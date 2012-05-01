# -*- coding: utf-8 -*-
""" A quick and dirty script for processing álgu's MySQL XML dumps (delimited
with <row> </row> tags and xmllinted) into CSV, delimited by commas with a
header row. It is so quick and dirty it will probably break on something weird,
but should be easy to edit. Read the comments...

"""
from xml.dom import minidom as _dom
import sys
import re

field_re = re.compile('^<field name="(?P<id>[\w_-]+)">(?P<val>.*)</field>', re.U)
name_re = re.compile('^<field name="(?P<id>[\w_-]+)" (xsi:nil="(?P<val>.*)")?', re.U)

def process_chunk(chunk):

	def resplit(c):
		""" Join and resplit fields by tag ends, sometimes there are additional
		linebreak characters within the field and this breaks field processing.
		"""
		return ''.join(c)\
				.replace('field><field','field>\n<field')\
				.replace(' /><field', ' />\n<field').split('\n')
	
	def field(f):
		""" Get the row name and the value, special treatment for xsi:nil.
		"""
		try:
			fs = field_re.match(f).groups()
		except:
			if f.find('xsi:nil') > -1:
				name = name_re.match(f).groups()
				fs = (name[0], str(bool(name[1])))
		try:
			return fs
		except:
			# Uh oh.
			print repr(f)
			raw_input()
		
	fields = map(field, resplit(chunk))
	rows = [a[0] for a in fields]
	vals = [a[1] for a in fields]
	return rows, vals

def main(filename):

	# Count the lines fast
	with open(filename, 'r') as C:
		total = sum(1 for line in C)
	print >> sys.stderr, "%d lines to go..." % total

	# Read the file in chunks, chunking when <row> and </row> come through
	# When a chunk is complete, process it and output a (quick and dirty) line
	# of CSV.

	with open(filename, 'r') as F:
		chunk = []
		in_chunk = False
		header = False
		rows = set()
		count = 0
		for line in F:
			count += 1

			if count%10000 == 0:
				print >> sys.stderr, "%d/%d lines processed..." % (count, total)

			l = line.strip().decode('utf-8')
			if l == "<row>":
				in_chunk = True
			elif l == "</row>":
				order, vals = process_chunk(chunk)

				# Print the header only once
				if not header:
					header = order
					print >> sys.stdout, ','.join(header).encode('utf-8')

				r = ','.join(vals).encode('utf-8')

				# If there are suddenly separate line-lengths, there may have
				# been a parsing error.
				rows.add(len(vals))
				if len(list(rows)) != 1:
					row_probs.append(r)
				
				# Print the line
				print >> sys.stdout, r

				# Reset the chunk
				chunk = []
				in_chunk = False

			# Otherwise append
			elif in_chunk:
				chunk.append(l)

		# Now we're done. Print helpful things.
		print >> sys.stderr, "%d/%d lines processed..." % (count, total)

		if len(list(rows)) != 1:
			print >> sys.stderr, "May be an issue with these rows..."
			print '\n'.join(row_probs)

		print >> sys.stderr, "All rows have %s items." % repr(list(rows))

if __name__ == "__main__":
	try:
		filename = sys.argv[1]
	except:
		print "Specify a filename." 
		sys.exit()
	
	sys.exit(main(filename))

