# GiellaLT unimorph support

There are several scripts in `giella-core/scripts/unimoprh` to support
conversions to and from unimorph data for GiellaLT languages:

* `generate.bash` can take unimorph data and generate giellalt version in same
  order; can be used to send updates to unimorph
* `generate-from-lexicons.bash` takes `stems/*.lexc` files and generates
  unimorph database from all lemmas it finds and can tag somehow
* `yamltests.py` takes unimorph database and generates a yaml test
* `analyseval.py` takes a unimorph database and FSA and measures compatibility
* `convert.py` converts from `hfst-lookup` to unimorph
* `xeroxy.py` converts unimorph to `lookup`
* `excluded.tags` is list of tags that FSA ignores when generating or analysing
  for unimorph, e.g. compounding and derivation

