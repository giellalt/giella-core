# A tailored & stand-alone copy of the morph-test.py module of Apertium Quality
# (http://wiki.apertium.org/wiki/Apertium-quality). Requires at least python3.1
# but autconf should check that for you. Also requires that you have a proper
# installation of py-yaml, but that as well should be handled by autoconf/
# configure.ac.
#
# This script is used to run the yaml test cases for morphology & morphophonology
# tests.

from multiprocessing import Process, Manager
from subprocess import Popen, PIPE
from glob import glob
from datetime import datetime
from hashlib import sha1
from tempfile import NamedTemporaryFile
from argparse import ArgumentParser
from io import StringIO
from collections import OrderedDict

import os
import os.path
import re
import urllib.request
import shlex
import itertools
import traceback
import time
import sys
import codecs
import yaml


try:
	from lxml import etree
	from lxml.etree import Element, SubElement
except:
	import xml.etree.ElementTree as etree
	from xml.etree.ElementTree import Element, SubElement


# SUPPORT FUNCTIONS

def string_to_list(data):
	if isinstance(data, bytes): return [data.decode('utf-8')]
	elif isinstance(data, str): return [data]
	else: return data

def invert_dict(data):
		tmp = OrderedDict()
		for key, val in data.items():
			for v in string_to_list(val):
				tmp.setdefault(v, set()).add(key)
		return tmp

def colourise(string, opt=None):
	#TODO per class, make into a class too
	def red(s="", r="\033[m"):
		return "\033[1;31m%s%s" % (s, r)
	def green(s="", r="\033[m"):
		return "\033[0;32m%s%s" % (s, r)
	def orange(s="", r="\033[m"):
		return "\033[0;33m%s%s" % (s, r)
	def yellow(s="", r="\033[m"):
		return "\033[1;33m%s%s" % (s, r)
	def blue(s="", r="\033[m"):
		return "\033[0;34m%s%s" % (s, r)
	def light_blue(s="", r="\033[m"):
		return "\033[0;36m%s%s" % (s, r)
	def reset(s=""):
		return "\033[m%s" % s

	if not opt:
		x = string
		x = x.replace("=>", blue("=>"))
		x = x.replace("<=", blue("<="))
		x = x.replace("PASS", green("PASS"))
		x = x.replace("FAIL", red("FAIL"))
		return x

	elif opt == 1:
		return light_blue(string)

	elif opt == 2:
		x = string.replace('asses: ', 'asses: %s' % green(r=""))
		x = x.replace('ails: ', 'ails: %s' % red(r=""))
		x = x.replace(', ', reset(', '))
		x = x.replace('otal: ', 'otal: %s' % light_blue(r=""))
		return "%s%s" % (x, reset())

def whereis(programs):
	out = {}
	for p in programs:
		for path in os.environ.get('PATH', '').split(':'):
			if os.path.exists(os.path.join(path, p)) and \
			   not os.path.isdir(os.path.join(path, p)):
					out[p] = os.path.join(path, p)
		if not out.get(p):
			raise EnvironmentError("Cannot find `%s`. Check $PATH." % p)
	return out

class UncleanWorkingDirectoryException(Exception):
	pass

# SUPPORT CLASSES

class LookupError(Exception):
	pass

# Courtesy of https://gist.github.com/844388. Thanks!
class _OrderedDictYAMLLoader(yaml.Loader):
	"""A YAML loader that loads mappings into ordered dictionaries."""

	def __init__(self, *args, **kwargs):
		yaml.Loader.__init__(self, *args, **kwargs)

		self.add_constructor('tag:yaml.org,2002:map', type(self).construct_yaml_map)
		self.add_constructor('tag:yaml.org,2002:omap', type(self).construct_yaml_map)

	def construct_yaml_map(self, node):
		data = OrderedDict()
		yield data
		value = self.construct_mapping(node)
		data.update(value)

	def construct_mapping(self, node, deep=False):
		if isinstance(node, yaml.MappingNode):
			self.flatten_mapping(node)
		else:
			raise yaml.constructor.ConstructorError(None, None,
				'expected a mapping node, but found %s' % node.id, node.start_mark)

		mapping = OrderedDict()
		for key_node, value_node in node.value:
			key = self.construct_object(key_node, deep=deep)
			try:
				hash(key)
			except TypeError as exc:
				raise yaml.constructor.ConstructorError('while constructing a mapping',
					node.start_mark, 'found unacceptable key (%s)' % exc, key_node.start_mark)
			value = self.construct_object(value_node, deep=deep)
			mapping[key] = value
		return mapping

