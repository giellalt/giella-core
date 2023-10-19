# Conversion from giellalt/dict-* to apertium/apertium-*

It is possible to convert a giellalt dictionary to apertium bidix format using
scripts with semi-manual supervision.

## Usage

```console
$ python $GTHOME/giella-core/scripts/giellalt2apes.py \
    -i $GTHOME/dict-fin-nob/src/V_finnob.xml \
    -r $APERTIUM/apertium-fin-nor/apertium-fin-nor.fin-nor.dix \
    -o apertium-fin-nor.new-verbs.dix
```

This will interactively ask for missing words to be added to apertium bidix. The
result will be written to a separate file which should be manually merged to
apertium bidix.
