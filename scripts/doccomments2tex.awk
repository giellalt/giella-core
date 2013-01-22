BEGIN { 
    LEXICONLEVEL="textbf"; # set to desired TeX for LEXICON autoheadings 
}
/^[[:space:]]*$/ {printf("\n");}
/^!! €/ {
    printf("\\emph{%s} \\texttt{%s} (%s), ", $3, $4, $5);
}
/^!! \$/ {
    printf("$^\\star$%s", $3);
}
/^!! [^$€]/ {print(gensub("!! ?", "", "")); }
/^LEXICON / {printf("\n\\%s{%s}: ", LEXICONLEVEL, $2);
}
