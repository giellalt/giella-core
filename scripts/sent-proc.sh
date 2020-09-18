#! /bin/bash

# sent-disamb.sh
# This is a shell script for analysing sentences with the vislcg3 parser.
# It gives the analysis, and optionally the number of the disambiguation rules.

# usage:
# <script_name> (-t) -l <lang_code> <sentence_to_analyze>
# to output the number of disambiguation rules, too, use the parameter '-t'
# parametized for language (sme as default)
# input sentence either coming from the pipe or at the end in quotation marks
# parametrized for processing step: -s pos, -s dis, -s syn, -s dep

# change to 'true' to debug paths of analysis tools
debug='false'
HLOOKUP=`which hfst-tokenize`

if [ -n "$HLOOKUP" ]; then
  echo "using hfst-tokenize"
else
  echo "no hfst-lookup found: please install it!"
  echo "See you later!"
  exit 0
fi

# List of language catalogues:
# langs
# bak bxr chp chr ciw cor crk deu est evn fao fin fit fkv hdn hun ipk izh kal kca koi kpv lav liv lut mdf mhr mns mrj myv nds nio nob oji olo otw ron rus sjd sje sma sme smj smn sms som tat tku udm vep vot vro yrk
# startup_langs:
# aka amh bla chr crj crl dgr epo eus gle grn hin iku khk kio kjh kmr krl luo mhr moe moh ndl nno non nso rup sel srs sto swe tau tel tgl tir tlh tuv tyv xal xwo zul
# experiment_langs:
# ara bul ces eng est fin sms sqi
# closed_lags (ignore)
# dan isl
# closedSA-langs (ignore)
# zul



# -l sme|sma|fao|etc. => default: sme
l='sme'
# -s pos|dis|dep => default: pos
s='pos'
# -t => default: no trace
t=''

# lang group => default: lang- (because of default sme, which is now in the infrastructure)
lg='lang-'

#abbr file => default: sme-path (because of default: sme)
abbr='$GTLANGS/$lg$l/tools/tokenisers/abbr.txt'

#long_lang_list
long_lang_list=(bxr chp ciw cor crk fao fin fkv
                hdn ipk izh kal kca kpv liv mdf
                mhr mrj myv ndl nio nob olo ron rus
                sjd sje sma sme smj smn sms som tat tku
                tuv udm vep vro yrk)

#startup_lang_list
startup_lang_list=(amh bla evn sel sto tlh zul)

#experiment_lang_list
experiment_lang_list=(deu eng est)

if [[ "$debug" == "true" ]] ; then
    echo "_pre l  ${l}"
    echo "_pre s  ${s}"
    echo "_pre t  ${t}"
    echo "_pre lg  ${lg}"
    echo "_pre abbr  ${abbr}"
fi

usage() {
    echo "USAGE: 1. $0 [-t] [-l LANG] [-s PROCESSING_STEP] \"INPUT_TEXT\""  1>&2;
    echo "                       or"  1>&2;
    echo "       2. cat FILE or echo \"INPUT_TEXT\" | $0 [-t] [-l LANG] [-s PROCESSING_STEP] "  1>&2;
    echo "-l language code: sme North Saami (default), sma South Saami, etc."  1>&2;
    echo "-s processing step: pos part-of-speech tagging without disambiguation which is (default)"  1>&2;
    echo "   processing step: dis part-of-speech tagging with disambiguation with vislcg3"  1>&2;
    echo "   processing step: syn assigning syntactic functions via vislcg3"  1>&2;
    echo "   processing step: dep dependency parsing with vislcg3"  1>&2;
    echo "-t print traces of the disambiguation or parsing step"  1>&2;
    echo "-h print this text"  1>&2;
    exit 1;
}

while getopts ":l:s:h:t" o; do
    case "${o}" in
        l)
            l=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        t)
            t='--trace'
            ;;
        h)
	    usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# language parameter test and abbr file assignment
if [[ "${long_lang_list[*]}" =~ (^|[^[:alpha:]])$l([^[:alpha:]]|$) ]]; then
    lg='lang-'
#    if [[ "${experiment_lang_list[*]}" =~ (^|[^[:alpha:]])$l([^[:alpha:]]|$) ]]; then
#    lg='experiment-langs'
    if [  -f $GTLANGS/lang-$l/tools/tokenisers/abbr.txt ]; then
       abbr="--abbr=$GTLANGS/$lg$l/tools/tokenisers/abbr.txt"  # <--- new infra
    else
       abbr=''
       echo "Warning: no abbr file found" 1>&2;
       echo "  $GTLANGS/$lg$l/tools/tokenisers/abbr.txt" 1>&2;
       echo "............. preprocessing without it!" 1>&2;
    fi
fi

current_path="$GTLANGS/$lg$l"

