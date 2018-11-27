#!/bin/bash

# script that checks if some reading in
# a cohort has a node pointing to itself 
# Ex.:
# "Simmon" N Prop Sem/Mal Sg Acc @<OBJ #12->12
# "lámis" A Sem/Hum Pl Acc @SPRED<OBJ #35->35
# "¶" CLB #1->1

# to run the script:
# sh check_incorrect_node_ids.sh INPUT_FILE

input=$1

grep -E '#([0-9]{1,})->\1$' $1

# which is equivalent to
# egrep '#([0-9]{1,})->\1$' $1

