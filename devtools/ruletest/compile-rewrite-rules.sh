#!/bin/sh

# compile-rewrite-rules.sh 1: XFSCRIPT (path to) 2: FSTTYPE

# Usage:
#   echo /Users/arppe/giella/langs/crk/src/fst/phonology.xfscript foma |

# Print empty line to get to the END statement in the GAWK script.

echo '' |

# Actual GAWK script starts here.

gawk -v XFSCRIPT=$1 -v FSTTYPE=$2 'BEGIN { xfscript=XFSCRIPT; fsttype=FSTTYPE;

# Checking the FSTTYPE argument:
# If no argument value is provided, use "foma" by default.
# If an incorrect value is provided (neither "foma" nor "hfst"), exit
# with a statement on these options.

# if(fsttype!="foma" && fsttype!="hfst" && fsttype!="hfstol")
  if(fsttype!="foma" && fsttype!="hfst")
    {
      if(fsttype=="")
        {
          fsttype="foma";
          print "Setting FST type as \"foma\" by default" > "/dev/stderr";
        }
      else
        {
          # print "Aborting <- specify FST type for phonological rule(s) among the following: 1) foma; 2) hfst; or 3) hfstol";
          print "Aborting <- specify FST type for phonological rule(s) among the following: 1) foma; or 2) hfst";
          exit;
        }
    }

# Read in XFSCRIPT file.
# Identify the final REGEX and the names of its constituent rewrite rules.
# In the case of multiple REGEX statements, in effect only use the last one.
# This presumes a GiellaLT approach to defining morphophonology.

  while((getline < xfscript)!=0)
    { if(index($0,"regex")!=0)
        { rx=1; regex=""; }
      if(rx)
        regex=regex" "$0;
      if(index($0,";")!=0)
        rx=0;
    }
  sub("^[ ]*(read )regex.*\\[[ ]*","",regex);
  sub("[ ]*\\].*;.*$","",regex);
  n=split(regex,rule,"[ ]*\\.o\\.[ ]*");

# Create a new XFSCRIPT command sequence to compile and save all individual rewrite rule FSTs.
# As first XFSCRIPT command, 1) read in (and compile) original XFSCRIPT file as is.

  cmd="-e \"source "xfscript"\"";

# Then 2) clear the stack, 3) push onto stack one-by-one each define rewrite rule FST,
# and 4) save each of these as an FST, with the filename corresponding to the rewrite rule name
# and FSTTYPE.

  for(i=1; i<=n; i++)
     cmd=cmd" -e \"clear stack\" -e \"push "rule[i]"\" -e \"save stack "fsttype"/"rule[i]"."fsttype"\"";
}

# Compile aforementioned XFSCRIPT command sequence, according to either FSTTYPE.
# First create a subdirectory named according to FSTTYPE.

END {
  if(fsttype=="foma")
    {
      system("mkdir foma");
      system("foma "cmd" -e \"quit\"");
    }
  if(fsttype=="hfst" || fsttype=="hfstol")
    {
      system("mkdir hfst");
      system("hfst-xfst "cmd" -e \"quit\"");
    }

# The following conversion works in principle, but the resultant HFSTOL FSTs do not work.

  if(fsttype=="hfstol")
    {
      for(i=1; i<=n; i++)
         {
           hfst="hfst/" rule[i] ".hfst";
           hfstol=fsttype "/" rule[i] ".hfstol";
           system("hfst-fst2fst -O -i " hfst " -o " hfstol ";");
         }
    }
}'

# END #
