# A simple script to take output from divvun-suggest, and return close to plain
# text. Used with other tools to convert text in one variant of a language to
# another variant of the same language, as in SMJ following NO conventions, to
# SMJ following SE conventions = smj_NO => smj_SE.
BEGIN { already_outputted = 0; }
NF == 2 && $2 == "?" && $1 ~ /\+\?/ {
    if (already_outputted == 0) {
        print(gensub(/\+\?/, "", 1, $1)); 
        already_outputted = -1;
    }
} 
NF == 2 && $2 ~ /.,./ {
    if (already_outputted == 0) {
        len = split($2, vars, /,/)
        for (i = 1; i <= len; i++) {
            if (vars[i] == $1) {
                print($v);
                already_outputted = -1;
                break;
            }
        }
        print(vars[1]);
        already_outputted = -1;
    }
}
NF == 2 && $2 != "?" && $2 !~ /.,./ && $1 !~ /^".*"$/ { 
    if (already_outputted == 0) { 
        print(gensub(/^:/, "@COLON@", 1, $2));
        already_outputted = -1;
    }
}
/^:/ && NF == 1 {print; already_outputted =  0; }
/^"/ {already_outputted = 0;}
