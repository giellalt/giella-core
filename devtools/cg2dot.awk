#!/usr/bin/awk -f

# From: https://gist.github.com/unhammer/f793d118e11dbc629a55d4e85d198a3d
# Usage:
# awk -f cg2dot.awk < cg-output.txt > tree.dot && dot -Tpng tree.dot -o tree.png

BEGIN {
    FS="^\"<|>\""
    print "digraph ParseTree {"
    print "\tnode [shape=plaintext];"
    print "\tedge [fontname=Helvetica, fontsize=10];"
    print ""
}


/^"/{
    wf = $2
    gsub(/[<>]/, "_", wf)       # "escape" html
    s=s" "wf
}

/^\t/ {
    dep=$0; sub(/.* #/, "", dep); sub(/ .*/, "", dep)
    id=dep; sub(/->.*/, "", id)
    parent=dep; sub(/.*->/, "", parent)
    flabel=$0; sub(/.* @/, "", flabel); sub(/ .*/, "", flabel)
    mainpos=$0; sub(/.*" +/, "", mainpos); sub(/ .*/, "", mainpos)
    lemma=$0; sub(/^\t+"/, "", lemma); sub(/".*/, "", lemma)
    # print $0, "\n", dep, id, parent, flabel, mainpos
    gsub(/[<>]/, "_", flabel)
    printf "\t\"%d\" [label=<<i>%s</i><br/><font color=\"#665544\" point-size=\"10\">%s</font><br/><font color=\"#337733\" point-size=\"10\">%s</font>>]\n", id, wf, lemma, mainpos
    printf "\t\"%d\" -> \"%d\" [label=<<font color=\"#443399\">%s</font>>]\n", id, parent, flabel
}

END {
    printf "\t{ rank = sink; \n\t\tLegend [shape=none, margin=0, label=<<font point-size=\"12\">%s</font>>];\n\t}\n", s
    print "\n}"
}
