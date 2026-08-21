#!/bin/bash
#
# generate-err-testdata.sh
#
# Language-independent tool that generates spellchecker test data
# (typos.tsv format) from lexicalised +Err/-tagged entries in the LEXC
# stem files of the open word classes (nouns, proper nouns, adjectives,
# verbs, adverbs).
#
# All language-specific detail (which LEXC files to scan, which
# generator/analyser to use, which paradigm of tag suffixes to expand
# lexicalised +Err entries into) is supplied by a per-language wrapper
# script, see devtools/generate-err-testdata.sh in each lang-* repo.
#
# Pipeline:
#   1. Collect every LEXC entry that contains a "+Err" tag in one of the
#      given open-class stem files. A lemma can also get a +Err tag
#      indirectly, via an affix/continuation-lexicon file: if a LEXICON
#      block in the affix file contains a +Err entry, every lemma in the
#      stem (or affix) file that continues into that same LEXICON block
#      is also collected, even though the lemma entry itself has no
#      +Err tag.
#   2. Generate all inflected forms of each such entry with the
#      descriptive generator, optionally expanding into a full paradigm
#      of tag suffixes (for word classes given a paradigm file), so that
#      lexicalised Err forms are produced in every wordform, not just
#      the citation form.
#   3. Analyse every generated wordform with the disambiguating analyser,
#      which - unlike the normal analyser - keeps +Err/ tags in its
#      output.
#   4. Keep only wordforms whose analysis contains a +Err/ tag, strip
#      the +Err/ tag(s) from the analysis to get the correct analysis,
#      and generate the corresponding correct wordform(s). If the +Err
#      analysis has a stem variant tag (+v1, +v2, ...), prefer a
#      correction generated with that same variant tag; among the
#      remaining candidates, pick the one with the shortest edit
#      distance to the error wordform.
#   5. Verify every pair against the real spellchecker analyser: the
#      error form must be unrecognised (unknown/misspelled) and the
#      correction must be recognised (a valid word). Lexc's structure
#      means a generated wordform can have both a +Err and a non-+Err
#      analysis at the same time, in which case it is not a genuine
#      error/correction and must be dropped.
#   6. Write out unique (error, correction) pairs in the same three
#      column TAB-separated format used by tools/spellcheckers/test/*.tsv
#
# Usage:
#   generate-err-testdata.sh -g GENERATOR -a DISAMB_ANALYSER -c SPELLERANALYSER -o OUTPUT \
#       -l CLASS=LEXCFILE[:PARADIGMFILE[:POSPREFIX[:AFFIXFILE]]] [-l ...] [-Q MAXSUFFIXES] [-v]
#
# -l can be repeated once per word class. LEXCFILE is required.
# PARADIGMFILE (a file with one tag-suffix per line, e.g.
# src/fst/morphology/test/testnounparadigm.txt) is optional; word
# classes without inflection (typically adverbs) should omit it, and
# then only the literal LEXC analysis is tried.
# POSPREFIX is the leading tag(s) already present in the LEXC analysis
# that should be stripped once before appending a paradigm suffix that
# also starts with that same POS tag (default: "+CLASS", e.g. "+N").
# For proper nouns, where the LEXC analysis already contains "+N+Prop",
# pass POSPREFIX="+N+Prop".
# AFFIXFILE is the continuation-lexicon file for this word class (e.g.
# src/fst/morphology/affixes/nouns.lexc), scanned for LEXICON blocks
# that contain +Err entries; any lemma in LEXCFILE or AFFIXFILE that
# continues into such a LEXICON block is added as a candidate too.

set -eu

self=$(basename "$0")

usage() {
    cat >&2 <<EOF
Usage: $self -g GENERATOR -a DISAMB_ANALYSER -c SPELLERANALYSER -o OUTPUT \\
       -l CLASS=LEXCFILE[:PARADIGMFILE[:POSPREFIX[:AFFIXFILE]]] [-l ...] [-Q MAXSUFFIXES] [-v]

  -g FILE    descriptive generator FST (generator-gt-desc)
  -a FILE    disambiguating analyser FST (analyser-disamb-gt-desc)
  -c FILE    the real spellchecker analyser FST used to verify the
             result (analyser-desktopspeller-gt-norm.hfst), built by
             configuring with speller support enabled and running make
  -o FILE    output typos.tsv-style file
  -l SPEC    CLASS=LEXCFILE[:PARADIGMFILE[:POSPREFIX[:AFFIXFILE]]], repeatable
  -Q N       max number of paradigm suffixes to try per +Err entry (default: all)
  -v         verbose
  -h         show this help
EOF
}

