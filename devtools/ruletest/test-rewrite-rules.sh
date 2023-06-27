#!/bin/sh

# test-rewrite-rules.sh 1: XFSCRIPT rule file (path) 2: REPORT 3: FSTTYPE

# Example:
#
# echo 'nitáni2t>k>wa\tnitánikka' | ./test-rewrite-rules.sh phonology.xfscript diff foma | less
# ./extract-rule-test-cases.sh phonology.xfscript| ./test-rewrite-rules.sh phonology.xfscript diff foma | less


# LEXC forms from standard input, so multiple words can be processed
# Input must have one LEXC form per line to be processed,
# as well as an optional second space-separated form representing the
# final outcome.

gawk -v XFSCRIPT=$1 -v REPORT=$2 -v FSTTYPE=$3 'BEGIN { xfscript=XFSCRIPT;
report=REPORT; fsttype=FSTTYPE; FS="\t";

# Checking REPORT argument:
# If no REPORT argument provided, revert to "short" form of report.
# If argument provided but does not match supported ones ("long"/"full", "diff",
# or "short"), exit.

  if(report=="full")
    report="long";

  if(report=="")
    print "Setting REPORT type as \"short\" by default" > "/dev/stderr";

  if(report!="long" && report!="diff" && report!="short" && report!="")
    {
      print "Exiting <- specify REPORT type among the following: 1) long / full; 2) diff; or 3) short";
      exit;
    }

# Checking FSTTYPE argument:
# If no FSTTYPE argument provided, use "foma".
# If argument provided but does not match supported ones ("foma" and "hfst"), exit.

#   if(fsttype!="foma" && fsttype!="hfst" && fsttype!="hfstol")
  if(fsttype!="foma" && fsttype!="hfst")
    {
      if(fsttype=="")
        {
          fsttype="foma";
          print "Setting FST type as \"foma\" by default" > "/dev/stderr";
        }
      else
        {
#          print "Exiting <- specify FST type for phonological rule(s) among the following: 1) foma; 2) hfst; or 3) hfstol";
          print "Exiting <- specify FST type for phonological rule(s) among the following: 1) foma; or 2) hfst";
          exit;
        }
    }

# Scan XFSCRIPT for REGEX specification. If multiple REGEX specs, use the final one.

  while((getline < xfscript)!=0)
  {
    sub("[ \t]*!.*$","",$0);
    if(index($0,"regex")!=0)
      { rx=1; regex=""; }
    if(rx)
      regex=regex" "$0;
    if(index($0,";")!=0)
      rx=0;
  }

# Turn REGEX into a dynamic array with rule-names.
# Figure out the longest rule-name (for later print formatting).

  sub("^[ \t]*(read )?regex.*\\[[ ]*", "", regex);
  sub("[ ]*\\].*;.*$", "", regex);
  n=split(regex,rule,"[ ]*\\.o\\.[ ]*");
  for(i=1; i<=n; i++)
     if(length(rule[i])>maxrulelen)
       maxrulelen=length(rule[i]);
  maxixlen=length(n);

# Check that for each rule in XFSCRIPT a matching FST (according to FSTTYPE format) exists
# in the appropriate subdirectory (foma/ or hfst/).
# If not, exit and list missing FSTs.
 
  for(i=1; i<=n; i++)
     {
       fst=fsttype "/" rule[i] "." fsttype;
       "if [ -f \"" fst "\" ]\nthen\n echo 1\nelse\necho 0\nfi" | getline exit_status;
       if(exit_status!=1)
         missing_fst=missing_fst fst " ";
     }
  if(missing_fst!="")
    {
      printf "Aborting <- FST(s) (in %s format) for rules is/are missing in: %s/\n %s\n", toupper(fsttype), fsttype, missing_fst;
      exit;
    }
}

# Go through input of underlying forms (from LEXC source) and associated one or more target forms.
# Assign target form(s) to a dynamic array.