class Test(object):
	"""Abstract class for Test objects

	It is recommended that print not be used within a Test class.
	Use a StringIO instance and .getvalue() in to_string().
	"""

	"""Attributes"""
	timer = None

	def __str__(self):
		"""Will return to_string method's content if exists,
		otherwise default to parent class
		"""
		try: return self.to_string()
		except: return object.__str__(self)

	def _checksum(self, data):
		"""Returns checksum hash for given data (currently SHA1) for the purpose
		of maintaining integrity of test data.
		"""
		if hasattr(data, 'encode'):
			data = data.encode('utf-8')
		return sha1(data).hexdigest()

	def _svn_revision(self, directory):
		"""Returns the SVN revision of the given dictionary directory"""
		whereis(['svnversion'])
		res = Popen('svnversion', stdout=PIPE, close_fds=True).communicate()[0].decode('utf-8').strip()
		try:
			int(res) # will raise error if it can't be int'd
			return str(res)
		except:
			raise UncleanWorkingDirectoryException("You must have a clean SVN directory. Commit or remove uncommitted files.")

	def run(self, *args, **kwargs):
		"""Runs the actual test

		Parameters: none
		Returns: integer >= 0 <= 255  (exit value)
		"""
		raise NotImplementedError("Required method `run` was not implemented.")

	def to_xml(self, *args, **kwargs):
		"""Output XML suitable for saving in Statistics format.
		It is recommended that you use etree for creating the tree.

		Parameters: none
		Returns: (string, string)
			first being parent node, second being xml
		"""
		raise NotImplementedError("Required method `to_xml` was not implemented.")

	def to_string(self, *args, **kwargs):
		"""Prints the output of StringIO instance and other printable output.

		Parameters: none
		Returns: string
		"""
		raise NotImplementedError("Required method `to_string` was not implemented.")


