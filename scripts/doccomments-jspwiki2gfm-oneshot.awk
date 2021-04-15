# An AWK preprocessor to replace doc comments in Xerox lexc, twolc and VISL CG3
# files from old JSPWIKI format to new GitHub Flavoured MarkDown.
BEGIN {
    # Initialise the referable variables
    TABLESIZE=0;
    THEAD="|:--"
}
function jsp2gfm(s) {
    return gensub(/\[(.*)\|(.*)\]/, "[\\1](\\2)", "g", 
           gensub("__ *([^_]*[^_ ]+) *__", "**\\1**", "g",
           gensub("'' *([^']*[^' ]+) *''", "*\\1*", "g",
           gensub("^ *!", "### ", "1",
           gensub("^ *!!", "## ", "1", 
           gensub("^ *!!!", "# ", "1",
           gensub("{%", "{", "g",
           gensub("{{", "`", "g",
           gensub("}}", "`", "g",
           gensub("{{{", "```", "g",
           gensub("}}}", "```", "g", 
           gensub(/^ *; *(.*[^ ]) *:(.*)$/, "* **\\1**: \\2", "g",
           gensub(/^ *\|([^|].*) *$/, "| \\1", "g",
           gensub(/^# (.*)$/, "1. \\1", "g",
           gensub(/^## (.*)$/, "    1. \\1", "g",
           gensub(/^### (.*)$/, "        1. \\1", "g",
           gensub(/^\*\* (.*)$/, "    - \\1", "g",
           gensub(/^\*\*\* (.*)$/, "        - \\1", "g",
           gensub(/\|\|/, "|", "g",
           gensub(/^ *\|\|(.*) *$/, "| \\1\n" THEAD, "g", s))))))))))))))))))));
}
/\|\|/ { 
    TABLESIZE = gsub(/\|\|/, "||");
    THEAD="";
    for (i = 0; i < TABLESIZE; i++) {
        THEAD=THEAD "| --- ";
    }
} 
match($0, /^(!![ \t=≈])/, a) {$0=(a[1] jsp2gfm(gensub(".*!![ \t=≈]", "", 1))); }
match($0, /^([^!]+!![ \t=≈])/, a) {$0=(a[1] jsp2gfm(gensub(".*!![ \t=≈]", "", 1))); }
{print;
    if (TABLESIZE>0) {
        print("!! " THEAD);
        TABLESIZE=0;
    }
}
