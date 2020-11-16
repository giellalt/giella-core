# An AWK preprocessor to pull doc comments out of Xerox lexc, twolc and VISL CG3
# files. 
#
# The doc comments are recognised by sequence of /^!! /, that is, two comment
# signs at the beginning of a line.
#
# The doc comments are assumed to be already in jspwiki markup with
# following special additions:
# - Multichar_Symbols block is handled specially and its contents are used in
#   output as lists
# - LEXICONs and Rules blocks are handled specially and their names are saved
#   for use in headings that directly follow them with @LEXNAME@ and @RULENAME@
# - a doc comment starting with $ or € and space
#   is used to denote an example, and a test case
# - a doc comment starting with $ or € without space is used to change test
#   settings
BEGIN {
    # Initialise the referable variables
    LEXNAME="@OUTSIDE_LEXICONS@";
    RULENAME="@OUTSIDE RULES@";
    CODE="@NO CODE@";
    SOMETHING_WRONG="TRUE";
    TABLESIZE=0;
    THEAD="|--"
}
function expand_variables(s) {
    # expand all our doc comment variables
    return gensub("@CODE@", CODE, "g", 
              gensub("@RULENAME@", RULENAME, "g",
                     gensub("@LEXNAME@", LEXNAME, "g", s)));
}
function jsp2gfm(s) {
    return gensub(/\[(.*)\|(.*)\]/, "[\\1](\\2)", "g", 
           gensub("__ *([^_]*[^_ ]+) *__", "**\\1**", "g",
           gensub("'' *([^']*[^' ]+) *''", "*\\1*", "g",
           gensub("^ *!", "### ", "1",
           gensub("^ *!!", "## ", "1", 
           gensub("^ *!!!", "# ", "1",
           gensub("{{", "`", "g",
           gensub("}}", "`", "g",
           gensub("{{{", "```", "g",
           gensub("}}}", "```", "g", 
           gensub(/^ *; *(.*[^ ]) *:(.*)$/, "* **\\1**: \\2", "g",
           gensub(/^ *\|([^|].*) *$/, "| \\1", "g",
           gensub(/\|\|/, "|", "g",
           gensub(/^ *\|\|(.*) *$/, "| \\1\n" THEAD, "g", s))))))))))))));
}
/^[[:space:]]*$/ {
    # retaining empty lines of code will greatly help excessive squeezing
    # of subsequent paragraphs
    printf("\n");
}
/^!![€$][^ ]/ {
    printf("\n*%s examples:*\n", 
           gensub("!![€$][^ ]* *", "", 1));
}
/\|\|/ { 
    TABLESIZE = gsub(/\|\|/, "||");
    THEAD="";
    for (i = 0; i < TABLESIZE; i++) {
        THEAD=THEAD "| --- ";
    }
} 
/^!!€ / {
    if (NF >= 4) {
        printf("* *%s* `%s` (Eng.", $2, $3);
        for (i = 4; i <= NF; i++) {
            printf(" %s", $i);
        }
        printf(")\n");
    }
    else if (NF == 3) {
        printf("* *%s* `%s`\n", $2, $3);
    }
    else if (NF == 2) {
        printf("* *%s*\n", $2);
    }
    else {
        print("* ???");
    }
}
/^!!\$ / {
    if (NF >= 4) {
        printf("* ★*%s* `%s` (is not standard language", $2, $3);
        for (i = 4; i <= NF; i++) {
            printf(" %s", $i);
        }
        printf(")\n");
    }
    else if (NF == 3) {
        printf("* ★*%s* `%s` (is not standard language)\n", $2, $3);
    }
    else if (NF == 2) {
        printf("* ★*%s* (is not standard language)\n", $2);
    }
    else {
        print("* ???");
    }
}
/^!!¥ / {
    printf("This construct is not supported anymore:\n `{%s`} ", $0);
}
/^[^!].*!!= / {
    CODE=gensub("!!=.*", "", 1);
    if ($0 ~ /@CODE@/)
    {
        print(jsp2gfm(expand_variables(gensub(".*!!=", "", 1))));
    }
    else
    {
        print(jsp2gfm(expand_variables(gensub("!!=", " ", 1))));
    }
}
/^[^!].*!!≈ / {
    CODE=gensub("  *", " ", "g",
           gensub("^ *", "", 1,
           gensub(" *!!≈.*", "", 1)));
    if ($0 ~ /@CODE@/)
    {
        print(jsp2gfm(expand_variables(gensub(".*!!≈", "", 1))));
    }
    else
    {
        printf("%s ", CODE);
        print(jsp2gfm(expand_variables(gensub("!!≈", " ", 1))));
    }
}
/^!! / {print(jsp2gfm(expand_variables(gensub(".*!! ", "", 1)))); }
/^[^!]+!! / {print(jsp2gfm(expand_variables(gensub(".*!! ", "", 1)))); }
/!!/ {SOMETHING_WRONG="FALSE";}
/^Multichar_Symbols/ {LEXNAME=$1;}
/^LEXICON / {LEXNAME=$2;}
/^"[^"]*"/ {
    RULENAME=gensub("!.*", "", 1, gensub("\"", "", "g"));
}
END {
    if (SOMETHING_WRONG=="TRUE") {
        print("There was no content!");
        exit(1);
    }
}
