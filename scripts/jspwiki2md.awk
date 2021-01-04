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
    SOMETHING_WRONG="TRUE";
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
           gensub(/\|\|/, "|", "g",
           gensub(/^ *\|\|(.*) *$/, "| \\1\n" THEAD, "g", s)))))))))))))));
}
/^[[:space:]]*$/ {
    # retaining empty lines of code will greatly help excessive squeezing
    # of subsequent paragraphs
    printf("\n");
}
/\|\|/ { 
    TABLESIZE = gsub(/\|\|/, "||");
    THEAD="";
    for (i = 0; i < TABLESIZE; i++) {
        THEAD=THEAD "| --- ";
    }
}
{
    print(jsp2gfm($0));
}
