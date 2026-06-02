# Ensure a Markdown file's leading YAML front matter contains `generated: true`,
# preserving every key it already has. If there's no front matter, a minimal
# block is synthesised. If `generated:` is already set, its value is left as-is
# (no duplicate key). Body content is passed through untouched.
#
# Used by am-shared/docs-dir-include.am to mark generated doc pages so the
# Jekyll theme (jekyll-theme-giellalt) suppresses their "Edit on GitHub" link.
NR==1 && $0=="---" { infm=1; print; next }            # keep an existing opening fence
NR==1 {                                               # no front matter: synthesise, then emit body
    print "---"; print "generated: true"; print "---"; print "";
    print; next
}
infm && /^[[:space:]]*generated[[:space:]]*:/ { seen=1 }
infm && $0=="---" {                                   # closing fence
    if (!seen) print "generated: true";
    infm=0; print; next
}
{ print }
END { if (NR==0) { print "---"; print "generated: true"; print "---" } }   # empty input
