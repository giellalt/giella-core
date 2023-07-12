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
    * You need to have `lang-xxx` and `corpus-xxx` as a subdirectory of one
      common directory to use these scripts, this is a best common practice in
      GiellaLT infra atm

## Scripts

### Corpus coverages, frequencies, missing lists

Script: `scripts/corpus-stats.bash`

1. uses ccat to create corpus
1. tokenises corpus to `.tokens` file
1. makes a frequency sorted list of tokens
1. analyse frequency sorted list to count naïve coverage
    * Naïve coverage means the proportion of tokens that get any analysis over
      all tokens in %

Example:

```console
$ bash scripts/corpus-stats.bash sme
...
Tokens	Covered	OOV
1124309	1074616	49693
100.0	95.58012966186342	4.41987033813658
Types	Covered	OOV
118163	90872	27291
100.0	76.90393778086204	23.09606221913797
$ head sme.missinglist
560	of
371	and
355	og
182	det
176	to
169	
162	for
135	is
131	av
118	til
```

Copy-pasta this into the article e.g. like so:

```tex
\hline
\bf Language & \bf Words & \bf Coverage % & \bf Types % \bf Coverage \\
\hline
Northern Sámi & 1,124,309 & 95.6~\% & 118,163~\% \\
```

### Lexicon, ruleset sizes

Script: `scripts/language-stats.bash`

1. uses some greps and seds to estimate root morphs in lexc files
1. assumes fairly standard structure of lexc files in `src/fst/stems/*.lexc` and
   `src/fst/generated_files/*.lexc`

```console
bash scripts/language-stats.bash sme
sme
154861 root morphs or similar
56179 shared root morphs (proper nouns, symbols, etc.)
```

Copy-pasta this into the article e.g. like so:

```tex
\hline
\bf Language & \bf Lemmas \\
\hline
Northern Sámi & 154,861$^1$ \
...
\caption{$^1$ excluding proper nouns shared between languages}
```

