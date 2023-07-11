# Scripts for evaluation and statistics

These have been used to generate figures for articles and may be used to
generate some statistics for some websites.

## Dependencies

* coreutils, etc. i.e. grep, sed, wc, and such unix tools
* [CorpusTools/ccat](//github.com/giellalt/CorpusTools)
* [libdivvun](//github.com/divvun/libdivvun)
* python + libhfst for python

## Environment

Some scripts depend on proper environment variable setup:

* `$GTHOME` = path to `giella-core`
* `$GTLANG` = parent path of directories like `lang-xxx` and `corpus-xxx`

## Scripts

### Corpus coverages, frequencies, missing lists

Script: `scripts/corpus-stats.bash`

1. uses ccat to create corpus
1. tokenises corpus to `.tokens` file
1. makes a frequency sorted list of tokens
1. analyse frequency sorted list to count naïve coverage
    * Naïve coverage means the proportion of tokens that get any analysis over
      all tokens in %

### Lexicon, ruleset sizes

Script: `scripts/language-stats.bash`

1.
