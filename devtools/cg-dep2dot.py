#!/usr/bin/env python3
"""Convert CG3 dependency analysis to Graphviz dot format.

Takes CG3 dependency annotated text as input and generates a dependency tree
visualization in Graphviz dot format.

Usage:
    cat input.cg3 | cg-dep2dot.py > output.dot
    cat input.cg3 | cg-dep2dot.py | dot -Tpng > tree.png
    cg-dep2dot.py input.cg3 -o output.dot
"""

import sys
import re
from argparse import ArgumentParser, RawDescriptionHelpFormatter
from pathlib import Path
from typing import List, Tuple, Optional


class Word:
    """Represents a word with its dependency information."""
    
    def __init__(self, word_id: int, form: str, lemma: str, morph_tags: str, 
                 dep_rel: str, head_id: int):
        self.word_id = word_id
        self.form = form
        self.lemma = lemma
        self.morph_tags = morph_tags
        self.dep_rel = dep_rel
        self.head_id = head_id
    
    def __repr__(self):
        return f"Word({self.word_id}, {self.form}, {self.lemma}, @{self.dep_rel} #{self.word_id}->{self.head_id})"


def parse_cg3_line(line: str) -> Optional[Tuple[str, str]]:
    """Parse a CG3 line and extract word form or analysis.
    
    Returns:
        Tuple of (type, content) where type is 'form' or 'analysis'
    """
    # Word form: "<word>"
    form_match = re.match(r'^"<(.+)>"', line)
    if form_match:
        return ('form', form_match.group(1))
    
    # Analysis line with dependency info
    # Example: 	"mun" Pron Pers Sg1 Nom <W:0.0> sentinit @SUBJ> #1->2
    if line.startswith('\t"'):
        return ('analysis', line.strip())
    
    return None


def extract_dependency_info(analysis_line: str) -> Optional[Tuple[str, str, str, str, int, int]]:
    """Extract lemma, morphological tags, dependency relation and IDs from analysis line.
    
    Returns:
        Tuple of (lemma, morph_tags, full_analysis, dep_rel, word_id, head_id)
    """
    # Extract lemma (between quotes)
    lemma_match = re.search(r'^"([^"]+)"', analysis_line)
    if not lemma_match:
        return None
    lemma = lemma_match.group(1)
    
    # Extract all tags between lemma and weight tag <W:X.Y>
    # Exclude tags on <tag> format (but keep the weight stop point)
    parts = analysis_line.split()
    morph_tags = []
    
    # Start after the lemma (parts[0] is the lemma with quotes)
    for i in range(1, len(parts)):
        part = parts[i]
        # Stop when we hit the weight tag
        if re.match(r'<W:', part):
            break
        # Skip tags on <tag> format (semantic/syntactic tags)
        if re.match(r'<[^@#].*>', part):
            continue
        # Stop at @ and # tags
        if part.startswith('@') or part.startswith('#'):
            break
        morph_tags.append(part)
    
    morph_tags_str = ' '.join(morph_tags)
    
    # Extract dependency relation (@...)
    dep_match = re.search(r'@([^\s]+)', analysis_line)
    dep_rel = dep_match.group(1) if dep_match else "?"
    
    # Extract dependency IDs (#id->head)
    id_match = re.search(r'#(\d+)->(\d+)', analysis_line)
    if not id_match:
        return None
    
    word_id = int(id_match.group(1))
    head_id = int(id_match.group(2))
    
    return (lemma, morph_tags_str, analysis_line, dep_rel, word_id, head_id)


def parse_cg3_input(lines: List[str]) -> List[Word]:
    """Parse CG3 dependency annotated text.
    
    Returns:
        List of Word objects
    """
    words = []
    current_form = None
    
    for line in lines:
        line = line.rstrip('\n')
        if not line or line.startswith(':'):
            continue
        
        parsed = parse_cg3_line(line)
        if not parsed:
            continue
        
        line_type, content = parsed
        
        if line_type == 'form':
            current_form = content
        elif line_type == 'analysis' and current_form:
            dep_info = extract_dependency_info(content)
            if dep_info:
                lemma, morph_tags, full_analysis, dep_rel, word_id, head_id = dep_info
                word = Word(word_id, current_form, lemma, morph_tags, dep_rel, head_id)
                words.append(word)
                # Use first analysis only
                current_form = None
    
    return words


