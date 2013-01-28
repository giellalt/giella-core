BEGIN {
    # Parameter: TYPE; set to automaton name/sections to extract, defaults to
    # gt-norm
    if (TYPE=="") {
        TYPE="gt-norm";
    }
    # we need to getline to get filename :-\
    getline
    printf("# Yaml test file generated from %s\n", FILENAME)
    print( "# with $GTCORE/scripts/doccomments2yaml.awk\n")
    print( "Config:");
    print( "  hfst:");
    printf("    Gen: ../../../src/generator-%s.hfst\n", TYPE);
    printf("    Morph: ../../../src/analyser-%s.hfst\n", TYPE);
    print( "    App: hfst-lookup");
    print( "  xerox:");
    printf("    Gen: ../../../src/generator-%s.xfst\n", TYPE);
    printf("    Morph: ../../../src/analyser-%s.hfst\n", TYPE);
    print( "    App: lookup");
    print( "");
    print("Tests:");
    ACTIVETYPE="@NONE@";
    LEXNAME="@BEFORE LEXICON@";
    ALL_OK="NOPE";
}
/^!![€$][^ :]+:/ {
    ACTIVETYPE = gensub("!![€$]", "", "", 
        gensub(":.*", "", ""))
    if (ACTIVETYPE == TYPE) {
        printf("  %s: #\n", gensub("!![^:]*:", "", ""));
        ALL_OK="YEAH";
    }
}
/^!!€ / {
    if (ACTIVETYPE == TYPE) {
        printf("    %s: %s # %s\n", $3, $2, $4);
        ALL_OK="YEAH";
    }
}
/^!!\$ / {
    if (ACTIVETYPE == TYPE) {
        printf("    %s: ~%s # %s\n", $3, $2, $4);
        ALL_OK="YEAH";
    }
}
/^!!¥ / {
    if (ACTIVETYPE == TYPE) {
        printf("    %s\n", gensub("!!¥ *", "", ""));
        ALL_OK="YEAH";
    }
}
END {
    if (ALL_OK == "NOPE") {
        printf("# THERE WERE NO TESTS marked with €%s:\n", TYPE);
        exit(1);
    }
}
