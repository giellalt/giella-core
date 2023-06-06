#!/bin/sh

# Usage:
#    ./extract-rule-test-cases.sh 1:PATH-TO-phonology.xfscript 2:MARKER

# Example:
# ./extract-rule-test-cases.sh phonology.xfscript '!!€' | ./rewrite-rule-test.sh phonology.xfscript short hfst | less

# cat $1 |

gawk -v PHONOLOGY=$1 -v MARKER=$2 'BEGIN { marker=MARKER; phonology=PHONOLOGY;
  if(phonology=="")
    phonology="phonology.xfscript";
       "if [ -f \"" phonology "\" ]\nthen\n echo 1\nelse\necho 0\nfi" | getline exit_status;
       if(exit_status!=1)
         {
           printf "Aborting - Missing phonology file: %s\n", phonology;
           exit 1;
         }

  if(marker=="")
    marker="!!€";

  while((getline < phonology)!=0)
    {
      if($1==marker && test!="")
        test=test "\t" $2;
      if($1==marker && test=="")
        test=$2;
      if($1!=marker && test!="")
        {
          print test;
          test="";
        }
    }
  if(test!="")
    print test;
}'
