BEGIN {
    # Parameter: TYPE; set to automaton name/sections to extract, defaults to
    # gt-norm
    if (TYPE=="") {
        TYPE="gt-norm";
    }
    # we need to getline to get filename :-\
    getline
    printf("# yaml test generated from %s with doccomments2yaml.awk\n", 
           FILENAME)
    print("Config:");
    print("  hfst:");
    printf("    Gen: ../../../src/generator-%s.hfst\n", TYPE);
    printf("    Morph: ../../../src/analyser-%s.hfst\n", TYPE);
    print("  xerox:");
    printf("    Gen: ../../../src/generator-%s.xfst\n", TYPE);
    printf("    Morph: ../../../src/analyser-%s.hfst\n", TYPE);
    print("");
    print("Tests:");
    ACTIVETYPE="@NONE@";
    LEXNAME="@BEFORE LEXICON@";
    ALL_OK="NOPE";
}
/^LEXICON / {LEXNAME=$2;}
/^!![€$][^ :]+:/ {
    ACTIVETYPE = gensub("!![€$]", "", "", 
        gensub(":.*", "", ""))
    if (ACTIVETYPE == TYPE) {
        printf("  %s: # %s\n", $2, $3);
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
        print("# Need more tests!");
        exit(1);
    }
}