generator=
disamb=
spelleranalyser=
output=
maxsuffixes=0
verbose=false
classes=()
lexcfiles=()
paradigms=()
posprefixes=()
affixfiles=()

while getopts "g:a:c:o:l:Q:vh" opt; do
    case "$opt" in
        g) generator=$OPTARG ;;
        a) disamb=$OPTARG ;;
        c) spelleranalyser=$OPTARG ;;
        o) output=$OPTARG ;;
        Q) maxsuffixes=$OPTARG ;;
        v) verbose=true ;;
        l)
            key=${OPTARG%%=*}
            rest=${OPTARG#*=}
            lexcfile=$(printf '%s' "$rest" | cut -d: -f1)
            paradigm=$(printf '%s' "$rest" | cut -s -d: -f2)
            posprefix=$(printf '%s' "$rest" | cut -s -d: -f3)
            affixfile=$(printf '%s' "$rest" | cut -s -d: -f4)
            if [ -z "$posprefix" ]; then
                posprefix="+$key"
            fi
            classes+=("$key")
            lexcfiles+=("$lexcfile")
            paradigms+=("$paradigm")
            posprefixes+=("$posprefix")
            affixfiles+=("$affixfile")
            ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$generator" ] || [ -z "$disamb" ] || [ -z "$spelleranalyser" ] || [ -z "$output" ] || [ ${#classes[@]} -eq 0 ]; then
    usage
    exit 1
fi
if [ ! -e "$generator" ]; then
    echo "$self: ERROR: generator not found: $generator" >&2
    exit 1
fi
if [ ! -e "$disamb" ]; then
    echo "$self: ERROR: disamb analyser not found: $disamb" >&2
    exit 1
fi
if [ ! -e "$spelleranalyser" ]; then
    echo "$self: ERROR: spellchecker analyser not found: $spelleranalyser" >&2
    echo "$self: the build tree must be configured with speller support enabled (e.g. configure --enable-spellers) and built with make first" >&2
    exit 1
fi
if ! command -v hfst-lookup >/dev/null 2>&1; then
    echo "$self: ERROR: hfst-lookup not found in PATH" >&2
    exit 1
fi
if ! command -v gawk >/dev/null 2>&1; then
    echo "$self: ERROR: gawk not found in PATH (needed for UTF-8-safe edit distance)" >&2
    exit 1
fi

vecho() {
    if [ "$verbose" = true ]; then
        echo "$self: $*" >&2
    fi
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

candidates_file="$tmpdir/candidates.txt"
: > "$candidates_file"

# Scan a LEXC file and emit, one per line, TAB-separated records:
#   ANALYSIS<TAB>analysis           - analysis contains a +Err tag
#   ERRLEX<TAB>lexiconname          - the enclosing LEXICON block of a
#                                     +Err entry (relevant in affix files)
#   CONTLEX<TAB>analysis<TAB>contlex - every entry's analysis and the
#                                     continuation lexicon it points to
# Lexc escapes (%!, %:, %<, % , %") are unescaped in the analysis field.
scan_lexc() {
    awk '
    {
        line = $0
        if (line ~ /^[ \t]*LEXICON[ \t]+/) {
            lex = line
            sub(/^[ \t]*LEXICON[ \t]+/, "", lex)
            sub(/[ \t!].*$/, "", lex)
            cur = lex
            next
        }
        if (line ~ /^[ \t]*!/) next
        gsub(/%!/, "\001EXCL\001", line)
        gsub(/%:/, "\001COLON\001", line)
        gsub(/%</, "\001LT\001", line)
        gsub(/% /, "\001SPACE\001", line)
        gsub(/%"/, "\001QUOT\001", line)
        sub(/!.*$/, "", line)
        if (line !~ /;/) next
        sub(/;.*/, "", line)
        gsub(/^[ \t]+/, "", line)
        gsub(/[ \t]+$/, "", line)
        if (line == "") next
        if (index(line, ":") > 0) {
            analysis = substr(line, 1, index(line, ":") - 1)
            rest = substr(line, index(line, ":") + 1)
            n = split(rest, parts, /[ \t]+/)
            contlex = (n >= 2) ? parts[2] : ""
        } else {
            n = split(line, parts, /[ \t]+/)
            analysis = parts[1]
            contlex = (n >= 2) ? parts[2] : ""
        }
        gsub(/\001EXCL\001/, "!", analysis)
        gsub(/\001COLON\001/, ":", analysis)
        gsub(/\001LT\001/, "<", analysis)
        gsub(/\001SPACE\001/, " ", analysis)
        gsub(/\001QUOT\001/, "\"", analysis)
        if (analysis == "") next
        if (analysis ~ /\+Err/) {
            print "ANALYSIS\t" analysis
            if (cur != "") print "ERRLEX\t" cur
        }
        if (contlex != "") print "CONTLEX\t" analysis "\t" contlex
    }
    ' "$1"
}

for i in "${!classes[@]}"; do
    class=${classes[$i]}
    lexcfile=${lexcfiles[$i]}
    paradigm=${paradigms[$i]}
    posprefix=${posprefixes[$i]}
    affixfile=${affixfiles[$i]}

    if [ ! -f "$lexcfile" ]; then
        echo "$self: WARNING: lexc file not found, skipping: $lexcfile" >&2
        continue
    fi

    scanfile="$tmpdir/scan-$class.txt"
    scan_lexc "$lexcfile" > "$scanfile"
    if [ -n "$affixfile" ] && [ -f "$affixfile" ]; then
        scan_lexc "$affixfile" >> "$scanfile"
    elif [ -n "$affixfile" ]; then
        echo "$self: WARNING: affix file not found, skipping: $affixfile" >&2
    fi

    errfile="$tmpdir/err-$class.txt"
    # Direct hits: lemmas whose own analysis contains a +Err tag.
    awk -F'\t' '$1 == "ANALYSIS" {print $2}' "$scanfile" > "$errfile"
    # Indirect hits: lemmas that continue into a LEXICON block (in the
    # affix file) that itself contains a +Err entry somewhere.
    errlexfile="$tmpdir/errlex-$class.txt"
    awk -F'\t' '$1 == "ERRLEX" {print $2}' "$scanfile" | sort -u > "$errlexfile"
    if [ -s "$errlexfile" ]; then
        awk -F'\t' '
            NR == FNR { errlex[$1] = 1; next }
            $1 == "CONTLEX" && ($3 in errlex) { print $2 }
        ' "$errlexfile" "$scanfile" >> "$errfile"
    fi
    sort -u "$errfile" -o "$errfile"
    vecho "$class: $(wc -l < "$errfile" | tr -d ' ') +Err entries found (directly or via affixes) in $lexcfile${affixfile:+ and $affixfile}"

    # candidate 0: the literal LEXC analysis, in case it is already a
    # complete, generatable wordform on its own.
    cat "$errfile" >> "$candidates_file"

    if [ -n "$paradigm" ] && [ -f "$paradigm" ]; then
        suffixfile="$tmpdir/suffixes-$class.txt"
        sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e '/^$/d' "$paradigm" | sort -u > "$suffixfile"
        if [ "$maxsuffixes" -gt 0 ] 2>/dev/null; then
            head -n "$maxsuffixes" "$suffixfile" > "$suffixfile.tmp" && mv "$suffixfile.tmp" "$suffixfile"
        fi
        vecho "$class: $(wc -l < "$suffixfile" | tr -d ' ') paradigm suffixes from $paradigm"

        # cross product: analysis+suffix, and (if the analysis's POS tag
        # is already present at the head of the suffix) analysis+suffix
        # with that redundant leading POS tag stripped off.
        awk -v posprefix="$posprefix" '
            NR == FNR { analyses[++na] = $0; next }
            {
                suf = $0
                for (j = 1; j <= na; j++) {
                    print analyses[j] suf
                    if (index(suf, posprefix) == 1) {
                        stripped = substr(suf, length(posprefix) + 1)
                        if (stripped != "" && stripped != suf) {
                            print analyses[j] stripped
                        }
                    }
                }
            }
        ' "$errfile" "$suffixfile" >> "$candidates_file"
    fi
done

sort -u "$candidates_file" -o "$candidates_file"
vecho "$(wc -l < "$candidates_file" | tr -d ' ') candidate analyses to generate"

if [ ! -s "$candidates_file" ]; then
    echo "$self: no +Err entries found, nothing to do" >&2
    exit 0
fi

# Generate wordforms for every candidate analysis; keep only the ones
# the generator could actually produce.
generated_file="$tmpdir/generated-surfaces.txt"
hfst-lookup -q "$generator" < "$candidates_file" \
    | awk -F'\t' '$2 != "" && $2 !~ /\+\?/ {print $2}' \
    | sort -u > "$generated_file"
vecho "$(wc -l < "$generated_file" | tr -d ' ') wordforms generated"

# Analyse every generated wordform with the disambiguating analyser,
# and keep only the best (lowest-weight) analysis per wordform that
# still contains a +Err/ tag - a wordform can be genuinely ambiguous,
# but we only want one error/correction pair per generated error form.
err_hits_file="$tmpdir/err-hits.txt"
hfst-lookup -q "$disamb" < "$generated_file" \
    | awk -F'\t' '
        $2 ~ /\+Err\// {
            w = $3 + 0
            if (!($1 in bestw) || w < bestw[$1]) {
                bestw[$1] = w
                best[$1] = $2
            }
        }
        END { for (k in best) print k "\t" best[k] }
    ' | sort -u > "$err_hits_file"
vecho "$(wc -l < "$err_hits_file" | tr -d ' ') generated wordforms analysed with a +Err/ tag"

# For every +Err analysis, compute the corrected analysis (with the
# +Err/ tag(s) removed), and also a variant-neutral version of it with
# any stem variant tag (+v1, +v2, ...) removed too, as a fallback key.
corrected_analyses_file="$tmpdir/corrected-analyses.txt"
awk -F'\t' '
    {
        corrected = $2
        gsub(/\+Err\/[^+]*/, "", corrected)
        print corrected
        novariant = corrected
        gsub(/\+v[0-9]+/, "", novariant)
        if (novariant != corrected) print novariant
    }
' "$err_hits_file" | sort -u > "$corrected_analyses_file"

# Generate every surface the generator produces for each corrected
# analysis - keep ALL of them (not just one), since the final choice
# among them depends on the specific error wordform they are paired
# with below.
corrected_gen_file="$tmpdir/corrected-gen.txt"
hfst-lookup -q "$generator" < "$corrected_analyses_file" \
    | awk -F'\t' '$2 != "" && $2 !~ /\+\?/ {print $1 "\t" $2}' \
    | sort -u > "$corrected_gen_file"

# Join err-hits with EVERY corrected wordform candidate (not just one),
# ranked by preference: a candidate generated from the corrected
# analysis that still carries the same stem variant tag (+v1, +v2, ...)
# as the +Err analysis is preferred; among the rest, shorter (UTF-8
# character-based) edit distance to the error wordform is preferred.
# We cannot commit to a single "best" candidate yet: LEXC's structure
# means the +Err stem and the correct stem can collapse to the very
# same tag-stripped analysis (they share a continuation lexicon), so
# the generator may return both the (still wrong) +Err-derived surface
# and the genuinely correct one for that analysis - only the speller
# verification step below can tell them apart.
ranked_file="$tmpdir/ranked-candidates.txt"
gawk -F'\t' '
    function levenshtein(a, b,    la, lb, i, j, cost, d, prev, cur) {
        la = length(a)
        lb = length(b)
        for (j = 0; j <= lb; j++) prev[j] = j
        for (i = 1; i <= la; i++) {
            cur[0] = i
            for (j = 1; j <= lb; j++) {
                cost = (substr(a, i, 1) == substr(b, j, 1)) ? 0 : 1
                d = prev[j - 1] + cost
                if (prev[j] + 1 < d) d = prev[j] + 1
                if (cur[j - 1] + 1 < d) d = cur[j - 1] + 1
                cur[j] = d
            }
            for (j = 0; j <= lb; j++) prev[j] = cur[j]
        }
        return prev[lb]
    }
    NR == FNR {
        candidates[$1] = (candidates[$1] == "") ? $2 : candidates[$1] "\x01" $2
        next
    }
    {
        err_surface = $1
        analysis = $2
        corrected = analysis
        gsub(/\+Err\/[^+]*/, "", corrected)
        has_variant = match(corrected, /\+v[0-9]+/)
        novariant = corrected
        gsub(/\+v[0-9]+/, "", novariant)

        delete seen_cand
        pools = has_variant ? corrected "\x02" novariant : corrected
        m = split(pools, poolkeys, "\x02")
        for (p = 1; p <= m; p++) {
            key = poolkeys[p]
            if (!(key in candidates)) continue
            variant_rank = (has_variant && key == corrected) ? 0 : 1
            n = split(candidates[key], arr, "\x01")
            for (i = 1; i <= n; i++) {
                cand = arr[i]
                if (cand == err_surface) continue
                if (cand in seen_cand) continue
                seen_cand[cand] = 1
                dist = levenshtein(err_surface, cand)
                print err_surface "\t" cand "\t" analysis "\t" variant_rank "\t" dist
            }
        }
    }
' "$corrected_gen_file" "$err_hits_file" \
    | sort -t "$(printf '\t')" -k1,1 -k4,4n -k5,5n -k2,2 > "$ranked_file"
vecho "$(cut -f1 "$ranked_file" | sort -u | wc -l | tr -d ' ') error wordforms have at least one correction candidate"

# Verify every candidate pair against the real spellchecker analyser:
# the error form must be unrecognised there (it was removed from the
# speller lexicon), and the correction must be recognised. LEXC's
# structure means a generated wordform can have both a +Err and a
# non-+Err analysis at the same time, making it a real word after all -
# such error forms must be dropped; likewise a corrected candidate that
# the speller does not recognise (e.g. it was in fact derived from the
# wrong, +Err, stem) must be dropped in favour of the next-best one.
pair_errs_file="$tmpdir/pair-errs.txt"
pair_corrs_file="$tmpdir/pair-corrs.txt"
cut -f1 "$ranked_file" | sort -u > "$pair_errs_file"
cut -f2 "$ranked_file" | sort -u > "$pair_corrs_file"

unknown_errs_file="$tmpdir/unknown-errs.txt"
hfst-lookup -q "$spelleranalyser" < "$pair_errs_file" \
    | awk -F'\t' '$2 == "" || $2 ~ /\+\?/ {print $1}' \
    | sort -u > "$unknown_errs_file"

known_corrs_file="$tmpdir/known-corrs.txt"
hfst-lookup -q "$spelleranalyser" < "$pair_corrs_file" \
    | awk -F'\t' '$2 != "" && $2 !~ /\+\?/ {print $1}' \
    | sort -u > "$known_corrs_file"

# Keep candidates that pass verification, then - since ranked_file is
# already sorted best-first within each error wordform's group - take
# the first surviving candidate per error wordform.
verified_pairs_file="$tmpdir/verified-pairs.txt"
gawk -F'\t' '
    FNR == NR { unknown_err[$0] = 1; next }
    ARGIND == 2 { known_corr[$0] = 1; next }
    ($1 in unknown_err) && ($2 in known_corr) && !(seen[$1]++) {
        print $1 "\t" $2 "\t# " $3
    }
' "$unknown_errs_file" "$known_corrs_file" "$ranked_file" > "$verified_pairs_file"
vecho "$(wc -l < "$verified_pairs_file" | tr -d ' ') error/correction pairs left after speller verification"

{
    cat <<EOF
# This file is machine-generated by giella-core/devtools/generate-err-testdata.sh
# It contains word forms generated from lexicalised +Err/-tagged LEXC
# entries, paired with their corresponding correct word forms.
#
# The format is three columns, separated by TAB:
#
# Column 1: error word/typo
# Column 2: correction
# Column 3: Comment, starting with # or !
#
# Please review the generated data before using it, and move any lines
# that need hand-editing to a manually maintained typos file instead.
#
EOF
    awk -F'\t' '!seen[$1"\t"$2]++' "$verified_pairs_file"
} > "$output"

pair_count=$(awk -F'\t' '!seen[$1"\t"$2]++' "$verified_pairs_file" | wc -l | tr -d ' ')
echo "$self: wrote $pair_count error/correction pairs to $output"
