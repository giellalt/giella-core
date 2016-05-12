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
from argparse import ArgumentParser
from io import StringIO
from collections import OrderedDict, namedtuple

import os
import os.path
import re
import shlex
import shutil
import sys
import yaml


TestCase = namedtuple("TestCase", ['input', 'outputs'])


# SUPPORT FUNCTIONS

def string_to_list(data):
    if isinstance(data, bytes): return [data.decode('utf-8')]
    elif isinstance(data, str): return [data]
    else: return data

def invert_dict(data):
        tmp = OrderedDict()
        for key, val in data.items():
            for v in string_to_list(val):
                d = tmp.setdefault(v, [])
                if key not in d:
                    d.append(key)
        return tmp

COLORS = {
    "red": "\033[1;31m",
    "green": "\033[0;32m",
    "orange": "\033[0;33m",
    "yellow": "\033[1;33m",
    "blue": "\033[0;34m",
    "light_blue": "\033[0;36m",
    "reset": "\033[m"
}

def colourise(string, *args, **kwargs):
    kwargs.update(COLORS)
    return string.format(*args, **kwargs)

def check_path_exists(program):
    out = shutil.which(program)
    if out is None:
        raise EnvironmentError("Cannot find `%s`. Check $PATH." % program)
    return out

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


def yaml_load_ordered(f):
    return yaml.load(f, _OrderedDictYAMLLoader)


class TestFile:
    def __init__(self, data, system="hfst"):
        self.data = data
        self._system = system

    @property
    def surface_tests(self):
        tests = OrderedDict()
        for title, cases in self.data['Tests'].items():
            new_cases = []
            for surface, lexical in cases.items():
                new_cases.append(TestCase(input=surface, outputs=string_to_list(lexical)))
            tests[title] = new_cases
        return tests

    @property
    def lexical_tests(self):
        tests = OrderedDict()
        for title, cases in self.data['Tests'].items():
            new_cases = []
            for lexical, surface in invert_dict(cases).items():
                new_cases.append(TestCase(input=lexical, outputs=string_to_list(surface)))
            tests[title] = new_cases
        return tests

    @property
    def gen(self):
        return self.data.get("Config", {}).get(self._system, {}).get("Gen", None)

    @property
    def morph(self):
        return self.data.get("Config", {}).get(self._system, {}).get("Morph", None)

    @property
    def app(self):
        a = self.data.get("Config", {}).get(self._system, {}).get("App", None)
        if a is None:
            if self._system == "hfst":
                return ['hfst-lookup']
            elif self._system == "xerox":
                return ["lookup", "-flags", "mbTT"]
            else:
                raise Exception("Unknown system: '%s'" % self._system)
        return a

