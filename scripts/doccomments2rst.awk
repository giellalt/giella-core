/^[[:space:]]*$/ {printf("\n");}
/^!! €/ {
    printf("\n- **%s**: ``%s`` (%s)\n\n", $3, $4, $5);
}
/^!! \$/ {
    printf("\n- \\**%s* (is not standard language)\n\n", $3);
}
/^!! [^$€]/ {print(gensub("!! ?", "", 1)); }
/^LEXICON / {
    print($2);
    print(gensub(".", "-", "g", $2)); 
}