if [[ "$debug" == "true" ]] ; then
    echo "post_ l  ${l}"
    echo "post_ s  ${s}"
    echo "post_ t  ${t}"
    echo "post_ lg  ${lg}"
    echo "post_ abbr  ${abbr}"
    echo "current_path  $current_path"
fi

if [[ "${long_lang_list[*]}" =~ (^|[^[:alpha:]])$l([^[:alpha:]]|$) ]]; then
    MORPH="$HLOOKUP --giella-cg --weight-classes=1 $current_path/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst "
    DIS="$current_path/src/cg3/disambiguator.cg3"
    if [ ! -f "$current_path/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst" ]; then
        echo "no hfst file found: please compile the language tools for $l"
        echo "See you later!"
        exit 0
    fi
else
    MORPH="$HLOOKUP -flags mbTT -utf8 $current_path/bin/$l.fst"
    DIS="$current_path/src/$l-dis.rle"
fi

#get the input
# no parameters after command => expect the input from cat, echo and pipe
if [[ $# -eq 0 ]]; then
#tput cup 0 0
    sentence=$(cat -)
else
    sentence=${@:${#@}}
fi

# mask round brackets
sentence="${sentence//(/\(}"
sentence="${sentence//)/\)}"

# path to the shared syntax
SD_PATH='$GTLANGS/giella-shared/smi/src/cg3'

# define commands
# common pos_cmd
#pos_cmd="echo $sentence | preprocess $abbr | $MORPH | $GTHOME/gt/script/lookup2cg"
pos_cmd="echo $sentence | $MORPH"

if [ $l == fao ] || [ $l == crk ]; then
    dis_cmd=$pos_cmd" | vislcg3 -g $GTLANGS/$lg$l/src/cg3/disambiguator.cg3 $t"
    syn_cmd=$dis_cmd" | vislcg3 -g $GTLANGS/$lg$l/src/cg3/functions.cg3 $t"
else
    dis_cmd=$pos_cmd" | vislcg3 -g $DIS $t"
    syn_cmd=$dis_cmd" | vislcg3 -g $SD_PATH/functions.cg3 $t"
fi

# common dep_cmd
dep_cmd=$syn_cmd" | vislcg3 -g $SD_PATH/dependency.cg3 $t"


# processing step
case $s in
    pos)
	echo "... pos tagging ..."
	echo $(echo $pos_cmd) | sh
	;;
    dis)
	if [[ "$debug" == "true" ]] ; then
	    echo "$dis_cmd"
	fi
	echo "... pos disambiguating ..."
	echo $(echo $dis_cmd) | sh
	;;
    syn)
	if [[ "$debug" == "true" ]] ; then
	    echo "$syn_cmd"
	fi
	echo "... syntax analysis ..."
	echo $(echo $syn_cmd) | sh
	;;
    dep)
	if [[ "$debug" == "true" ]] ; then
	    echo "$dep_cmd"
	fi
	echo "... inserting dependency relations ..."
	echo $(echo $dep_cmd) | sh
	;;
esac



# Notes for further development:
# ==============================

# At the moment, there is a family of scripts for analysis, in addition to this one:
# cealkka (sentence), sme-dis.sh (sentence, with rule nr), sme-multi.sh (sentence w/o disamb)
#                     smj-dis.sh (sentence, with rule nr), smj-multi.sh (sentence w/o disamb)
# With more lgs and more options this will develop into a wildernis.

# What we want:
# One script, with parametrised options along several paths:
# What language,
# What kind of input (plain text, xml text, evt. other text formats as well)
# What kind of output (disambiguated text with and without rule numbers, non-disambiguated text with and without syntactic tags
# What kind of morphological transducers (standard (tolerant) or normative (restricted))

# dis.sh (script for disambiguating sentences or text)
# If given as
# dis.sh filename
# the script expects a text
# If given as
# dis.sh
# (i.e., without file name), the script expects a sentence, and answers:
# "Write a sentence and press ENTER. Terminate by pressing ctrl-C."

# options:
# -l <lang> what disambiguator to call for (sme as default?)
# -n        gives the rule number (no rule numbers is default)
# -m        gives the non-disambiguated output (only section 1 in the .rle file)
# -norm     uses normative transducers for the morphological analysis,
#           ie will not recognise any non-conformant spellings
# -i <type> gives text type:
#           xml  (default, calls for ccat with the same <lang> as given above)
#           txt  (takes plain text as input, is basically the script we have now)
#           doc  (if we bother doing this, it would call for ... | antiword -db | ccat | ...)
#           odt  (openoffice documents could probably get the same treatment
#           html (importing relevant code from convert2xml.pl)
#           pdf  (importing relevant code from convert2xml.pl)
# -o <type> visl (default is the standard vislcg output format)
#           xml  (gives xml-tagget output)
