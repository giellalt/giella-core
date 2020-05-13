#!/usr/bin/env perl -w

# Script that reads Xerox style cohorts, and prints out only the cohorts that
# matches the following criteria:
#
# 1. contains lemma that equals the input string and with the same POS as the
#    derivation
# 2. contains the derivation specified as one of the input options
#
# The printout only contains the lines matching the above criteria, so that
# irrelevant lines are purged.

# Input:
#
# addin   addi+N+NomAg+Ess
# addin   addi+N+NomAg+Ess
# addin   addi+N+NomAg+Ess
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addi+A+Ess
# addin   addit+V+Der2+Der/NomAg+N+Ess
# addin   addit+V+Der2+Der/NomAg+N+Ess
# addin   addit+V+Der2+Der/NomAg+N+Ess
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
# addin   addit+V+Actio+Gen
# addin   addit+V+Actio+Nom
# 
# addjoheapmi     addjohit+V+Der2+Der/NomAct+N+Sg+Nom
# addjoheapmi     addjohit+V+Der2+Der/NomAct+N+Sg+Nom
# addjoheapmi     addjohit+V+Der2+Der/NomAct+N+Sg+Nom
# addjoheapmi     addjot+V+Der1+Der/h+V+Der2+Der/NomAct+N+Sg+Nom

# Output:
#
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addin+N+Sg+Gen+Allegro
# addin   addin+N+Sg+Nom
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Gen
# addin   addit+V+Der4+Der/NomAct+N+Sg+Nom
