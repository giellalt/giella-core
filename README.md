# giella-core

Build tools and build support files as well as developer support tools for the
GiellaLT repositories.

This repo is required by all other GiellaLT repos, and will be cloned
automatically wheen running `./autogen.sh` in a `lang` repo for the first time.

Some further documentation can be found on [the project
site](https://giellalt.github.io/giella-core).

## Requirements

* `uconv` from ICU, used to convert unicodes in builds
    * on Debian / ubuntu `apt install icu-devtools`
    * on Mac OS X homebrew `brew install icu4c`
* HFST