{
  input=$1; lexc=$1; delete target; ntarget=0;
  gsub("0","",input);
  if(NF>=2)
    for(i=2; i<=NF; i++)
       if($i!="")
         {
           gsub("0","",$i);
           target[$i]=$i;
           ntarget++;
         }

# Write out rewrite rule sequence for reference.

  gsub("\\.o\\.","->",regex);
  if(report=="long" || report=="diff")
    {
# Commented out the duplicate printing of entire rule set, as that is anyhow shown in the rule-by-rule scrutiny
#      print "REWRITE RULE SEQUENCE:";
#      print regex;
#      print "";
      printf "%"maxixlen"i: %-"maxrulelen"s    %s\n", 0, "LEXC", input;
      s=sprintf("%"maxixlen+maxrulelen+4"s|%"length(input)+2"s", "", ""); gsub(" ","-",s); printf "%s\n", s;
    }

# Pass source word-form through in sequence through each FST corresponding to a rewrite rule.

  for(i=1; i<=n; i++)
     {

# Specify alternative lookup commands and FST names.

       flookup_cmd="flookup -b -i"; fomabin=fsttype "/" rule[i] ".foma";
       hfst_lookup_cmd="hfst-lookup -q"; hfst=fsttype "/" rule[i] ".hfst";
       hfstol_lookup_cmd="hfst-optimized-lookup -q"; hfstol=fsttype "/" rule[i] ".hfstol";

       if(fsttype=="foma")
         { lookup_cmd=flookup_cmd; rulefst=fomabin; }
       if(fsttype=="hfst")
         { lookup_cmd=hfst_lookup_cmd; rulefst=hfst; }
       # HFSTOL FSTs can be created, but look-ups do not work currently
       if(fsttype=="hfstol")
         { lookup_cmd=hfstol_lookup_cmd; rulefst=hfstol; }

# Reset variables concerning output forms.
# If multiple input forms, split these to a dynamic array.
# This may arise from some FST outputting more than one possible form.

       output=""; delete diff; ndiff=0; anydiff=0;
       ninput=split(input, input2, "\n");

# Process each input form at a time, through the appropriate FST..
# Concatenate all output forms into a single variable.

       for(j=1; j<=ninput; j++)
          {
            fst_result=lookup(lookup_cmd, rulefst, input2[j]);
            output=output sprintf("%s\n", fst_result);

# For each input form, Process each output form one at a time,
# comparing each against their original input form.
# This is repeated for each input form.
# The "anydiff" variable indicates that the rule in question
# fired at least for one of the input/output pairings.

            noutput=split(fst_result, output2, "\n");
            for(k=1; k<=noutput; k++)
               {
                 if(input2[j]==output2[k])
                   d="|";
                 else
                   {
                     d="+";
                     anydiff=1;                     
                   }
                 diff[++ndiff]=d;
               }
          }
       sub("\n$","",output);

# Assign all output forms (at this step) as input forms for next step.

       input=output;

# Depending on report type, print out rule name for the step in question and all
# produced output forms, indicating whether they represent a change wrt their
# corresponding input form.
# If "full" or "long" REPORT format is selected, print all steps
# If "diff" REPORT format is selected, print only steps for which the output form
# differs from the corresponding input form.
# If no or "short" REPORT format is selected, show only the original input and
# final outcome forms, and their analysis.

       noutput=split(output, output2, "\n");
       if(report=="long" || (report=="diff" && anydiff))
         {
           printf "%"maxixlen"i: %-"maxrulelen"s ", i, rule[i];
           for(k=1; k<=noutput; k++)
              printf " %s %s", diff[k], output2[k];
           printf "\n";
         }
     }

# Print delimiter only in the case of "long" or "diff" REPORT formats.

  if(report=="long" || report=="diff")
    { 
      s=sprintf("%"maxixlen+maxrulelen+4"s|%"length(lexc)+2"s", "", "");
      gsub(" ","-",s); printf "%s\n", s;
    }

# Calculate the various case-specific statistics, which will be aggregated
# into the overall statistics.

# Set finally output form(s) as the final outcome(s).
# Remove any morpheme boundary markers from these outcome.

  outcome=output;
  gsub("\n", "\t", outcome);
  gsub("[<>]", "", outcome);
  noutcome=split(outcome, outcome2, "\t");

# Calculate the number of, and identify the finally outfput forms that DID match
# the originally provided target form(s).

  delete success; nlocsuccess=0;
  for(i=1; i<=noutcome; i++)
     {
       if(outcome2[i] in target)
         {
           success[i]="(=)";
           nlocsuccess++;
           target[outcome2[i]]="";
         }
       else
         if(noutcome==1 && ntarget==1)
           success[i]="(<> " outcome2[i] ")";
         else
           success[i]="(<> ?)";
     }

# Print finally output forms that did match the initially provided target form(s).

  printf "%i: 1-%i: %s ->", NR, n, lexc; 
  for(i=1; i<=noutcome; i++)
     {
       if(noutcome>=2 && i<noutcome)
         sep=" /";
       else
         sep="";
       printf " %s %s%s", outcome2[i], success[i], sep;
     }

# Deduce how many, and which, target forms were not output in the end,
# and print these missed forms.

  nlocmiss=0;
  for(t in target)
     if(target[t]!="")
       {
         nlocmiss++;
         printf " | -/-> %s", t;
       }
  printf "\n";

# Interpret case-specific results as part of the overall summary statistics.

  if(ntarget>0)
    if(nlocsuccess==noutcome && nlocmiss==0)
      n_success++;
    else
      if(nlocsuccess>0)
        n_mixed++;
      else
        n_fail++;
  else
    n_other++;

# Printing case-specific performance stats, if one or more target word-forms have been provided.
# 1. Correct: number of final output forms that match the target forms.
# 2. Wrong: number of final output forms that do NOT match any of the target form().
# 3. Missed: number of target forms that were not among the output forms.

if(ntarget>0)
  printf "%"length(NR)+1"s STATS: Correct: %i/%i - Wrong: %i/%i - Missed: %i/%i\n", "", nlocsuccess, noutcome, noutcome-nlocsuccess, noutcome, nlocmiss, ntarget;

# When printing the non-short steps, output an empty line between each case.

  if(report=="long" || report=="diff")
    print "";
}

