##### RULETEST #####

# Shell scripts for testing a series of XFST rewrite rules
# from the output of LEXC to the surface wordform

# USAGE / INSTRUCTIONS

# 1. Compile mini FSTs for all rewrite rules

# The rules are expected to be found from a GiellaLT style
# phonology.xfscript file, here crk.phonology.xfscript.
# If no phonology file is specified, the script tries to
# access a file named: phonology.xfscript

# You can choose the mini-FSTs to be compiled either
# with the FOMA or HFST compiler, and stored into a
# directory with the compiler name

./compile-rewrite-rules.sh crk.phonology.xfscript foma

# 2. Test individual deep/surface form pairs

# The rules are applied in the sequence found in the
# crk.phonology.xfscript file. If no such file is provided,
# the default expectation is for a file named: phonology.xfscript

# The deep/surface forms pairs should be separated by a tabulator
# and director to standard input. One can choose the flavor
# of FSTs that are applied (default: FOMA or HFST), as well as the
# reporting style (default: short OR diff OR long / full)

echo 'nit2<astotin>i2^DIMs\tnicascocinis' | ./test-rewrite-rules.sh crk.phonology.xfscript diff foma

Found n=23 rewrite rules in "crk.phonology.xfscript"
 0: LEXC                nit2<astotin>i2^DIMs
----------------------|----------------------
14: t2epenthesisRule  + nit<astotin>i2^DIMs
20: DimRule           + nic<ascocin>i2^DIMs
21: deep2surfRule     + nic<ascocin>i^DIMs
23: rmTriggerRule     + nic<ascocin>is
----------------------|----------------------
1: 1-23: nit2<astotin>i2^DIMs -> nicascocinis (=)
   STATS: Correct: 1/1 - Wrong: 0/1 - Missed: 0/1

SUMMARY - SUCCESS: 1/1 - FAIL: 0/1 - PARTIAL: 0/1 - OTHER: 0/1

# One need not provide the surface form, e.g.

echo 'nit2<astotin>i2^DIMs' | ./test-rewrite-rules.sh crk.phonology.xfscript diff foma

Found n=23 rewrite rules in "crk.phonology.xfscript"
 0: LEXC                nit2<astotin>i2^DIMs
----------------------|----------------------
14: t2epenthesisRule  + nit<astotin>i2^DIMs
20: DimRule           + nic<ascocin>i2^DIMs
21: deep2surfRule     + nic<ascocin>i^DIMs
23: rmTriggerRule     + nic<ascocin>is
----------------------|----------------------
1: 1-23: nit2<astotin>i2^DIMs -> nicascocinis (<> ?)

SUMMARY - SUCCESS: 0/1 - FAIL: 0/1 - PARTIAL: 0/1 - OTHER: 1/1

# 3. Testing rewrite rules in batch

# The script can work with a number of deep/surface word-form sets.
# In such a case, aggregate statistics are provided.
# One can use an auxiliary script to extract such deep/surface
# word-form sets, e.g. from the original phonology source.
# In such a case, the example sets should be prefixed by '!!€',
# and should follow immediately each other.

./extract-rule-test-cases.sh crk.phonology.xfscript | ./test-rewrite-rules.sh crk.phonology.xfscript diff foma

Found n=23 rewrite rules in "crk.phonology.xfscript"
 0: LEXC                mêskanaw>i2^DIMs
----------------------|------------------
 1: VGi2VVRule        + mêskanâ>^DIMs
23: rmTriggerRule     + mêskanâ>s
----------------------|------------------
1: 1-23: mêskanaw>i2^DIMs -> mêskanâs (=)
   STATS: Correct: 1/1 - Wrong: 0/1 - Missed: 0/1

 0: LEXC                mêskanaw>i2hk
----------------------|---------------
 1: VGi2VVRule        + mêskanâ>hk
----------------------|---------------
2: 1-23: mêskanaw>i2hk -> mêskanâhk (=)
   STATS: Correct: 1/1 - Wrong: 0/1 - Missed: 0/1

##### END #####

