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
}
function expand_variables(s) {
    # expand all our doc comment variables
    return gensub("@CODE@", CODE, "g", 
              gensub("@RULENAME@", RULENAME, "g",
                     gensub("@LEXNAME@", LEXNAME, "g", s)));
}
/^[[:space:]]*$/ {
    # retaining empty lines of code will greatly help excessive squeezing
    # of subsequent paragraphs
    printf("\n");
}
/^!![€$][^ ]/ {
    printf("(subsequent examples are *%s*)\n", 
           gensub("!![€$][^ ]* *", "", ""));
}
/^!!€ / {
    if (NF >= 4) {
        printf("* __%s__: {{%s}} (Eng.", $2, $3);
        for (i = 4; i <= NF; i++) {
            printf(" %s", $i);
        }
        printf(")\n");
    }
    else if (NF == 3) {
        printf("* __%s__: {{%s}}\n", $2, $3);
    }
    else if (NF == 2) {
        printf("* __%s__\n", $2);
    }
    else {
        print("* ???");
    }
}
/^!!\$ / {
    if (NF >= 4) {
        printf("* __*%s__: {{%s}} (is not standard language", $2, $3);
        for (i = 4; i <= NF; i++) {
            printf(" %s", $i);
        }
        printf(")\n");
    }
    else if (NF == 3) {
        printf("* __*%s__: {{%s}} (is not standard language)\n", $2, $3);
    }
    else if (NF == 2) {
        printf("* __*%s__ (is not standard language)\n", $2);
    }
    else {
        print("* ???");
    }
}
/^!!¥ / {
    printf("; {{%s}}: ", gensub(":$", "", "", $2));
    for (i = 3; i <= NF; i++)
    {
        printf("__%s__ ", gensub("[][]", "", "g", gensub("~", "*", "", $i)));
    }
    printf("\n");
}
/.*!!= / {
    CODE=gensub("!!=.*", "", "");
    if ($0 ~ /@CODE@/)
    {
        print(expand_variables(gensub(".*!!=", "", "")));
    }
    else
    {
        print(expand_variables(gensub("!!=", " ", "")));
    }
}
/.*!!≈ / {
    CODE=gensub("  *", " ", "g",
           gensub("^ *", "", "",
           gensub(" *!!≈.*", "", "")));
    if ($0 ~ /@CODE@/)
    {
        print(expand_variables(gensub(".*!!≈", "", "")));
    }
    else
    {
        printf("%s ", CODE);
        print(expand_variables(gensub("!!≈", " ", "")));
    }
}
/.*!! / {print(expand_variables(gensub(".*!! ", "", ""))); }
/!!/ {SOMETHING_WRONG="FALSE";}
/^LEXICON / {
    LEXNAME=$2;
}
/^"[^"]*"/ {
    RULENAME=gensub("!.*", "", "", gensub("\"", "", "g"));
}
END {
    if (SOMETHING_WRONG=="TRUE") {
        print("There was no content!");
        exit(1);
    }
}
