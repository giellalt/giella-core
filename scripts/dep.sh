#!/bin/bash

usage() {
  cat << EOF
Usage: dep.sh [-l lang] [-t] sentence
Tokenizes, analyses, disabiguates and gives dependency analysis to a sentence.

Options:
  -l lang   The language code of the input sentence (required)
  -t        Show trace when running disambiguation (optional)
  -h        Show this help message
EOF
}

# Parse command line arguments
while getopts ":l:th" opt; do
  case $opt in
    l)
      lang=$OPTARG
      ;;
    t)
      trace=true
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ -z "$lang" ]; then
  echo "Error: language code is required (-l)" >&2
  exit 1
fi

# Tokenize and disambiguate sentence
# Tokenize and disambiguate sentence
if [ -t 0 ]; then
  # Read from argument
  sentence="$@"
else
  # Read from standard input
  sentence=$(cat)
fi

if [ "$trace" = true ]; then
  echo "$sentence" | hfst-tokenise -cg "$GTLANGS/lang-$lang/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/disambiguator.cg3" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/functions.cg3" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/dependency.cg3" -t
else
  echo "$sentence" | hfst-tokenise -cg "$GTLANGS/lang-$lang/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/disambiguator.cg3" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/functions.cg3" \
    | vislcg3 -g "$GTLANGS/lang-$lang/src/cg3/dependency.cg3" 
fi
