# Usage: python $GTHOME/devtools/print-lex-graph.py < file.lexc > graph.dot
#
# The .dot file can be opened in OmniGraffle, but isn't rendered optimally.
# GraphViz should be preinstalled on the Mac, otherwise it is a macports installation away.
#
# Seems to work fine with both Python2 and Python3.
#
# NB! The script does not handle the following cases:
# * tabs before ; - any place
# * more than one space after LEXICON and before the lexicon name

import sys

g = {'#': []} # graph/tree
cur_lex = '' # current continuation lexicon
lines = [] # cache of the lines
nodes = {'#': 0} # node to id mapping
i = 1 # current id

# First read through the lexc file and make a list of the continuation lexica
for line in sys.stdin.readlines():
	line = line.strip()
	if line == '': continue
	if line[0] == '!': continue
	row = line.replace('% ', '%<SPACE>').replace(' ;', ';').replace(';', ' ;').split(' ')
	lines.append(row)
	if row[0] == 'LEXICON':
		if row[1] not in g: 
			g[row[1]] = []
			nodes[row[1]] = i
			i += 1
		continue

# Now read through again and do a map of lexicon -> outgoing lexicons
cur_lex = ''
for row in lines:
	s = 0
#	eprint("|")
	if row[0] == 'LEXICON': 
		cur_lex = row[1]
		continue
	if row[0].count(':') > 0 and row[1] != '' and row[1] != ';':
		s = 1
		g[cur_lex].append(row[1]);	
	elif len(row) >= 2 and row[1] == ';' and row[0] not in ['',';'] and row[0].count('<') == 0:  
		s = 2 
		g[cur_lex].append(row[0]);	
#	print('!', s, cur_lex, row, g, file=sys.stderr)	


# Print out the graph as a Graphviz .dot file (on stdout):
print('digraph G { rankdir="LR"')
print('node [fontname="Tahoma",shape=box,fontsize=14,fixedsize=false,fillcolor="grey",style=filled]')
print('edge [fontname="FreeMono",fontsize=14]')
for lex in g:
	print('%s [label="%s"];' % (nodes[lex], lex))
	g[lex] = list(set(g[lex]))
	for cont in g[lex]:
		print('@@', lex, cont, file=sys.stderr)
		print('%s -> %s ;' % (nodes[lex], nodes[cont]))
print('}')
