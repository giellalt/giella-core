# Special tags and flags for FST

This is a list of flags that are common for all languages in giellalt **and**
have special rules in automake scripts in giella-core. All tags and flags are
also documented in language specific documentation in
<https://giellalt.github.io>. Most of the handling described here is using
automata in `fst-filters/` directory and called from `am-shared/`.

## Use tags

* `+Use/NG` - *no MT / TTS / oahpa*
    * filtered out from some MT automata. some TTS automata and oahpa automata
      but included in all generators and analysers otherwise?
* `+Use/NA` - *no analysis*
    * filtered out from all analysis automata, `src/fst/analyser-*.hfst??`
* `+Use/-Spell` - *no spell checking*
    * filtered out from all spell-checker automata,
      `tools/spellers/*.zhfst`
* `+Use/MT` - *only MT*
    * filtered out of other than machine translation automata, only in
      `tools/mt`
* `+Use/TTS` - only TTS
    * filtered out of non-TTS automata only in `src/fst/*-tts-*.hfst??` and
      `tools/tts/*`
* `+Use/SpellNoSugg` - *no speller suggestions*
    * filtered out from spell-checker suggestions (programmatically), but
      silently accepted if found
* `+Use/-GC` - *no grammar checker*,
    * filtered out of grammar checker automata, e.g. in
      `src/fst/*-gramcheck-*.hfst??` and `tools/grammarchecker/*.pmhfst`
* `+Use/PMatch` - *only tokeniser*
    * used only by tokenisers in `tools/tokenisers/*` (and other tools that use
      tokenisers)



## Err tags

* `+Err/*` - *error forms*
    * filtered from normative automata, e.g. `src/fst/*-gt-norm*.hfst??` and
      `tools/spellcheckers/*.zhfst`
    * Err tags are optional in descriptive generator
    * Err tags may be used by grammatical error correction logics


## Dialect tags

Dialects need to be set up in `configure.ac`

* `Dial/*` - dialect tags
    * may be filtered into dialect specific automata, e.g.
      `src/fst/*-dial_XXX.hfst??` where XXX is an ad hoc dialect code, also
      `tools/spellers/*-x-XXX.zhfst`, etc.

## Area tags

Areas need to be set up in `configure.ac`

* `Area/*` - area tags
    * may be filtered into area-specific automata, e.g. `src/fst/*_XX.hfst??`
      where XX is the standard country code, also `tools/spellers/*-XX.zhfst`
      etc.

## Orth tags

Orthographies need to be setup in `configure.ac`

* `Orth/*` - orthography tags
* `AltOrth/*` - alternative orthography tags