# Print summary of performance of the rules for all input-output / source-target sets
# 1. SUCCESS indicates cases where all targets were output correctly.
# 2. FAIL indicates cases where none of the targets were output correctly.
# 3. PARTIAL indicates cases where one or more but not all of the targets were produced,
# where some of the output forms might also be incorrect.
# 4. OTHER indicates cases where no target(s) was/were provided, so no performance validation
# can be undertaken.

# The initial condition (NR>1) is required to skip this END statement, when the script is aborted
# in the beginning due to incorrect arguments or missing rule FSTs.

END { if(NR>=1) printf "SUMMARY - SUCCESS: %i/%i - FAIL: %i/%i - PARTIAL: %i/%i - OTHER: %i/%i\n", n_success, NR, n_fail, NR, n_mixed, NR, n_other, NR;
}

# Function for generating, with a specified FST, word-form outputs, based on a single input.
# There may be more than one output word-form.

function lookup(cmd, fst, input,     fst_output, inp, out, i, nr, nf, rs, fs)
{
  rs=RS; fs=FS;
  cmd_fst=cmd " " fst;

  # print input |& cmd_fst;
  # fflush(); close(cmd_fst, "to");
  # while((cmd_fst |& getline)!=0)
  #    {
  #      fst_output[++nr]=$0;
  #    }
  # fflush(); close(cmd_fst, "from");

  RS=""; FS="\n";
  print input |& cmd_fst;
  fflush(); close(cmd_fst, "to");
  cmd_fst |& getline inp;
  fflush(); close(cmd_fst, "from");
  RS=rs; FS=fs;

  nr=split(inp,fst_output,"\n");
  for(i=1; i<=nr; i++)
     {
       nf=split(fst_output[i],f,"\t");
       if(nf!=0)
         if(match(fst_output[i],"\\+\\?[\t$]")==0)
           out=out f[2] "\n";
         else
           out=out "+?" "\n";
     }
  sub("\n$","",out);
  
  return out;
}'