class MorphTest:
    class AllOutput():
        def __init__(self, args):
            self._io = StringIO()
            self.args = args

        def __str__(self):
            return self._io.getvalue()

        def write(self, data):
            self._io.write(data)

        def info(self, data):
            self.write(data)

        def title(self, *args): pass
        def success(self, *args): pass
        def failure(self, *args): pass
        def result(self, *args): pass
        def final_result(self, hfst):
            self.write(colourise("Total passes: {green}{passes}{reset}, " +
                "Total fails: {red}{fails}{reset}, " +
                "Total: {light_blue}{total}{reset}\n",
                passes=hfst.passes,
                fails=hfst.fails,
                total=hfst.fails+hfst.passes
            ))

    class NormalOutput(AllOutput):
        def title(self, text):
            self.write(colourise("{light_blue}-" * len(text) + '\n'))
            self.write(text + '\n')
            self.write(colourise("-" * len(text) + '{reset}\n'))

        def success(self, case, total, left, right):
            x = colourise(("[{light_blue}{case:>%d}/{total}{reset}][{green}PASS{reset}] " +
                          "{left} {blue}=>{reset} {right}\n") % len(str(total)),
                          left=left, right=right, case=case, total=total)
            self.write(x)

        def failure(self, case, total, left, right, errlist):
            x = colourise(("[{light_blue}{case:>%d}/{total}{reset}][{red}FAIL{reset}] " +
                          "{left} {blue}=>{reset} {right}: {errlist}\n") % len(str(total)),
                          left=left, right=right, case=case, total=total,
                          errlist=", ".join(errlist))
            self.write(x)

        def result(self, title, test, counts):
            p = counts["Pass"]
            f = counts["Fail"]
            text = colourise("\nTest {n} - Passes: {green}{passes}{reset}, " +
                   "Fails: {red}{fails}{reset}, " +
                   "Total: {light_blue}{total}{reset}\n",
                   n=test, passes=p, fails=f, total=p+f)
            self.write(text)

    class CompactOutput(AllOutput):
        def result(self, title, test, counts):
            p = counts["Pass"]
            f = counts["Fail"]
            out = "%s %d/%d/%d" % (title, p, f, p+f)
            if counts["Fail"] > 0:
                if not self.args.hide_fail:
                    self.write(colourise("[{red}FAIL{reset}] {}\n", out))
            elif not self.args.hide_pass:
                self.write(colourise("[{green}PASS{reset}] {}\n", out))

    class TerseOutput(AllOutput):
        def success(self, case, total, l, r):
            self.write(colourise("{green}.{reset}"))
        def failure(self, case, total, form, err, errlist):
            self.write(colourise("{red}!{reset}"))
        def result(self, title, test, counts):
            self.write('\n')
        def final_result(self, counts):
            if counts.fails > 0:
                self.write(colourise("{red}FAIL{reset}\n"))
            else:
                self.write(colourise("{green}PASS{reset}\n"))

    class FinalOutput(AllOutput):
        def final_result(self, counts):
            p = counts.passes
            f = counts.fails
            self.write("%d/%d/%d " % (p, f, p+f))

    class NoOutput(AllOutput):
        def final_result(self, *args):
            pass

    def __init__(self, args):
        self.args = args

        # TODO: check for null case

        self.fails = 0
        self.passes = 0

        self.count = OrderedDict()
        self.load_config(self.args.test_file)

    def run(self):
        #timing_begin = time.time()
        self.run_tests(self.args.test)
        #self.timer = time.time() - timing_begin
        if self.fails > 0:
            return 1
        else:
            return 0

    def load_config(self, fn):
        args = self.args

        if fn.endswith('lexc'):
            self.config = TestFile(parse_lexc_trans(open(fn),
                    args.gen,
                    args.morph,
                    args.app,
                    args.transducer,
                    args.section), args.section)
        else:
            self.config = TestFile(yaml_load_ordered(open(fn)), args.section)

        config = self.config

        app = args.app or config.app
        if isinstance(app, str):
            app = app.split(" ")
        self.program = string_to_list(app)
        check_path_exists(self.program[0])

        self.gen = args.gen or config.gen
        self.morph = args.morph or config.morph

        if args.surface:
            self.gen = None
        if args.lexical:
            self.morph = None

        if self.gen == self.morph == None:
            raise AttributeError("One of Gen or Morph must be configured.")

        for i in (self.gen, self.morph):
            if i and not os.path.isfile(i):
                raise IOError("File %s does not exist." % i)

        if args.silent:
            self.out = MorphTest.NoOutput(args)
        else:
            self.out = {
                "normal": MorphTest.NormalOutput,
                "terse": MorphTest.TerseOutput,
                "compact": MorphTest.CompactOutput,
                "silent": MorphTest.NoOutput,
                "final": MorphTest.FinalOutput
            }.get(args.output, lambda x: None)(args)

        if self.out is None:
            raise AttributeError("Invalid output mode supplied: %s" % args.output)

        if args.verbose:
            self.out.info("`%s` will be used for parsing dictionaries.\n" % self.program[0])

        if not args.colour:
            for key in list(COLORS.keys()):
                COLORS[key] = ""

    def run_tests(self, single_test=None):
        args = self.args
        config = self.config

        if args.surface == args.lexical == False:
            args.surface = args.lexical = True

        if single_test is not None:
            self.parse_fsts(single_test)
            if args.lexical: self.run_test(single_test, True)
            if args.surface: self.run_test(single_test, False)

        else:
            self.parse_fsts()

            if args.lexical:
                for t in config.lexical_tests:
                    self.run_test(t, True)

            if args.surface:
                for t in config.surface_tests:
                    self.run_test(t, False)

        self.out.final_result(self)

    def parse_fsts(self, key=None):
        args = self.args
        manager = Manager()
        self.results = manager.dict({"gen": {}, "morph": {}})

        def parser(self, d, f, tests):
            # TODO: handle ~ in file parser
            if key is not None:
                keys = [x.lstrip("~") for x in tests[key]]
            else:
                keys = [x[0].lstrip("~") for vals in tests.values() for x in vals]
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

        if args.lexical:
            gen = Process(target=parser, args=(self, "gen", self.gen, self.config.surface_tests))
            gen.start()
            if self.args.verbose:
                self.out.info("Generating...\n")

        if args.surface:
            morph = Process(target=parser, args=(self, "morph", self.morph, self.config.lexical_tests))
            morph.start()
            if self.args.verbose:
                self.out.info("Morphing...\n")

        if args.lexical:
            gen.join()
        if args.surface:
            morph.join()

        if self.args.verbose:
            self.out.info("Done!\n")

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
            tests = self.config.surface_tests[data]

        else: #surface
            desc = "Surface/Analysis"
            f = "morph"
            tests = self.config.lexical_tests[data]

        res = self.results[f]

        if self.results.get('err'):
            raise LookupError('`%s` had an error:\n%s' % (self.program, self.results['err']))

        c = len(self.count)
        d = "%s (%s)" % (data, desc)
        title = "Test %d: %s" % (c, d)
        self.out.title(title)

        self.count[d] = {"Pass": 0, "Fail": 0}

        caseslen = len(tests)
        for n, testcase in enumerate(tests):
            n += 1 # off by one annoyance

            test = testcase.input
            forms = testcase.outputs

            actual_results = set(res[test.lstrip("~")])
            test, detested_results, expected_results = self.get_forms(test, forms)

            missing = set()
            invalid = set()
            success = set()
            detested = set()
            missing_detested = set()

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
                        if not self.args.hide_pass:
                            self.out.success(n, caseslen, test, form)
                for form in missing_detested:
                    success.add(form)
                    self.count[d]["Pass"] += 1
                    if not self.args.hide_pass:
                        self.out.success(n, caseslen, test, "<No '%s' %s>" % (form, desc.lower()))
            else:
                if len(invalid) == 1 and list(invalid)[0].endswith("+?"):
                    invalid = set()
                    self.count[d]["Pass"] += 1
                    if not self.args.hide_pass:
                        self.out.success(n, caseslen, test, "<No %s>" % desc.lower())

            if len(missing) > 0:
                if not self.args.hide_fail:
                    self.out.failure(n, caseslen, test, "Missing results", missing)
                #self.count[d]["Fail"] += len(missing)

            if len(invalid) > 0:
                if not is_lexical and self.args.ignore_analyses:
                    invalid = set() # hide this for the final check
                elif not self.args.hide_fail:
                    self.out.failure(n, caseslen, test, "Unexpected results", invalid)
                #self.count[d]["Fail"] += len(invalid)

            if len(detested) > 0:
                if self.args.colour:
                    msg = colourise("{red}BROKEN!{reset}")
                else:
                    msg = "BROKEN!"
                if not self.args.hide_fail:
                    self.out.failure(n, caseslen, test, msg + " Negative results", detested)
                #self.count[d]["Fail"] += len(detested)
            if len(detested) + len(missing) + len(invalid) > 0:
                self.count[d]["Fail"] += 1

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

    def __str__(self):
        return str(self.out)

