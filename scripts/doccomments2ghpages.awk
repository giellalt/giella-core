# An AWK preprocessor to pull doc comments out of Xerox lexc, twolc and VISL CG3
# files. 
#
# The doc comments are recognised by sequence of /^!! /, that is, two comment
# signs at the beginning of a line.
#
# The doc comments are assumed to be already in Markdown syntax with
# the following special additions:
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
    LEXNAME="`OUTSIDE_LEXICONS`";
    RULENAME="`OUTSIDE RULES`";
    CODE="`NO CODE`";
    LEXEME="`NO LEMMA`";
    LEMMA="`NO LEMMA`";
    STEM="`NO STEM'";
    CONTLEX="`NO CONTLEX`";
}
function expand_variables(s) {
    # expand all our doc comment variables
    return gensub("@CODE@", CODE, "g", 
              gensub("@LEXEME@", LEXEME, "g",
              gensub("@LEMMA@", LEMMA, "g",
              gensub("@STEM@", STEM, "g",
              gensub("@CONTLEX@", CONTLEX, "g",
              gensub("@RULENAME@", RULENAME, "g",
                 gensub("@LEXNAME@", LEXNAME, "g", s)))))));
}
/^[[:space:]]*$/ {
    # retaining empty lines of code will greatly help excessive squeezing
    # of subsequent paragraphs
    printf("\n");
}
/^!![€$][^ ]/ {
    printf("\n* %s examples:*\n", 
           gensub("!![€$][^ ]* *", "", 1));
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
/^[^!]*;/ {
    if ($1 ~ /:/) 
    {
        LEXEME=gensub(":.*", "", 1, $1);
        LEMMA=gensub("^([^+]*).*", "\\1", 1, gensub(":.*", "", 1, $1));
        STEM=gensub("^.*:", "", 1, $1);
        CONTLEX=$2
    }
    else
    {
        STEM=$1;
        LEXEME=$1;
        LEMMA=$1;
        CONTLEX=$2;
    }
}

/^[^!].*!!= / {
    CODE=gensub("!!=.*", "", 1);
    print(expand_variables(gensub(".*!!= ", "", 1)));
}
/^[^!].*!!≈ / {
    CODE=gensub("[ \t][ \t]*", " ", "g",
           gensub("^[ \t]*", "", 1,
           gensub("[ \t]*!!≈.*", "", 1)));
    print(expand_variables(gensub(".*!!≈ ", "", 1)));
}
/^!! / {print(expand_variables(gensub(".*!! *", "", 1))); }
/^[^!]+!! / {print(expand_variables(gensub(".*!! *", "", 1))); }
/^Multichar_Symbols/ {LEXNAME=$1;}
/^LEXICON / {LEXNAME=$2;}
/^"[^"]*"/ {
    RULENAME=gensub("!.*", "", 1, gensub("\"", "", "g"));
}
function docupath(s) {
    return gensub("\\.\\./", "", "g", s);
}
END {
    printf("\n* * *\n\n<small>This (part of) documentation was generated from " \
           "[%s](%s/%s)" \
           "</small>\n", docupath(FILENAME), REPOURL, docupath(FILENAME));
}
