# An AWK preprocessor to pull doc comments out of VISL CG3 and similar
# files. 
#
# The doc comments are recognised by sequence of /^#!! /.
#
# The doc comments are assumed to be already in Markdown syntax with
# the following special additions:
# - rule names are recognised and captured
# - section keywords are recognised and captured
# - a doc comment starting with $ or € without space is used to change test
#   settings
BEGIN {
    # Initialise the referable variables
    RULENAME="@OUTSIDE RULES@";
    CODE="@NO CODE@";
    LEXNAME="@NO LEXICON@";
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
/^#!![€$][^ ]/ {
    printf("\n*%s examples:*\n", 
           gensub("#!![€$][^ ]* *", "", 1));
}
/^#!!€ / {
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
/^#!!\$ / {
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
/^#!!¥ / {
    printf("This construct is not supported anymore:\n `{%s`} ", $0);
}
/^[^#].*#!!= / {
    CODE=gensub("#!!=.*", "", 1);
    print(expand_variables(gensub(".*#!!= ", "", 1)));
}
/^[^#].*#!!≈ / {
    CODE=gensub("[ \t][ \t]*", " ", "g",
           gensub("^[ \t]*", "", 1,
           gensub("[ \t]*#!!≈.*", "", 1)));
    print(expand_variables(gensub(".*#!!≈ ", "", 1)));
}
/^#!! / {print(expand_variables(gensub(".*#!! *", "", 1))); }
/^[^#]+#!! / {print(expand_variables(gensub(".*#!! *", "", 1))); }
/^(SETS|SECTIONS|BEFORE-SECTIONS|AFTER-SECTIONS)[ ]*$/ {
    LEXNAME=$2;
}
/^(LIST|SET) / {
    RULENAME=$2;
}
/^(REMOVE|SELECT|ADD|SUBSTITUTE|IFF):/ {
    RULENAME=gensub(":.*", "", 1, $1);
}
function docupath(s) {
    return gensub("\\.\\./", "", "g", s);
}
END {
    printf("\n* * *\n<small>This (part of) documentation was generated from " \
           "[%s](%s/%s)" \
           "</small>", docupath(FILENAME), REPOURL, docupath(FILENAME));
}