# Debug regex at: https://debuggex.com
# Visualisation of the TEST_RE regex:
# https://debuggex.com/i/kURzt7XS3t83-dvT.png
# Link to debuggex page with this regex:
# https://debuggex.com/r/kURzt7XS3t83-dvT
def parse_lexc(f, fallback=None):
    HEADER_RE = re.compile(r'^\!\!€([^\s.:]+)(?:.[^\s:]+)?:\s*([^#]+)\s*#?')
    TEST_RE = re.compile(r'^\!\!([€\$])\s+(\S.*):\s+(\S+|\S.*\S)(\s*$|\s+[#!])')
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
                test_type = match.group(1).strip()
                left = match.group(3).strip()
                right = match.group(2).strip()

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
        app = ["hfst-lookup"] if lookup == "hfst" else ["lookup", "-flags", "mbTT"]
    config = {lookup: {"Gen": gen, "Morph": morph, "App": string_to_list(app)}}
    return {"Config": config, "Tests": lexc}

def lexc_to_yaml_string(data):
    out = StringIO()
    out.write("Tests:\n")
    for trans, tests in data.items():
        for test, lines in tests.items():
            out.write("  %s:\n" % test)
            for left, rights in lines.items():
                if len(rights) == 1:
                    out.write("    %s: %s\n" % (left, rights[0]))
                elif len(rights) > 1:
                    out.write("    %s: [%s]\n" % (left, ", ".join(rights)))
    return out.getvalue()


class UI(ArgumentParser):
    def __init__(self):
        ArgumentParser.__init__(self)

        self.description="""Test morphological transducers for consistency."""
        self.epilog="Will run all tests in the test_file by default."

        self.add_argument("-c", "--colour", dest="colour",
            action="store_true", help="Colours the output")
        self.add_argument("-o", "--output",
            dest="output", default="normal",
            help="Desired output style: compact, terse, final, normal (Default: normal)")
        self.add_argument("-q", "--silent",
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
        self.add_argument("-S", "--section", default="hfst",
            dest="section", nargs='?', required=False,
            help="The section to be used for testing (default is `hfst`)")
        self.add_argument("-t", "--test",
            dest="test", nargs='?', required=False,
            help="""Which test to run (Default: all). TEST = test ID, e.g.
            'Noun - g\u00E5etie' (remember quotes if the ID contains spaces)""")
        self.add_argument("-F", "--fallback",
            dest="transducer", nargs='?', required=False,
            help="""Which fallback transducer to use.""")
        self.add_argument("-v", "--verbose",
            dest="verbose", action="store_true",
            help="More verbose output.")

        self.add_argument("--app", dest="app", nargs='?', required=False,
            help="Override application used for test")
        self.add_argument("--gen", dest="gen", nargs='?', required=False,
            help="Override generation transducer used for test")
        self.add_argument("--morph", dest="morph", nargs='?', required=False,
            help="Override morph transducer used for test")

        self.add_argument("test_file",
            help="YAML file with test rules")

        self.test = MorphTest(self.parse_args())

    def start(self):
        ret = self.test.run()
        sys.stdout.write(str(self.test))
        sys.exit(ret)

def main():
    try:
        ui = UI()
        ui.start()
    except KeyboardInterrupt:
        sys.exit(130)
    #except Exception as e:
    #    print("Error: %r" % e)
    #    sys.exit(1)

if __name__ == "__main__":
    main()