class MorphTest(Test):
	class AllOutput(StringIO):
		def __str__(self):
			return self.to_string()

		def title(self, *args): pass
		def success(self, *args): pass
		def failure(self, *args): pass
		def result(self, *args): pass

		def final_result(self, hfst):
			text = "Total passes: %d, Total fails: %d, Total: %d\n"
			self.write(colourise(text % (hfst.passes, hfst.fails, hfst.fails+hfst.passes), 2))

		def to_string(self):
			return self.getvalue()

	class NormalOutput(AllOutput):
		def title(self, text):
			self.write(colourise("-"*len(text)+'\n', 1))
			self.write(colourise(text+'\n', 1))
			self.write(colourise("-"*len(text)+'\n', 1))

		def success(self, l, r):
			self.write(colourise("[PASS] %s => %s\n" % (l, r)))

		def failure(self, form, err, errlist):
			self.write(colourise("[FAIL] %s => %s: %s\n" % (form, err, ", ".join(errlist))))

		def result(self, title, test, counts):
			p = counts["Pass"]
			f = counts["Fail"]
			text = "\nTest %d - Passes: %d, Fails: %d, Total: %d\n"
			self.write(colourise(text % (test, p, f, p+f), 2))

	class CompactOutput(AllOutput):
		def __init__(self, args):
			super().__init__()
			self.args = args

		def result(self, title, test, counts):
			p = counts["Pass"]
			f = counts["Fail"]
			out = "%s %d/%d/%d" % (title, p, f, p+f)
			if counts["Fail"] > 0:
				if not self.args.get('hide_fail'):
					self.write(colourise("[FAIL] %s\n" % out))
			elif not self.args.get('hide_pass'):
				self.write(colourise("[PASS] %s\n" % out))

	class TerseOutput(AllOutput):
		def final_result(self, counts):
			if counts.fails > 0:
				self.write(colourise("FAIL\n"))
			else:
				self.write(colourise("PASS\n"))

	class NoOutput(AllOutput):
		pass

	def __init__(self, f=None, **kwargs):
		self.args = dict(kwargs)
		self.f = self.args.get('test_file', f)

		self.fails = 0
		self.passes = 0

		self.count = OrderedDict()
		self.load_config()

	def run(self):
		timing_begin = time.time()
		self.run_tests(self.args['test'])
		self.timer = time.time() - timing_begin
		if self.fails > 0:
			return 1
		else:
			return 0

	def load_config(self):
		global colourise
		if self.f.endswith('lexc'):
			f = parse_lexc_trans(open(self.f),
					self.args.get('gen'),
					self.args.get('morph'),
					self.args.get('app'),
					self.args.get('transducer'),
					self.args.get('section'))
		else:
			f = yaml.load(open(self.f), _OrderedDictYAMLLoader)

		section = f.get("Config", {}).get(self.args['section'], {})
		self.program = shlex.split(self.args.get('app') or section.get("App", "hfst-lookup"))
		whereis([self.program[0]])

		self.gen = self.args.get('gen') or section.get("Gen", None)
		self.morph = self.args.get('morph') or section.get("Morph", None)

		if self.args.get('surface', None):
			self.gen = None
		if self.args.get('lexical', None):
			self.morph = None

		if self.gen == self.morph == None:
			raise AttributeError("One of Gen or Morph must be configured.")

		for i in (self.gen, self.morph):
			if i and not os.path.isfile(i):
				raise IOError("File %s does not exist." % i)

		if self.args.get('silent'):
			self.out = MorphTest.NoOutput()
		elif self.args.get('terse'):
			self.out = MorphTest.TerseOutput()
		elif self.args.get('compact'):
			self.out = MorphTest.CompactOutput(self.args)
		else:
			self.out = MorphTest.NormalOutput()

		if self.args.get('verbose'):
			self.out.write("`%s` will be used for parsing dictionaries.\n" % self.program)

		self.tests = f["Tests"]
		for test in self.tests:
			for key, val in self.tests[test].items():
				self.tests[test][key] = string_to_list(val)

		if not self.args.get('colour'):
			colourise = lambda x, y=None: x

	def run_tests(self, data=None):
		if self.args.get('surface') == self.args.get('lexical') == False:
			self.args['surface'] = self.args['lexical'] = True

		if data != None:
			self.parse_fsts(self.tests[data[0]])
			if self.args.get('lexical'): self.run_test(data[0], True)
			if self.args.get('surface'): self.run_test(data[0], False)

		else:
			tests = {}
			for t in self.tests:
				tests.update(self.tests[t])
			self.parse_fsts(tests)
			for t in self.tests:
				if self.args.get('lexical'): self.run_test(t, True)
				if self.args.get('surface'): self.run_test(t, False)

		if self.args.get('verbose') or self.args.get('terse'):
			self.out.final_result(self)

	def parse_fsts(self, tests):
		invtests = invert_dict(tests)
		manager = Manager()
		self.results = manager.dict({"gen": {}, "morph": {}})

		def parser(self, d, f, tests):
			keys = [key.lstrip("~") for key in tests.keys()]
			app = Popen(self.program + [f], stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
			args = '\n'.join(keys) + '\n'

			res, err = app.communicate(args.encode('utf-8'))
			res = res.decode('utf-8').split('\n\n')
			err = err.decode('utf-8').strip()

			if app.returncode != 0:
				self.results['err'] = "\n".join(
					[i for i in [res[0], err, "(Error code: %s)" % app.returncode] if i != '']
				)
			else:
				self.results[d] = self.parse_fst_output(res)

		gen = Process(target=parser, args=(self, "gen", self.gen, tests))
		gen.daemon = True
		gen.start()
		if self.args.get('verbose'):
			self.out.write("Generating...\n")

		morph = Process(target=parser, args=(self, "morph", self.morph, invtests))
		morph.daemon = True
		morph.start()
		if self.args.get('verbose'):
			self.out.write("Morphing...\n")

		gen.join()
		morph.join()

		if self.args.get('verbose'):
			self.out.write("Done!\n")

	def get_forms(self, test, forms):
		if test.startswith('~'):
			test = test.lstrip("~")
			detested = set()
			expected = set()
			for i in forms:
				if i.startswith('~'):
					expected.add(i.lstrip('~'))
				else:
					detested.add(i)
		else:
			detested = set([i.lstrip('~') for i in forms if i.startswith('~')])
			expected = set([i.lstrip('~') for i in forms if not i.startswith('~')])
		return test, detested, expected

	def run_test(self, data, is_lexical):
		if is_lexical:
			desc = "Lexical/Generation"
			f = "gen"
			tests = self.tests[data]

		else: #surface
			desc = "Surface/Analysis"
			f = "morph"
			tests = invert_dict(self.tests[data])

		if self.results.get('err'):
			raise LookupError('`%s` had an error:\n%s' % (self.program, self.results['err']))

		c = len(self.count)
		d = "%s (%s)" % (data, desc)
		title = "Test %d: %s" % (c, d)
		self.out.title(title)

		self.count[d] = {"Pass": 0, "Fail": 0}

		for test, forms in tests.items():
			actual_results = set(self.results[f][test.lstrip("~")])
			test, detested_results, expected_results = self.get_forms(test, forms)

			missing = set()
			invalid = set()
			success = set()
			detested = set()
			missing_detested = set()
			passed = False

			for form in expected_results:
				if not form in actual_results:
					missing.add(form)

			for form in detested_results:
				if form in actual_results:
					detested.add(form)
					actual_results.remove(form)
				else:
					missing_detested.add(form)

			for form in actual_results:
				if not form in expected_results:
					invalid.add(form)

			if len(expected_results) > 0:
				for form in actual_results:
					if not form in (missing | invalid | detested):
						passed = True
						success.add(form)
						self.count[d]["Pass"] += 1
						if not self.args.get('hide_pass'):
							self.out.success(test, form)
				for form in missing_detested:
					passed = True
					success.add(form)
					self.count[d]["Pass"] += 1
					if not self.args.get('hide_pass'):
						self.out.success(test, "<No '%s' %s>" % (form, desc.lower()))
			else:
				if len(invalid) == 1 and list(invalid)[0].endswith("+?"):
					invalid = set()
					passed = True
					self.count[d]["Pass"] += 1
					if not self.args.get('hide_pass'):
						self.out.success(test, "<No %s>" % desc.lower())

			if len(missing) > 0:
				if not self.args.get('hide_fail'):
					self.out.failure(test, "Missing results", missing)
				self.count[d]["Fail"] += len(missing)
			if len(invalid) > 0 and \
					(not self.args.get('ignore_analyses') or not passed):
				if not self.args.get('hide_fail'):
					self.out.failure(test, "Unexpected results", invalid)
				self.count[d]["Fail"] += len(invalid)
			if len(detested) > 0:
				if self.args.get('colour'):
					msg = "\033[1;31mBROKEN!\033[m"
				else:
					msg = "BROKEN!"
				if not self.args.get('hide_fail'):
					self.out.failure(test, msg + " Negative results", detested)
				self.count[d]["Fail"] += len(detested)

		self.out.result(title, c, self.count[d])

		self.passes += self.count[d]["Pass"]
		self.fails += self.count[d]["Fail"]

	def parse_fst_output(self, fst):
		parsed = {}
		for item in fst:
			res = item.replace('\r\n','\n').replace('\r','\n').split('\n')
			for i in res:
				if i.strip() != '':
					results = re.split(r'\t+', i)
					key = results[0].strip()
					if not key in parsed:
						parsed[key] = set()
					# This test is needed because xfst's lookup
					# sometimes output strings like
					# bearkoe\tbearkoe\t+N+Sg+Nom, instead of the expected
					# bearkoe\tbearkoe+N+Sg+Nom
					if len(results) > 2 and results[2][0] == '+':
						parsed[key].add(results[1].strip() + results[2].strip())
					else:
						parsed[key].add(results[1].strip())
		return parsed

	def to_xml(self):
		q = Element('config')
		q.attrib["value"] = self.f

		r = SubElement(q, "revision", value=str(self._svn_revision(dirname(self.f))),
					timestamp=datetime.utcnow().isoformat(),
					checksum=self._checksum(open(self.f, 'rb').read()))

		s = SubElement(r, 'gen')
		s.attrib["value"] = self.gen
		s.attrib["checksum"] = self._checksum(open(self.gen, 'rb').read())

		s = SubElement(r, 'morph')
		s.attrib["value"] = self.morph
		s.attrib["checksum"] = self._checksum(open(self.morph, 'rb').read())

		SubElement(r, 'total').text = str(self.passes + self.fails)
		SubElement(r, 'passes').text = str(self.passes)
		SubElement(r, 'fails').text = str(self.fails)

		s = SubElement(r, 'tests')
		for k, v in self.count.items():
			t = SubElement(s, 'test')
			t.text = str(k)
			t.attrib['fails'] = str(v["Fail"])
			t.attrib['passes'] = str(v["Pass"])

		s = SubElement(r, "system")
		SubElement(s, "speed").text = "%.4f" % self.timer

		return ("morph", etree.tostring(r))

	def to_string(self):
		return self.out.getvalue()


def parse_lexc(f, fallback=None):
	HEADER_RE = re.compile(r'^\!\!€([^\s:]+):\s*([^#]+)\s*#?')
	TEST_RE = re.compile(r'^\!\!([€\$])\s+(\S+)\s+(\S+)\s*#?')
	POS = "€"
	NEG = "$"

	output = {}
	trans = None
	test = None
	if isinstance(f, str):
		f = StringIO(f)

	lines = f.readlines()
	for line in lines:
		if line.startswith("LEXICON"):
			test = line.split(" ", 1)[-1]
			if fallback is not None:
				trans = fallback

		elif line.startswith("!!"):
			match = HEADER_RE.match(line)
			if match:
				trans = match.group(1)
				test = match.group(2).strip()
				if output.get(trans) is None:
					output[trans] = OrderedDict()
				if output[trans].get(test) is None:
					output[trans][test] = OrderedDict()
				continue

			match = TEST_RE.match(line)
			if test is None or trans is None:
				continue

			if TEST_RE.match(line):
				test_type = match.group(1)
				left = match.group(3)
				right = match.group(2)

				if test_type == NEG:
					right = "~" + right

				if output[trans][test].get(left) is None:
					output[trans][test][left] = []
				output[trans][test][left].append(right)
	return dict(output)

def parse_lexc_trans(f, gen=None, morph=None, app=None, fallback=None, lookup="hfst"):
	trans = None
	if gen is not None:
		trans = gen.rsplit('.', 1)[0].split('-', 1)[1]
	elif morph is not None:
		trans = morph.rsplit('.', 1)[0].split('-', 1)[1]
	elif fallback is not None:
		trans = fallback
	if trans is None or trans == "":
		raise AttributeError("Could not guess which transducer to use.")

	lexc = parse_lexc(f, fallback)[trans]
	if app is None:
		app = "hfst-lookup" if lookup == "hfst" else "lookup"
	config = {lookup: {"Gen": gen, "Morph": morph, "App": app}}
	return {"Config": config, "Tests": lexc}

def lexc_to_yaml_string(data):
	out = StringIO()
	out.write("Tests:\n")
	for trans, tests in data.items():
		for test, lines in tests.items():
			out.write("  %s:\n" % test)
			for left, rights in lines.items():
				if len(rights) == 1:
					out.write("	%s: %s\n" % (left, rights[0]))
				elif len(rights) > 1:
					out.write("	%s: [%s]\n" % (left, ", ".join(rights)))
	return out.getvalue()


class Frontend(Test, ArgumentParser):
	def __init__(self, stats=True, colour=False):
		ArgumentParser.__init__(self)
		Test.__init__(self)
		if colour:
			self.add_argument("-c", "--colour", dest="colour",
					action="store_true", help="Colours the output")

	def start(self):
		try:
			try:
				ret = self.run()
			except IOError as e:
				print(e)
				sys.exit(1)

			print(self.to_string())
			self.exit(ret)

		except KeyboardInterrupt:
			sys.exit()


class UI(Frontend, MorphTest):
	def __init__(self):
		Frontend.__init__(self, colour=True)
		self.description="""Test morphological transducers for consistency.
			`hfst-lookup` (or Xerox' `lookup` with argument -x) must be
			available on the PATH."""
		self.epilog="Will run all tests in the test_file by default."

		self.add_argument("-C", "--compact",
			dest="compact", action="store_true",
			help="Makes output more compact")
		self.add_argument("--terse",
			dest="terse", action="store_true",
			help="Show only PASS or FAIL for whole test.")
		self.add_argument("--silent",
			dest="silent", action="store_true",
			help="Hide all output; exit code only")
		self.add_argument("-i", "--ignore-extra-analyses",
			dest="ignore_analyses", action="store_true",
			help="""Ignore extra analyses when there are more than expected,
			will PASS if the expected one is found.""")
		self.add_argument("-s", "--surface",
			dest="surface", action="store_true",
			help="Surface input/analysis tests only")
		self.add_argument("-l", "--lexical",
			dest="lexical", action="store_true",
			help="Lexical input/generation tests only")
		self.add_argument("-f", "--hide-fails",
			dest="hide_fail", action="store_true",
			help="Suppresses passes to make finding failures easier")
		self.add_argument("-p", "--hide-passes",
			dest="hide_pass", action="store_true",
			help="Suppresses failures to make finding passes easier")
		self.add_argument("-S", "--section", default=["hfst"],
			dest="section", nargs=1, required=False,
			help="The section to be used for testing (default is `hfst`)")
		self.add_argument("-t", "--test",
			dest="test", nargs=1, required=False,
			help="""Which test to run (Default: all). TEST = test ID, e.g.
			'Noun - g\u00E5etie' (remember quotes if the ID contains spaces)""")
		self.add_argument("-F", "--fallback",
			dest="transducer", nargs=1, required=False,
			help="""Which fallback transducer to use.""")
		self.add_argument("-v", "--verbose",
			dest="verbose", action="store_true",
			help="More verbose output.")

		self.add_argument("--app", dest="app", nargs=1, required=False,
			help="Override application used for test")
		self.add_argument("--gen", dest="gen", nargs=1, required=False,
			help="Override generation transducer used for test")
		self.add_argument("--morph", dest="morph", nargs=1, required=False,
			help="Override morph transducer used for test")

		self.add_argument("test_file", nargs=1,
			help="YAML file with test rules")

		self.args = dict(self.parse_args()._get_kwargs())
		for k, v in self.args.copy().items():
			if isinstance(v, list) and len(v) == 1:
				self.args[k] = v[0]

		MorphTest.__init__(self, **self.args)

	def start(self):
		import sys
		ret = self.run()
		sys.stdout.write(self.to_string())
		self.exit(ret)

def main():
	try:
		ui = UI()
		ui.start()
	except KeyboardInterrupt:
		pass
	except Exception as e:
		print("Error: %r" % e)
		sys.exit(1)

if __name__ == "__main__":
	main()