def generate_dot(words: List[Word], title: str = "") -> str:
    """Generate Graphviz dot format for dependency tree.
    
    Args:
        words: List of Word objects
        title: Title for the graph
    
    Returns:
        Dot format string
    """
    # Sort words by ID to ensure correct order
    words = sorted(words, key=lambda w: w.word_id)
    
    dot_lines = [
        'digraph dependency {',
        '    rankdir=TB;',
        '    node [shape=box, style=rounded, fontname="Arial"];',
        '    edge [fontname="Arial", fontsize=10, dir=none];',  # dir=none removes arrowheads by default
    ]
    
    # Add title if provided
    if title:
        dot_lines.extend([
            f'    labelloc="t";',
            f'    label="{title}";',
        ])
    
    dot_lines.extend([
        '',
        '    // Root node - will be placed above',
        '    0 [label="ROOT", shape=ellipse, style=filled, fillcolor=lightgray];',
        ''
    ])
    
    # Add syntax function nodes (above words)
    dot_lines.append('    // Syntax function nodes')
    for word in words:
        syn_label = word.dep_rel.replace('"', '\\"')
        dot_lines.append(f'    s{word.word_id} [label="{syn_label}", shape=ellipse, style=filled, fillcolor=lightblue];')
    
    dot_lines.append('')
    
    # Add morphology nodes (lemma + tags, between syntax and word)
    dot_lines.append('    // Morphology nodes (lemma + tags)')
    for word in words:
        # Escape quotes in labels
        lemma = word.lemma.replace('"', '\\"')
        morph_tags = word.morph_tags.replace('"', '\\"')
        label = f'{lemma}\\n{morph_tags}'
        dot_lines.append(f'    m{word.word_id} [label="{label}", style=filled, fillcolor=lightyellow];')
    
    dot_lines.append('')
    
    # Add word nodes (word forms only, bottom level)
    dot_lines.append('    // Word nodes (word forms)')
    for word in words:
        # Escape quotes in labels
        form = word.form.replace('"', '\\"')
        dot_lines.append(f'    w{word.word_id} [label="{form}"];')
    
    dot_lines.append('')
    
    # Keep morphology nodes in horizontal order on same level
    dot_lines.append('    // Keep morphology nodes in text order')
    dot_lines.append('    {')
    dot_lines.append('        rank=same;')
    for i in range(len(words) - 1):
        dot_lines.append(f'        m{words[i].word_id} -> m{words[i+1].word_id} [style=invis];')
    dot_lines.append('    }')
    dot_lines.append('')
    
    # Keep word nodes in horizontal order on same level
    dot_lines.append('    // Keep word nodes in text order')
    dot_lines.append('    {')
    dot_lines.append('        rank=same;')
    for i in range(len(words) - 1):
        dot_lines.append(f'        w{words[i].word_id} -> w{words[i+1].word_id} [style=invis];')
    dot_lines.append('    }')
    dot_lines.append('')
    
    # Add dependency edges between syntax nodes (with arrowheads) - creates hierarchy
    dot_lines.append('    // Dependency edges between syntax nodes (creates hierarchy)')
    for word in words:
        # Edges from ROOT (0) or between syntax nodes
        if word.head_id == 0:
            dot_lines.append(f'    {word.head_id} -> s{word.word_id} [dir=forward];')
        else:
            dot_lines.append(f'    s{word.head_id} -> s{word.word_id} [dir=forward];')
    
    dot_lines.append('')
    
    # Vertical edges from syntax nodes to morphology nodes
    dot_lines.append('    // Vertical edges from syntax to morphology (keep in same column)')
    for word in words:
        dot_lines.append(f'    s{word.word_id} -> m{word.word_id} [weight=10];')
    
    dot_lines.append('')
    
    # Vertical edges from morphology nodes to word nodes
    dot_lines.append('    // Vertical edges from morphology to words (keep in same column)')
    for word in words:
        dot_lines.append(f'    m{word.word_id} -> w{word.word_id} [weight=10];')
    
    dot_lines.append('}')
    
    return '\n'.join(dot_lines)


def parse_args():
    """Parse command line arguments."""
    parser = ArgumentParser(
        description='Convert CG3 dependency analysis to Graphviz dot format',
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument(
        'input',
        nargs='?',
        type=Path,
        help='Input file with CG3 dependency analysis (default: stdin)'
    )
    parser.add_argument(
        '-o', '--output',
        type=Path,
        help='Output dot file (default: stdout)'
    )
    parser.add_argument(
        '-t', '--title',
        default='',
        help='Title for the graph'
    )
    return parser.parse_args()


def main():
    args = parse_args()
    
    # Read input
    if args.input:
        with args.input.open('r', encoding='utf-8') as f:
            lines = f.readlines()
    else:
        lines = sys.stdin.readlines()
    
    # Parse CG3 input
    words = parse_cg3_input(lines)
    
    if not words:
        print("Error: No dependency relations found in input", file=sys.stderr)
        sys.exit(1)
    
    # Generate dot format
    dot_output = generate_dot(words, args.title)
    
    # Write output
    if args.output:
        with args.output.open('w', encoding='utf-8') as f:
            f.write(dot_output)
        print(f"Generated {args.output}", file=sys.stderr)
    else:
        print(dot_output)


if __name__ == '__main__':
    main()
