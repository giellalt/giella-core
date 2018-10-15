# A number of useful aliases to run lookup sessions on the langauges we support.

# xerox aliases

HOSTNAME=`hostname`

if [ $HOSTNAME == 'victorio.uit.no' ]
then export LOOKUP='/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -flags  mbTT -utf8'
#then export LOOKUP='/opt/sami/xerox/c-fsm/ix86-linux2.6-gcc3.4/bin/lookup -q -flags  mbTT -utf8'
#else export LOOKUP='lookup -flags mbTT' # we try with quiet mode
else export LOOKUP='lookup -q -flags mbTT'
fi

export HLOOKUP='hfst-lookup -q'

# Languages in newinfra

alias deng='$LOOKUP $GTHOME/experiment-langs/eng/src/generator-gt-desc.xfst'
alias dest2='$LOOKUP $GTHOME/experiment-langs/est/src/generator-gt-desc.xfst'


alias dkhk='$LOOKUP $GTHOME/startup-langs/khk/src/generator-gt-desc.xfst'
alias dkjh='$LOOKUP $GTHOME/startup-langs/kjh/src/generator-gt-desc.xfst'
alias dtyv='$LOOKUP $GTHOME/startup-langs/tyv/src/generator-gt-desc.xfst'
alias dxal='$LOOKUP $GTHOME/startup-langs/xal/src/generator-gt-desc.xfst'
alias dxwo='$LOOKUP $GTHOME/startup-langs/xwo/src/generator-gt-desc.xfst'

alias damh='$LOOKUP $GTHOME/startup-langs/amh/src/generator-gt-desc.xfst'
alias dbak='$LOOKUP $GTHOME/langs/bak/src/generator-gt-desc.xfst'
alias dbla='$LOOKUP $GTHOME/startup-langs/bla/src/generator-gt-desc.xfst'
alias devn='$LOOKUP $GTHOME/langs/evn/src/generator-gt-desc.xfst'
alias dsel='$LOOKUP $GTHOME/startup-langs/sel/src/generator-gt-desc.xfst'
alias dsrs='$LOOKUP $GTHOME/startup-langs/srs/src/generator-gt-desc.xfst'
alias dsto='$LOOKUP $GTHOME/startup-langs/sto/src/generator-gt-desc.xfst'
alias dtlh='$LOOKUP $GTHOME/startup-langs/tlh/src/generator-gt-desc.xfst'
alias dzul='$LOOKUP $GTHOME/startup-langs/zul/src/generator-gt-desc.xfst'

alias dbxr='$LOOKUP $GTHOME/langs/bxr/src/generator-gt-desc.xfst'
alias dchp='$LOOKUP $GTHOME/langs/chp/src/generator-gt-desc.xfst'
alias dciw='$LOOKUP $GTHOME/langs/ciw/src/generator-gt-desc.xfst'
alias dcor='$LOOKUP $GTHOME/langs/cor/src/generator-gt-desc.xfst'
alias dcrk='$LOOKUP $GTHOME/langs/crk/src/generator-gt-desc.xfst'
alias dchp='$LOOKUP $GTHOME/langs/chp/src/generator-gt-desc.xfst'
alias dchr='$LOOKUP $GTHOME/langs/chr/src/generator-gt-desc.xfst'
alias ddeu='$LOOKUP $GTHOME/langs/deu/src/generator-gt-desc.xfst'
alias dest='$LOOKUP $GTHOME/langs/est/src/generator-gt-desc.xfst'
alias dfao='$LOOKUP $GTHOME/langs/fao/src/generator-gt-desc.xfst'
alias dfin='$LOOKUP $GTHOME/langs/fin/src/generator-gt-desc.xfst'
alias dfkv='$LOOKUP $GTHOME/langs/fkv/src/generator-gt-desc.xfst'
alias dhdn='$LOOKUP $GTHOME/langs/hdn/src/generator-gt-desc.xfst'
alias dhun='$LOOKUP $GTHOME/langs/hun/src/generator-gt-desc.xfst'
alias dipk='$LOOKUP $GTHOME/langs/ipk/src/generator-gt-desc.xfst'
alias dizh='$LOOKUP $GTHOME/langs/izh/src/generator-gt-desc.xfst'
alias dkal='$LOOKUP $GTHOME/langs/kal/src/generator-gt-desc.xfst'
alias dkca='$LOOKUP $GTHOME/langs/kca/src/generator-gt-desc.xfst'
alias dkom='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dkpv='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias dlav='$LOOKUP $GTHOME/langs/lav/src/generator-gt-desc.xfst'
alias dliv='$LOOKUP $GTHOME/langs/liv/src/generator-gt-desc.xfst'
alias dmdf='$LOOKUP $GTHOME/langs/mdf/src/generator-gt-desc.xfst'
alias dmhr='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.xfst'
alias dmns='$LOOKUP $GTHOME/langs/mns/src/generator-gt-desc.xfst'
alias dmrj='$LOOKUP $GTHOME/langs/mrj/src/generator-gt-desc.xfst'
alias dmyv='$LOOKUP $GTHOME/langs/myv/src/generator-gt-desc.xfst'
alias dndl='$LOOKUP $GTHOME/langs/ndl/src/generator-gt-desc.xfst'
alias dnio='$LOOKUP $GTHOME/langs/nio/src/generator-gt-desc.xfst'
alias dnob='$LOOKUP $GTHOME/langs/nob/src/generator-gt-desc.xfst'
alias dolo='$LOOKUP $GTHOME/langs/olo/src/generator-gt-desc.xfst'
alias doji='$LOOKUP $GTHOME/langs/oji/src/generator-gt-desc.xfst'
alias dotw='$LOOKUP $GTHOME/langs/otw/src/generator-gt-desc.xfst'
alias dron='$LOOKUP $GTHOME/langs/ron/src/generator-gt-desc.xfst'
alias drus='$LOOKUP $GTHOME/langs/rus/src/generator-gt-desc.xfst'
alias dsjd='$LOOKUP $GTHOME/langs/sjd/src/generator-gt-desc.xfst'
alias dsje='$LOOKUP $GTHOME/langs/sje/src/generator-gt-desc.xfst'
alias dsma='$LOOKUP $GTHOME/langs/sma/src/generator-gt-desc.xfst'
alias dsme='$LOOKUP $GTHOME/langs/sme/src/generator-gt-desc.xfst'
alias dsmj='$LOOKUP $GTHOME/langs/smj/src/generator-gt-desc.xfst'
alias dsmn='$LOOKUP $GTHOME/langs/smn/src/generator-gt-desc.xfst'
alias dsms='$LOOKUP $GTHOME/langs/sms/src/generator-gt-desc.xfst'
alias dsom='$LOOKUP $GTHOME/langs/som/src/generator-gt-desc.xfst'
alias dtat='$LOOKUP $GTHOME/langs/tat/src/generator-gt-desc.xfst'
alias dtku='$LOOKUP $GTHOME/langs/tku/src/generator-gt-desc.xfst'
alias dtuv='$LOOKUP $GTHOME/langs/tuv/src/generator-gt-desc.xfst'
alias dudm='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'
alias dvep='$LOOKUP $GTHOME/langs/vep/src/generator-gt-desc.xfst'
alias dvro='$LOOKUP $GTHOME/langs/vro/src/generator-gt-desc.xfst'
alias dyrk='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.xfst'


alias ueng='$LOOKUP $GTHOME/experiment-langs/eng/src/analyser-gt-desc.xfst'
alias uest2='$LOOKUP $GTHOME/experiment-langs/est/src/analyser-gt-desc.xfst'


alias ukhk='$LOOKUP $GTHOME/startup-langs/khk/src/analyser-gt-desc.xfst'
alias ukjh='$LOOKUP $GTHOME/startup-langs/kjh/src/analyser-gt-desc.xfst'
alias utyv='$LOOKUP $GTHOME/startup-langs/tyv/src/analyser-gt-desc.xfst'
alias uxal='$LOOKUP $GTHOME/startup-langs/xal/src/analyser-gt-desc.xfst'
alias uxwo='$LOOKUP $GTHOME/startup-langs/xwo/src/analyser-gt-desc.xfst'


alias uamh='$LOOKUP $GTHOME/startup-langs/amh/src/analyser-gt-desc.xfst'
alias ubak='$LOOKUP $GTHOME/langs/bak/src/analyser-gt-desc.xfst'
alias ubla='$LOOKUP $GTHOME/startup-langs/bla/src/analyser-gt-desc.xfst'
alias uevn='$LOOKUP $GTHOME/langs/evn/src/analyser-gt-desc.xfst'
alias usel='$LOOKUP $GTHOME/startup-langs/sel/src/analyser-gt-desc.xfst'
alias usrs='$LOOKUP $GTHOME/startup-langs/srs/src/analyser-gt-desc.xfst'
alias usto='$LOOKUP $GTHOME/startup-langs/sto/src/analyser-gt-desc.xfst'
alias utlh='$LOOKUP $GTHOME/startup-langs/tlh/src/analyser-gt-desc.xfst'
alias uzul='$LOOKUP $GTHOME/startup-langs/zul/src/analyser-gt-desc.xfst'

alias ubxr='$LOOKUP $GTHOME/langs/bxr/src/analyser-gt-desc.xfst'
alias uchp='$LOOKUP $GTHOME/langs/chp/src/analyser-gt-desc.xfst'
alias uchr='$LOOKUP $GTHOME/langs/chr/src/analyser-gt-desc.xfst'
alias uciw='$LOOKUP $GTHOME/langs/ciw/src/analyser-gt-desc.xfst'
alias ucor='$LOOKUP $GTHOME/langs/cor/src/analyser-gt-desc.xfst'
alias ucrk='$LOOKUP $GTHOME/langs/crk/src/analyser-gt-desc.xfst'
alias udeu='$LOOKUP $GTHOME/langs/deu/src/analyser-gt-desc.xfst'
alias uest='$LOOKUP $GTHOME/langs/est/src/analyser-gt-desc.xfst'
alias ufao='$LOOKUP $GTHOME/langs/fao/src/analyser-gt-desc.xfst'
alias ufin='$LOOKUP $GTHOME/langs/fin/src/analyser-gt-desc.xfst'
alias ufkv='$LOOKUP $GTHOME/langs/fkv/src/analyser-gt-desc.xfst'
alias uhdn='$LOOKUP $GTHOME/langs/hdn/src/analyser-gt-desc.xfst'
alias uhun='$LOOKUP $GTHOME/langs/hun/src/analyser-gt-desc.xfst'
alias uipk='$LOOKUP $GTHOME/langs/ipk/src/analyser-gt-desc.xfst'
alias uizh='$LOOKUP $GTHOME/langs/izh/src/analyser-gt-desc.xfst'
alias ukal='$LOOKUP $GTHOME/langs/kal/src/analyser-gt-desc.xfst'
alias ukca='$LOOKUP $GTHOME/langs/kca/src/analyser-gt-desc.xfst'
alias ukom='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias ukpv='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias ulav='$LOOKUP $GTHOME/langs/lav/src/analyser-gt-desc.xfst'
alias uliv='$LOOKUP $GTHOME/langs/liv/src/analyser-gt-desc.xfst'
alias umdf='$LOOKUP $GTHOME/langs/mdf/src/analyser-gt-desc.xfst'
alias umhr='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.xfst'
alias umns='$LOOKUP $GTHOME/langs/mns/src/analyser-gt-desc.xfst'
alias umrj='$LOOKUP $GTHOME/langs/mrj/src/analyser-gt-desc.xfst'
alias umyv='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.xfst'
alias undl='$LOOKUP $GTHOME/langs/ndl/src/analyser-gt-desc.xfst'
alias unio='$LOOKUP $GTHOME/langs/nio/src/analyser-gt-desc.xfst'
alias unob='$LOOKUP $GTHOME/langs/nob/src/analyser-gt-desc.xfst'
alias uolo='$LOOKUP $GTHOME/langs/olo/src/analyser-gt-desc.xfst'
alias uoji='$LOOKUP $GTHOME/langs/oji/src/analyser-gt-desc.xfst'
alias uotw='$LOOKUP $GTHOME/langs/otw/src/analyser-gt-desc.xfst'
alias uron='$LOOKUP $GTHOME/langs/ron/src/analyser-gt-desc.xfst'
alias urus='$LOOKUP $GTHOME/langs/rus/src/analyser-gt-desc.xfst'
alias usjd='$LOOKUP $GTHOME/langs/sjd/src/analyser-gt-desc.xfst'
alias usje='$LOOKUP $GTHOME/langs/sje/src/analyser-gt-desc.xfst'
alias usma='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-desc.xfst'
alias usme='$LOOKUP $GTHOME/langs/sme/src/analyser-gt-desc.xfst'
alias usmedis='$LOOKUP $GTHOME/langs/sme/src/analyser-disamb-gt-desc.xfst'
alias usmadis='$LOOKUP $GTHOME/langs/sma/src/analyser-disamb-gt-desc.xfst'
alias usmjdis='$LOOKUP $GTHOME/langs/smj/src/analyser-disamb-gt-desc.xfst'
alias usmndis='$LOOKUP $GTHOME/langs/smn/src/analyser-disamb-gt-desc.xfst'
alias usmsdis='$LOOKUP $GTHOME/langs/sms/src/analyser-disamb-gt-desc.xfst'
alias ufkvdis='$LOOKUP $GTHOME/langs/fkv/src/analyser-disamb-gt-desc.xfst'
alias usmj='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-desc.xfst'
alias usmn='$LOOKUP $GTHOME/langs/smn/src/analyser-gt-desc.xfst'
alias usms='$LOOKUP $GTHOME/langs/sms/src/analyser-gt-desc.xfst'
alias usom='$LOOKUP $GTHOME/langs/som/src/analyser-gt-desc.xfst'
alias utat='$LOOKUP $GTHOME/langs/tat/src/analyser-gt-desc.xfst'
alias utku='$LOOKUP $GTHOME/langs/tku/src/analyser-gt-desc.xfst'
alias utuv='$LOOKUP $GTHOME/langs/tuv/src/analyser-gt-desc.xfst'
alias uudm='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'
alias uvep='$LOOKUP $GTHOME/langs/vep/src/analyser-gt-desc.xfst'
alias uvro='$LOOKUP $GTHOME/langs/vro/src/analyser-gt-desc.xfst'
alias uyrk='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.xfst'


# Dictionary transducers

alias usmnDict='$LOOKUP $GTHOME/langs/smn/src/analyser-dict-gt-desc.xfst'
alias dsmnDict='$LOOKUP $GTHOME/langs/smn/src/generator-dict-gt-norm.xfst'
alias usmsDict='$LOOKUP $GTHOME/langs/sms/src/analyser-dict-gt-desc.xfst'
alias dsmsDict='$LOOKUP $GTHOME/langs/sms/src/generator-dict-gt-norm.xfst'


alias husmnDict='$HLOOKUP $GTHOME/langs/smn/src/analyser-dict-gt-desc.hfstol'
alias hdsmnDict='$HLOOKUP $GTHOME/langs/smn/src/generator-dict-gt-norm.hfstol'
alias husmsDict='$HLOOKUP $GTHOME/langs/sms/src/analyser-dict-gt-desc.hfstol'
alias hdsmsDict='$HLOOKUP $GTHOME/langs/sms/src/generator-dict-gt-norm.hfstol'



# Languages in newinfra, lazy cyrillic aliases:

alias уком='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias глщь='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.xfst'
alias умчр='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.xfst'
alias умыв='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.xfst'
alias уудм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.xfst'
alias уырк='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.xfst'
alias урус='$LOOKUP $GTHOME/langs/rus/src/analyser-gt-desc.xfst'

alias дком='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.xfst'
alias дмчр='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.xfst'
alias дмыв='$LOOKUP $GTHOME/langs/myv/src/generator-gt-desc.xfst'
alias дудм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-desc.xfst'
alias дырк='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.xfst'
alias друс='$LOOKUP $GTHOME/langs/rus/src/generator-gt-desc.xfst'


# Languages in newinfra, Normative variants:

alias dkhkNorm='$LOOKUP $GTHOME/startup-langs/khk/src/generator-gt-norm.xfst'
alias dkjhNorm='$LOOKUP $GTHOME/startup-langs/kjh/src/generator-gt-norm.xfst'
alias dtyvNorm='$LOOKUP $GTHOME/startup-langs/tyv/src/generator-gt-norm.xfst'
alias dxalNorm='$LOOKUP $GTHOME/startup-langs/xal/src/generator-gt-norm.xfst'
alias dxwoNorm='$LOOKUP $GTHOME/startup-langs/xwo/src/generator-gt-norm.xfst'

alias damhNorm='$LOOKUP $GTHOME/startup-langs/amh/src/generator-gt-norm.xfst'
alias dbakNorm='$LOOKUP $GTHOME/langs/bak/src/generator-gt-norm.xfst'
alias dblaNorm='$LOOKUP $GTHOME/startup-langs/bla/src/generator-gt-norm.xfst'
alias devnNorm='$LOOKUP $GTHOME/langs/evn/src/generator-gt-norm.xfst'
alias dselNorm='$LOOKUP $GTHOME/startup-langs/sel/src/generator-gt-norm.xfst'
alias dstoNorm='$LOOKUP $GTHOME/startup-langs/sto/src/generator-gt-norm.xfst'
alias dtlhNorm='$LOOKUP $GTHOME/startup-langs/tlh/src/generator-gt-norm.xfst'
alias dzulNorm='$LOOKUP $GTHOME/startup-langs/zul/src/generator-gt-norm.xfst'

alias dbxrNorm='$LOOKUP $GTHOME/langs/bxr/src/generator-gt-norm.xfst'
alias dchpNorm='$LOOKUP $GTHOME/langs/chp/src/generator-gt-norm.xfst'
alias dciwNorm='$LOOKUP $GTHOME/langs/ciw/src/generator-gt-norm.xfst'
alias dcorNorm='$LOOKUP $GTHOME/langs/cor/src/generator-gt-norm.xfst'
alias dcrkNorm='$LOOKUP $GTHOME/langs/crk/src/generator-gt-norm.xfst'
alias dchrNorm='$LOOKUP $GTHOME/langs/chr/src/generator-gt-norm.xfst'
alias destNorm='$LOOKUP $GTHOME/langs/est/src/generator-gt-norm.xfst'
alias dfaoNorm='$LOOKUP $GTHOME/langs/fao/src/generator-gt-norm.xfst'
alias dfinNorm='$LOOKUP $GTHOME/langs/fin/src/generator-gt-norm.xfst'
alias dfkvNorm='$LOOKUP $GTHOME/langs/fkv/src/generator-gt-norm.xfst'
alias dhdnNorm='$LOOKUP $GTHOME/langs/hdn/src/generator-gt-norm.xfst'
alias dhunNorm='$LOOKUP $GTHOME/langs/hun/src/generator-gt-norm.xfst'
alias dipkNorm='$LOOKUP $GTHOME/langs/ipk/src/generator-gt-norm.xfst'
alias dizhNorm='$LOOKUP $GTHOME/langs/izh/src/generator-gt-norm.xfst'
alias dkalNorm='$LOOKUP $GTHOME/langs/kal/src/generator-gt-norm.xfst'
alias dkcaNorm='$LOOKUP $GTHOME/langs/kca/src/generator-gt-norm.xfst'
alias dkomNorm='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias dkpvNorm='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias dlavNorm='$LOOKUP $GTHOME/langs/lav/src/generator-gt-norm.xfst'
alias dlivNorm='$LOOKUP $GTHOME/langs/liv/src/generator-gt-norm.xfst'
alias dmdfNorm='$LOOKUP $GTHOME/langs/mdf/src/generator-gt-norm.xfst'
alias dmhrNorm='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.xfst'
alias dmnsNorm='$LOOKUP $GTHOME/langs/mns/src/generator-gt-norm.xfst'
alias dmrjNorm='$LOOKUP $GTHOME/langs/mrj/src/generator-gt-norm.xfst'
alias dmyvNorm='$LOOKUP $GTHOME/langs/myv/src/generator-gt-norm.xfst'
alias dndlNorm='$LOOKUP $GTHOME/langs/ndl/src/generator-gt-norm.xfst'
alias dnioNorm='$LOOKUP $GTHOME/langs/nio/src/generator-gt-norm.xfst'
alias dnobNorm='$LOOKUP $GTHOME/langs/nob/src/generator-gt-norm.xfst'
alias doloNorm='$LOOKUP $GTHOME/langs/olo/src/generator-gt-norm.xfst'
alias dojiNorm='$LOOKUP $GTHOME/langs/oji/src/generator-gt-norm.xfst'
alias dotwNorm='$LOOKUP $GTHOME/langs/otw/src/generator-gt-norm.xfst'
alias dronNorm='$LOOKUP $GTHOME/langs/ron/src/generator-gt-norm.xfst'
alias drusNorm='$LOOKUP $GTHOME/langs/rus/src/generator-gt-norm.xfst'
alias dsjdNorm='$LOOKUP $GTHOME/langs/sjd/src/generator-gt-norm.xfst'
alias dsjeNorm='$LOOKUP $GTHOME/langs/sje/src/generator-gt-norm.xfst'
alias dsmaNorm='$LOOKUP $GTHOME/langs/sma/src/generator-gt-norm.xfst'
alias dsmeNorm='$LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst'
alias dsmjNorm='$LOOKUP $GTHOME/langs/smj/src/generator-gt-norm.xfst'
alias dsmnNorm='$LOOKUP $GTHOME/langs/smn/src/generator-gt-norm.xfst'
alias dsmsNorm='$LOOKUP $GTHOME/langs/sms/src/generator-gt-norm.xfst'
alias dsomNorm='$LOOKUP $GTHOME/langs/som/src/generator-gt-norm.xfst'
alias dtatNorm='$LOOKUP $GTHOME/langs/tat/src/generator-gt-norm.xfst'
alias dtkuNorm='$LOOKUP $GTHOME/langs/tku/src/generator-gt-norm.xfst'
alias dtuvNorm='$LOOKUP $GTHOME/langs/tuv/src/generator-gt-norm.xfst'
alias dudmNorm='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'
alias dvepNorm='$LOOKUP $GTHOME/langs/vep/src/generator-gt-norm.xfst'
alias dvroNorm='$LOOKUP $GTHOME/langs/vro/src/generator-gt-norm.xfst'
alias dyrkNorm='$LOOKUP $GTHOME/langs/yrk/src/generator-gt-norm.xfst'


alias ukhkNorm='$LOOKUP $GTHOME/startup-langs/khk/src/analyser-gt-norm.xfst'
alias ukjhNorm='$LOOKUP $GTHOME/startup-langs/kjh/src/analyser-gt-norm.xfst'
alias utyvNorm='$LOOKUP $GTHOME/startup-langs/tyv/src/analyser-gt-norm.xfst'
alias uxalNorm='$LOOKUP $GTHOME/startup-langs/xal/src/analyser-gt-norm.xfst'
alias uxwoNorm='$LOOKUP $GTHOME/startup-langs/xwo/src/analyser-gt-norm.xfst'



alias uamhNorm='$LOOKUP $GTHOME/langs/amh/src/analyser-gt-norm.xfst'
alias ubakNorm='$LOOKUP $GTHOME/langs/bak/src/analyser-gt-norm.xfst'
alias ublaNorm='$LOOKUP $GTHOME/langs/bla/src/analyser-gt-norm.xfst'
alias uevnNorm='$LOOKUP $GTHOME/langs/evn/src/analyser-gt-norm.xfst'
alias uselNorm='$LOOKUP $GTHOME/langs/sel/src/analyser-gt-norm.xfst'
alias ustoNorm='$LOOKUP $GTHOME/langs/sto/src/analyser-gt-norm.xfst'
alias utlhNorm='$LOOKUP $GTHOME/langs/tlh/src/analyser-gt-norm.xfst'
alias uzulNorm='$LOOKUP $GTHOME/langs/zul/src/analyser-gt-norm.xfst'

alias ubxrNorm='$LOOKUP $GTHOME/langs/bxr/src/analyser-gt-norm.xfst'
alias uchpNorm='$LOOKUP $GTHOME/langs/chp/src/analyser-gt-norm.xfst'
alias uciwNorm='$LOOKUP $GTHOME/langs/ciw/src/analyser-gt-norm.xfst'
alias ucorNorm='$LOOKUP $GTHOME/langs/cor/src/analyser-gt-norm.xfst'
alias ucrkNorm='$LOOKUP $GTHOME/langs/crk/src/analyser-gt-norm.xfst'
alias uchrNorm='$LOOKUP $GTHOME/langs/chr/src/analyser-gt-norm.xfst'
alias uestNorm='$LOOKUP $GTHOME/langs/est/src/analyser-gt-norm.xfst'
alias ufaoNorm='$LOOKUP $GTHOME/langs/fao/src/analyser-gt-norm.xfst'
alias ufinNorm='$LOOKUP $GTHOME/langs/fin/src/analyser-gt-norm.xfst'
alias ufkvNorm='$LOOKUP $GTHOME/langs/fkv/src/analyser-gt-norm.xfst'
alias uhdnNorm='$LOOKUP $GTHOME/langs/hdn/src/analyser-gt-norm.xfst'
alias uhunNorm='$LOOKUP $GTHOME/langs/hun/src/analyser-gt-norm.xfst'
alias uipkNorm='$LOOKUP $GTHOME/langs/ipk/src/analyser-gt-norm.xfst'
alias uizhNorm='$LOOKUP $GTHOME/langs/izh/src/analyser-gt-norm.xfst'
alias ukalNorm='$LOOKUP $GTHOME/langs/kal/src/analyser-gt-norm.xfst'
alias ukcaNorm='$LOOKUP $GTHOME/langs/kca/src/analyser-gt-norm.xfst'
alias ukomNorm='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias ukpvNorm='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias ulavNorm='$LOOKUP $GTHOME/langs/lav/src/analyser-gt-norm.xfst'
alias ulivNorm='$LOOKUP $GTHOME/langs/liv/src/analyser-gt-norm.xfst'
alias umdfNorm='$LOOKUP $GTHOME/langs/mdf/src/analyser-gt-norm.xfst'
alias umhrNorm='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.xfst'
alias umnsNorm='$LOOKUP $GTHOME/langs/mns/src/analyser-gt-norm.xfst'
alias umrjNorm='$LOOKUP $GTHOME/langs/mrj/src/analyser-gt-norm.xfst'
alias umyvNorm='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.xfst'
alias undlNorm='$LOOKUP $GTHOME/langs/ndl/src/analyser-gt-norm.xfst'
alias unioNorm='$LOOKUP $GTHOME/langs/nio/src/analyser-gt-norm.xfst'
alias unobNorm='$LOOKUP $GTHOME/langs/nob/src/analyser-gt-norm.xfst'
alias uojiNorm='$LOOKUP $GTHOME/langs/oji/src/analyser-gt-norm.xfst'
alias uotwNorm='$LOOKUP $GTHOME/langs/otw/src/analyser-gt-norm.xfst'
alias uoloNorm='$LOOKUP $GTHOME/langs/olo/src/analyser-gt-norm.xfst'
alias uronNorm='$LOOKUP $GTHOME/langs/ron/src/analyser-gt-norm.xfst'
alias urusNorm='$LOOKUP $GTHOME/langs/rus/src/analyser-gt-norm.xfst'
alias usjdNorm='$LOOKUP $GTHOME/langs/sjd/src/analyser-gt-norm.xfst'
alias usjeNorm='$LOOKUP $GTHOME/langs/sje/src/analyser-gt-norm.xfst'
alias usmaNorm='$LOOKUP $GTHOME/langs/sma/src/analyser-gt-norm.xfst'
alias usmeNorm='$LOOKUP $GTHOME/langs/sme/src/analyser-gt-norm.xfst'
alias usmjNorm='$LOOKUP $GTHOME/langs/smj/src/analyser-gt-norm.xfst'
alias usmnNorm='$LOOKUP $GTHOME/langs/smn/src/analyser-gt-norm.xfst'
alias usmsNorm='$LOOKUP $GTHOME/langs/sms/src/analyser-gt-norm.xfst'
alias usomNorm='$LOOKUP $GTHOME/langs/som/src/analyser-gt-norm.xfst'
alias utatNorm='$LOOKUP $GTHOME/langs/tat/src/analyser-gt-norm.xfst'
alias utkuNorm='$LOOKUP $GTHOME/langs/tku/src/analyser-gt-norm.xfst'
alias utuvNorm='$LOOKUP $GTHOME/langs/tuv/src/analyser-gt-norm.xfst'
alias uudmNorm='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'
alias uvepNorm='$LOOKUP $GTHOME/langs/vep/src/analyser-gt-norm.xfst'
alias uvroNorm='$LOOKUP $GTHOME/langs/vro/src/analyser-gt-norm.xfst'
alias uyrkNorm='$LOOKUP $GTHOME/langs/yrk/src/analyser-gt-norm.xfst'

# Languages in newinfra, lazy cyrillic aliases:

alias дкомНорм='$LOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.xfst'
alias дмчрНорм='$LOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.xfst'
alias дмывНорм='$LOOKUP $GTHOME/langs/myv/src/generator-gt-norm.xfst'
alias дудмНорм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'
alias дыркНорм='$LOOKUP $GTHOME/langs/udm/src/generator-gt-norm.xfst'

alias укомНорм='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias глщьНорм='$LOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.xfst'
alias умчрНорм='$LOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.xfst'
alias умывНорм='$LOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.xfst'
alias уудмНорм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'
alias уыркНорм='$LOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.xfst'


# Other languages in the old infra:

alias   damh='$LOOKUP $GTHOME/st/amh/bin/iamh.fst'
alias   dces='$LOOKUP $GTHOME/st/ces/bin/ices.fst'
alias   deus='$LOOKUP $GTHOME/st/eus/bin/ieus.fst'
alias   diku='$LOOKUP $GTHOME/st/iku/bin/iiku.fst'
alias   dnno='$LOOKUP $GTHOME/st/nno/bin/inno.fst'
alias   dnon='$LOOKUP $GTHOME/st/non/bin/inon.fst'

alias   uamh='$LOOKUP $GTHOME/st/amh/bin/amh.fst'
alias   uces='$LOOKUP $GTHOME/st/ces/bin/ces.fst'
alias   ueus='$LOOKUP $GTHOME/st/eus/bin/eus.fst'
alias   uiku='$LOOKUP $GTHOME/st/iku/bin/iku.fst'
alias   unno='$LOOKUP $GTHOME/st/nno/bin/nno.fst'
alias   unon='$LOOKUP $GTHOME/startup-langs/non/src/analyser-gt-desc.xfst'


alias   дбхр='$LOOKUP $GTHOME/st/bxr/bin/ibxr.fst'
alias   убхр='$LOOKUP $GTHOME/st/bxr/bin/bxr.fst'

# Other FU languages:






# Bilingual transducers:

alias crkeng='$LOOKUP $GTHOME/words/dicts/crkeng/bin/crkeng-all.fst'
alias engsme='$LOOKUP $GTHOME/words/dicts/engsme/bin/engsme-all.fst'
alias finsme='$LOOKUP $GTHOME/words/dicts/finsme/bin/finsme-all.fst'
alias finsmn='$LOOKUP $GTHOME/words/dicts/finsmn/bin/finsmn-all.fst'
alias fitswe='$LOOKUP $GTHOME/kvensk/fitswe/bin/fitswe-all.fst'
alias fkvnob='$LOOKUP $GTHOME/words/dicts/fkvnob/bin/fkvnob-all.fst'
alias hdneng='$LOOKUP $GTHOME/words/dicts/hdneng/bin/hdneng-all.fst'
alias kaldan='$LOOKUP $GTHOME/words/dicts/kaldan/bin/kaldan-all.fst'
alias kaleng='$LOOKUP $GTHOME/words/dicts/kaleng/bin/kaleng-all.fst'
alias myvmdf='$LOOKUP $GTHOME/words/dicts/nobfkv/bin/myvmdf-all.fst'
alias nobfkv='$LOOKUP $GTHOME/words/dicts/nobfkv/bin/nobfkv-all.fst'
alias nobsma='$LOOKUP $GTHOME/words/dicts/nobsma/bin/nobsma-all.fst'
alias nobsmj='$LOOKUP $GTHOME/words/dicts/nobsmj/bin/nobsmj-all.fst'
alias nobsme='$LOOKUP $GTHOME/words/dicts/nobsme/bin/nobsme-all.fst'
alias smanob='$LOOKUP $GTHOME/words/dicts/smanob/bin/smanob-all.fst'
alias smeeng='$LOOKUP $GTHOME/words/dicts/smeeng/bin/smeeng-all.fst'
alias smefin='$LOOKUP $GTHOME/words/dicts/smefin/bin/smefin-all.fst'
alias smenob='$LOOKUP $GTHOME/words/dicts/smenob/bin/smenob-all.fst'
alias smesma='$LOOKUP $GTHOME/words/dicts/smesma/bin/smesma-all.fst'
alias smesmj='$LOOKUP $GTHOME/words/dicts/smesmj/bin/smesmj-all.fst'
alias smasme='$LOOKUP $GTHOME/words/dicts/smasme/bin/smasme-all.fst'
alias smesmn='$LOOKUP $GTHOME/words/dicts/smesmn/bin/smesmn-all.fst'
alias smjsme='$LOOKUP $GTHOME/words/dicts/smesmj/bin/smjsme-all.fst'
alias smnfin='$LOOKUP $GTHOME/words/dicts/smnfin/bin/smnfin-all.fst'
alias smnsme='$LOOKUP $GTHOME/words/dicts/smnsme/bin/smnsme-all.fst'
alias swefit='$LOOKUP $GTHOME/words/dicts/swefit/bin/swefit-all.fst'
alias myvmdf='$LOOKUP $GTHOME/words/dicts/myvmdf/bin/myvmdf-all.fst'

# Other transducers
alias ogeo='$LOOKUP $GTHOME/words/dicts/smi/geo/bin/geo.fst'
alias kaldic='$LOOKUP $GTHOME/words/dicts/kaldan/bin/kaldic.fst'


# HFST aliases

alias hdkhk='$HLOOKUP $GTHOME/startup-langs/khk/src/generator-gt-desc.hfstol'
alias hdkjh='$HLOOKUP $GTHOME/startup-langs/kjh/src/generator-gt-desc.hfstol'
alias hdtyv='$HLOOKUP $GTHOME/startup-langs/tyv/src/generator-gt-desc.hfstol'
alias hdxal='$HLOOKUP $GTHOME/startup-langs/xal/src/generator-gt-desc.hfstol'
alias hdxwo='$HLOOKUP $GTHOME/startup-langs/xwo/src/generator-gt-desc.hfstol'

alias hdamh='$HLOOKUP $GTHOME/startup-langs/amh/src/generator-gt-desc.hfstol'
alias hdbak='$HLOOKUP $GTHOME/langs/bak/src/generator-gt-desc.hfstol'
alias hdbla='$HLOOKUP $GTHOME/startup-langs/bla/src/generator-gt-desc.hfstol'
alias hdevn='$HLOOKUP $GTHOME/langs/evn/src/generator-gt-desc.hfstol'
alias hdsel='$HLOOKUP $GTHOME/startup-langs/sel/src/generator-gt-desc.hfstol'
alias hdsrs='$HLOOKUP $GTHOME/startup-langs/srs/src/generator-gt-desc.hfstol'
alias hdsto='$HLOOKUP $GTHOME/startup-langs/sto/src/generator-gt-desc.hfstol'
alias hdtlh='$HLOOKUP $GTHOME/startup-langs/tlh/src/generator-gt-desc.hfstol'
alias hdzul='$HLOOKUP $GTHOME/startup-langs/zul/src/generator-gt-desc.hfstol'

alias hdbxr='$HLOOKUP $GTHOME/langs/bxr/src/generator-gt-desc.hfstol'
alias hdchp='$HLOOKUP $GTHOME/langs/chp/src/generator-gt-desc.hfstol'
alias hdciw='$HLOOKUP $GTHOME/langs/ciw/src/generator-gt-desc.hfstol'
alias hdcor='$HLOOKUP $GTHOME/langs/cor/src/generator-gt-desc.hfstol'
alias hdcrk='$HLOOKUP $GTHOME/langs/crk/src/generator-gt-desc.hfstol'
alias hdchr='$HLOOKUP $GTHOME/langs/chr/src/generator-gt-desc.hfstol'
alias hddeu='$HLOOKUP $GTHOME/langs/deu/src/generator-gt-desc.hfstol'
alias hdest='$HLOOKUP $GTHOME/langs/est/src/generator-gt-desc.hfstol'
alias hdfao='$HLOOKUP $GTHOME/langs/fao/src/generator-gt-desc.hfstol'
alias hdfin='$HLOOKUP $GTHOME/langs/fin/src/generator-gt-desc.hfstol'
alias hdfkv='$HLOOKUP $GTHOME/langs/fkv/src/generator-gt-desc.hfstol'
alias hdhdn='$HLOOKUP $GTHOME/langs/hdn/src/generator-gt-desc.hfstol'
alias hdhun='$HLOOKUP $GTHOME/langs/hun/src/generator-gt-desc.hfstol'
alias hdipk='$HLOOKUP $GTHOME/langs/ipk/src/generator-gt-desc.hfstol'
alias hdizh='$HLOOKUP $GTHOME/langs/izh/src/generator-gt-desc.hfstol'
alias hdkal='$HLOOKUP $GTHOME/langs/kal/src/generator-gt-desc.hfstol'
alias hdkca='$HLOOKUP $GTHOME/langs/kca/src/generator-gt-desc.hfstol'
alias hdkom='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfstol'
alias hdkpv='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfstol'
alias hdlav='$HLOOKUP $GTHOME/langs/lav/src/generator-gt-desc.hfstol'
alias hdliv='$HLOOKUP $GTHOME/langs/liv/src/generator-gt-desc.hfstol'
alias hdlut='$HLOOKUP $GTHOME/langs/lut/src/generator-gt-desc.hfstol'
alias hdmdf='$HLOOKUP $GTHOME/langs/mdf/src/generator-gt-desc.hfstol'
alias hdmhr='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfstol'
alias hdmns='$HLOOKUP $GTHOME/langs/mns/src/generator-gt-desc.hfstol'
alias hdmrj='$HLOOKUP $GTHOME/langs/mrj/src/generator-gt-desc.hfstol'
alias hdmyv='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfstol'
alias hdndl='$HLOOKUP $GTHOME/langs/ndl/src/generator-gt-desc.hfstol'
alias hdnio='$HLOOKUP $GTHOME/langs/nio/src/generator-gt-desc.hfstol'
alias hdnob='$HLOOKUP $GTHOME/langs/nob/src/generator-gt-desc.hfstol'
alias hdoji='$HLOOKUP $GTHOME/langs/oji/src/generator-gt-desc.hfstol'
alias hdotw='$HLOOKUP $GTHOME/langs/otw/src/generator-gt-desc.hfstol'
alias hdolo='$HLOOKUP $GTHOME/langs/olo/src/generator-gt-desc.hfstol'
alias hdron='$HLOOKUP $GTHOME/langs/ron/src/generator-gt-desc.hfstol'
alias hdrus='$HLOOKUP $GTHOME/langs/rus/src/generator-gt-desc.hfstol'
alias hdsjd='$HLOOKUP $GTHOME/langs/sjd/src/generator-gt-desc.hfstol'
alias hdsje='$HLOOKUP $GTHOME/langs/sje/src/generator-gt-desc.hfstol'
alias hdsma='$HLOOKUP $GTHOME/langs/sma/src/generator-gt-desc.hfstol'
alias hdsme='$HLOOKUP $GTHOME/langs/sme/src/generator-gt-desc.hfstol'
alias hdsmj='$HLOOKUP $GTHOME/langs/smj/src/generator-gt-desc.hfstol'
alias hdsmn='$HLOOKUP $GTHOME/langs/smn/src/generator-gt-desc.hfstol'
alias hdsms='$HLOOKUP $GTHOME/langs/sms/src/generator-gt-desc.hfstol'
alias hdsom='$HLOOKUP $GTHOME/langs/som/src/generator-gt-desc.hfstol'
alias hdtat='$HLOOKUP $GTHOME/langs/tat/src/generator-gt-desc.hfstol'
alias hdtku='$HLOOKUP $GTHOME/langs/tku/src/generator-gt-desc.hfstol'
alias hdtuv='$HLOOKUP $GTHOME/langs/tuv/src/generator-gt-desc.hfstol'
alias hdudm='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfstol'
alias hdvep='$HLOOKUP $GTHOME/langs/vep/src/generator-gt-desc.hfstol'
alias hdvro='$HLOOKUP $GTHOME/langs/vro/src/generator-gt-desc.hfstol'
alias hdyrk='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.hfstol'


alias hukhk='$HLOOKUP $GTHOME/startup-langs/khk/src/analyser-gt-desc.hfstol'
alias hukjh='$HLOOKUP $GTHOME/startup-langs/kjh/src/analyser-gt-desc.hfstol'
alias hutyv='$HLOOKUP $GTHOME/startup-langs/tyv/src/analyser-gt-desc.hfstol'
alias huxal='$HLOOKUP $GTHOME/startup-langs/xal/src/analyser-gt-desc.hfstol'
alias huxwo='$HLOOKUP $GTHOME/startup-langs/xwo/src/analyser-gt-desc.hfstol'


alias huamh='$HLOOKUP $GTHOME/startup-langs/amh/src/analyser-gt-desc.hfstol'
alias hubak='$HLOOKUP $GTHOME/langs/bak/src/analyser-gt-desc.hfstol'
alias hubla='$HLOOKUP $GTHOME/startup-langs/bla/src/analyser-gt-desc.hfstol'
alias huevn='$HLOOKUP $GTHOME/langs/evn/src/analyser-gt-desc.hfstol'
alias husto='$HLOOKUP $GTHOME/startup-langs/sto/src/analyser-gt-desc.hfstol'
alias hutlh='$HLOOKUP $GTHOME/startup-langs/tlh/src/analyser-gt-desc.hfstol'
alias huzul='$HLOOKUP $GTHOME/startup-langs/zul/src/analyser-gt-desc.hfstol'

alias hubxr='$HLOOKUP $GTHOME/langs/bxr/src/analyser-gt-desc.hfstol'
alias huchp='$HLOOKUP $GTHOME/langs/chp/src/analyser-gt-desc.hfstol'
alias huciw='$HLOOKUP $GTHOME/langs/ciw/src/analyser-gt-desc.hfstol'
alias hucor='$HLOOKUP $GTHOME/langs/cor/src/analyser-gt-desc.hfstol'
alias hucrk='$HLOOKUP $GTHOME/langs/crk/src/analyser-gt-desc.hfstol'
alias huchr='$HLOOKUP $GTHOME/langs/chr/src/analyser-gt-desc.hfstol'
alias hudeu='$HLOOKUP $GTHOME/langs/deu/src/analyser-gt-desc.hfstol'
alias huest='$HLOOKUP $GTHOME/langs/est/src/analyser-gt-desc.hfstol'
alias hufao='$HLOOKUP $GTHOME/langs/fao/src/analyser-gt-desc.hfstol'
alias hufin='$HLOOKUP $GTHOME/langs/fin/src/analyser-gt-desc.hfstol'
alias hufkv='$HLOOKUP $GTHOME/langs/fkv/src/analyser-gt-desc.hfstol'
alias huhdn='$HLOOKUP $GTHOME/langs/hdn/src/analyser-gt-desc.hfstol'
alias huhun='$HLOOKUP $GTHOME/langs/hun/src/analyser-gt-desc.hfstol'
alias huipk='$HLOOKUP $GTHOME/langs/ipk/src/analyser-gt-desc.hfstol'
alias huizh='$HLOOKUP $GTHOME/langs/izh/src/analyser-gt-desc.hfstol'
alias hukal='$HLOOKUP $GTHOME/langs/kal/src/analyser-gt-desc.hfstol'
alias hukca='$HLOOKUP $GTHOME/langs/kca/src/analyser-gt-desc.hfstol'
alias hukom='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias hukpv='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias hulav='$HLOOKUP $GTHOME/langs/lav/src/analyser-gt-desc.hfstol'
alias huliv='$HLOOKUP $GTHOME/langs/liv/src/analyser-gt-desc.hfstol'
alias hulut='$HLOOKUP $GTHOME/langs/lut/src/analyser-gt-desc.hfstol'
alias humdf='$HLOOKUP $GTHOME/langs/mdf/src/analyser-gt-desc.hfstol'
alias humhr='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfstol'
alias humns='$HLOOKUP $GTHOME/langs/mns/src/analyser-gt-desc.hfstol'
alias humrj='$HLOOKUP $GTHOME/langs/mrj/src/analyser-gt-desc.hfstol'
alias humyv='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfstol'
alias hundl='$HLOOKUP $GTHOME/langs/ndl/src/analyser-gt-desc.hfstol'
alias hunio='$HLOOKUP $GTHOME/langs/nio/src/analyser-gt-desc.hfstol'
alias hunob='$HLOOKUP $GTHOME/langs/nob/src/analyser-gt-desc.hfstol'
alias huoji='$HLOOKUP $GTHOME/langs/oji/src/analyser-gt-desc.hfstol'
alias huotw='$HLOOKUP $GTHOME/langs/otw/src/analyser-gt-desc.hfstol'
alias huolo='$HLOOKUP $GTHOME/langs/olo/src/analyser-gt-desc.hfstol'
alias huron='$HLOOKUP $GTHOME/langs/ron/src/analyser-gt-desc.hfstol'
alias hurus='$HLOOKUP $GTHOME/langs/rus/src/analyser-gt-desc.hfstol'
alias husel='$HLOOKUP $GTHOME/langs/sel/src/analyser-gt-desc.hfstol'
alias husrs='$HLOOKUP $GTHOME/langs/srs/src/analyser-gt-desc.hfstol'
alias husjd='$HLOOKUP $GTHOME/langs/sjd/src/analyser-gt-desc.hfstol'
alias husje='$HLOOKUP $GTHOME/langs/sje/src/analyser-gt-desc.hfstol'
alias husma='$HLOOKUP $GTHOME/langs/sma/src/analyser-gt-desc.hfstol'
alias husme='$HLOOKUP $GTHOME/langs/sme/src/analyser-gt-desc.hfstol'
alias husmedis='$HLOOKUP $GTHOME/langs/sme/src/analyser-disamb-gt-desc.hfstol'
alias husmj='$HLOOKUP $GTHOME/langs/smj/src/analyser-gt-desc.hfstol'
alias husmn='$HLOOKUP $GTHOME/langs/smn/src/analyser-gt-desc.hfstol'
alias husms='$HLOOKUP $GTHOME/langs/sms/src/analyser-gt-desc.hfstol'
alias husom='$HLOOKUP $GTHOME/langs/som/src/analyser-gt-desc.hfstol'
alias hutat='$HLOOKUP $GTHOME/langs/tat/src/analyser-gt-desc.hfstol'
alias hutku='$HLOOKUP $GTHOME/langs/tku/src/analyser-gt-desc.hfstol'
alias hutuv='$HLOOKUP $GTHOME/langs/tuv/src/analyser-gt-desc.hfstol'
alias huudm='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfstol'
alias huvep='$HLOOKUP $GTHOME/langs/vep/src/analyser-gt-desc.hfstol'
alias huvro='$HLOOKUP $GTHOME/langs/vro/src/analyser-gt-desc.hfstol'
alias huyrk='$HLOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.hfstol'


# Normative variants:
alias hdamhNorm='$HLOOKUP $GTHOME/startup-langs/amh/src/generator-gt-norm.hfstol'
alias hdbakNorm='$HLOOKUP $GTHOME/langs/bak/src/generator-gt-norm.hfstol'
alias hdblaNorm='$HLOOKUP $GTHOME/startup-langs/bla/src/generator-gt-norm.hfstol'
alias hdevnNorm='$HLOOKUP $GTHOME/langs/evn/src/generator-gt-norm.hfstol'
alias hdstoNorm='$HLOOKUP $GTHOME/startup-langs/sto/src/generator-gt-norm.hfstol'
alias hdselNorm='$HLOOKUP $GTHOME/startup-langs/sel/src/generator-gt-norm.hfstol'
alias hdtlhNorm='$HLOOKUP $GTHOME/startup-langs/tlh/src/generator-gt-norm.hfstol'
alias hdzulNorm='$HLOOKUP $GTHOME/startup-langs/zul/src/generator-gt-norm.hfstol'

alias hdbxrNorm='$HLOOKUP $GTHOME/langs/bxr/src/generator-gt-norm.hfstol'
alias hdchpNorm='$HLOOKUP $GTHOME/langs/chp/src/generator-gt-norm.hfstol'
alias hdciwNorm='$HLOOKUP $GTHOME/langs/ciw/src/generator-gt-norm.hfstol'
alias hdcorNorm='$HLOOKUP $GTHOME/langs/cor/src/generator-gt-norm.hfstol'
alias hdcrkNorm='$HLOOKUP $GTHOME/langs/crk/src/generator-gt-norm.hfstol'
alias hdchrNorm='$HLOOKUP $GTHOME/langs/chr/src/generator-gt-norm.hfstol'
alias hddeuNorm='$HLOOKUP $GTHOME/langs/deu/src/generator-gt-norm.hfstol'
alias hdestNorm='$HLOOKUP $GTHOME/langs/est/src/generator-gt-norm.hfstol'
alias hdfaoNorm='$HLOOKUP $GTHOME/langs/fao/src/generator-gt-norm.hfstol'
alias hdfinNorm='$HLOOKUP $GTHOME/langs/fin/src/generator-gt-norm.hfstol'
alias hdfkvNorm='$HLOOKUP $GTHOME/langs/fkv/src/generator-gt-norm.hfstol'
alias hdhdnNorm='$HLOOKUP $GTHOME/langs/hdn/src/generator-gt-norm.hfstol'
alias hdhunNorm='$HLOOKUP $GTHOME/langs/hun/src/generator-gt-norm.hfstol'
alias hdipkNorm='$HLOOKUP $GTHOME/langs/ipk/src/generator-gt-norm.hfstol'
alias hdizhNorm='$HLOOKUP $GTHOME/langs/izh/src/generator-gt-norm.hfstol'
alias hdkalNorm='$HLOOKUP $GTHOME/langs/kal/src/generator-gt-norm.hfstol'
alias hdkcaNorm='$HLOOKUP $GTHOME/langs/kca/src/generator-gt-norm.hfstol'
alias hdkomNorm='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfstol'
alias hdkpvNorm='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfstol'
alias hdlavNorm='$HLOOKUP $GTHOME/langs/lav/src/generator-gt-norm.hfstol'
alias hdlivNorm='$HLOOKUP $GTHOME/langs/liv/src/generator-gt-norm.hfstol'
alias hdlutNorm='$HLOOKUP $GTHOME/langs/lut/src/generator-gt-norm.hfstol'
alias hdmdfNorm='$HLOOKUP $GTHOME/langs/mdf/src/generator-gt-norm.hfstol'
alias hdmhrNorm='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfstol'
alias hdmnsNorm='$HLOOKUP $GTHOME/langs/mns/src/generator-gt-norm.hfstol'
alias hdmrjNorm='$HLOOKUP $GTHOME/langs/mrj/src/generator-gt-norm.hfstol'
alias hdmyvNorm='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfstol'
alias hdndlNorm='$HLOOKUP $GTHOME/langs/ndl/src/generator-gt-norm.hfstol'
alias hdnioNorm='$HLOOKUP $GTHOME/langs/nio/src/generator-gt-norm.hfstol'
alias hdnobNorm='$HLOOKUP $GTHOME/langs/nob/src/generator-gt-norm.hfstol'
alias hdojiNorm='$HLOOKUP $GTHOME/langs/oji/src/generator-gt-norm.hfstol'
alias hdotwNorm='$HLOOKUP $GTHOME/langs/otw/src/generator-gt-norm.hfstol'
alias hdronNorm='$HLOOKUP $GTHOME/langs/ron/src/generator-gt-norm.hfstol'
alias hdrusNorm='$HLOOKUP $GTHOME/langs/rus/src/generator-gt-norm.hfstol'
alias hdsjdNorm='$HLOOKUP $GTHOME/langs/sjd/src/generator-gt-norm.hfstol'
alias hdsjeNorm='$HLOOKUP $GTHOME/langs/sje/src/generator-gt-norm.hfstol'
alias hdsmaNorm='$HLOOKUP $GTHOME/langs/sma/src/generator-gt-norm.hfstol'
alias hdsmeNorm='$HLOOKUP $GTHOME/langs/sme/src/generator-gt-norm.hfstol'
alias hdsmjNorm='$HLOOKUP $GTHOME/langs/smj/src/generator-gt-norm.hfstol'
alias hdsmnNorm='$HLOOKUP $GTHOME/langs/smn/src/generator-gt-norm.hfstol'
alias hdsmsNorm='$HLOOKUP $GTHOME/langs/sms/src/generator-gt-norm.hfstol'
alias hdsomNorm='$HLOOKUP $GTHOME/langs/som/src/generator-gt-norm.hfstol'
alias hdtatNorm='$HLOOKUP $GTHOME/langs/tat/src/generator-gt-norm.hfstol'
alias hdtkuNorm='$HLOOKUP $GTHOME/langs/tku/src/generator-gt-norm.hfstol'
alias hdtuvNorm='$HLOOKUP $GTHOME/langs/tuv/src/generator-gt-norm.hfstol'
alias hdudmNorm='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfstol'
alias hdvepNorm='$HLOOKUP $GTHOME/langs/vep/src/generator-gt-norm.hfstol'
alias hdvroNorm='$HLOOKUP $GTHOME/langs/vro/src/generator-gt-norm.hfstol'
alias hdyrkNorm='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-norm.hfstol'



alias huamhNorm='$HLOOKUP $GTHOME/startup-langs/amh/src/analyser-gt-norm.hfstol'
alias hubakNorm='$HLOOKUP $GTHOME/langs/bak/src/analyser-gt-norm.hfstol'
alias hublaNorm='$HLOOKUP $GTHOME/startup-langs/bla/src/analyser-gt-norm.hfstol'
alias huevnNorm='$HLOOKUP $GTHOME/langs/evn/src/analyser-gt-norm.hfstol'
alias huselNorm='$HLOOKUP $GTHOME/startup-langs/sel/src/analyser-gt-norm.hfstol'
alias hustoNorm='$HLOOKUP $GTHOME/startup-langs/sto/src/analyser-gt-norm.hfstol'
alias huzulNorm='$HLOOKUP $GTHOME/startup-langs/zul/src/analyser-gt-norm.hfstol'
alias hutlhNorm='$HLOOKUP $GTHOME/startup-langs/tlh/src/analyser-gt-norm.hfstol'

alias hubxrNorm='$HLOOKUP $GTHOME/langs/bxr/src/analyser-gt-norm.hfstol'
alias huchpNorm='$HLOOKUP $GTHOME/langs/chp/src/analyser-gt-norm.hfstol'
alias huciwNorm='$HLOOKUP $GTHOME/langs/ciw/src/analyser-gt-norm.hfstol'
alias hucorNorm='$HLOOKUP $GTHOME/langs/cor/src/analyser-gt-norm.hfstol'
alias hucrkNorm='$HLOOKUP $GTHOME/langs/crk/src/analyser-gt-norm.hfstol'
alias huchrNorm='$HLOOKUP $GTHOME/langs/chr/src/analyser-gt-norm.hfstol'
alias huestNorm='$HLOOKUP $GTHOME/langs/est/src/analyser-gt-norm.hfstol'
alias hufaoNorm='$HLOOKUP $GTHOME/langs/fao/src/analyser-gt-norm.hfstol'
alias hufinNorm='$HLOOKUP $GTHOME/langs/fin/src/analyser-gt-norm.hfstol'
alias hufkvNorm='$HLOOKUP $GTHOME/langs/fkv/src/analyser-gt-norm.hfstol'
alias huhdnNorm='$HLOOKUP $GTHOME/langs/hdn/src/analyser-gt-norm.hfstol'
alias huhunNorm='$HLOOKUP $GTHOME/langs/hun/src/analyser-gt-norm.hfstol'
alias huipkNorm='$HLOOKUP $GTHOME/langs/ipk/src/analyser-gt-norm.hfstol'
alias huizhNorm='$HLOOKUP $GTHOME/langs/izh/src/analyser-gt-norm.hfstol'
alias hukalNorm='$HLOOKUP $GTHOME/langs/kal/src/analyser-gt-norm.hfstol'
alias hukcaNorm='$HLOOKUP $GTHOME/langs/kca/src/analyser-gt-norm.hfstol'
alias hukomNorm='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias hukpvNorm='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias hulavNorm='$HLOOKUP $GTHOME/langs/lav/src/analyser-gt-norm.hfstol'
alias hulivNorm='$HLOOKUP $GTHOME/langs/liv/src/analyser-gt-norm.hfstol'
alias hulutNorm='$HLOOKUP $GTHOME/langs/lut/src/analyser-gt-norm.hfstol'
alias humdfNorm='$HLOOKUP $GTHOME/langs/mdf/src/analyser-gt-norm.hfstol'
alias humhrNorm='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfstol'
alias humnsNorm='$HLOOKUP $GTHOME/langs/mns/src/analyser-gt-norm.hfstol'
alias humrjNorm='$HLOOKUP $GTHOME/langs/mrj/src/analyser-gt-norm.hfstol'
alias humyvNorm='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfstol'
alias hundlNorm='$HLOOKUP $GTHOME/langs/ndl/src/analyser-gt-norm.hfstol'
alias hunioNorm='$HLOOKUP $GTHOME/langs/nio/src/analyser-gt-norm.hfstol'
alias hunobNorm='$HLOOKUP $GTHOME/langs/nob/src/analyser-gt-norm.hfstol'
alias huojiNorm='$HLOOKUP $GTHOME/langs/oji/src/analyser-gt-norm.hfstol'
alias huotwNorm='$HLOOKUP $GTHOME/langs/otw/src/analyser-gt-norm.hfstol'
alias huoloNorm='$HLOOKUP $GTHOME/langs/olo/src/analyser-gt-norm.hfstol'
alias huronNorm='$HLOOKUP $GTHOME/langs/ron/src/analyser-gt-norm.hfstol'
alias hurusNorm='$HLOOKUP $GTHOME/langs/rus/src/analyser-gt-norm.hfstol'
alias husjdNorm='$HLOOKUP $GTHOME/langs/sjd/src/analyser-gt-norm.hfstol'
alias husjeNorm='$HLOOKUP $GTHOME/langs/sje/src/analyser-gt-norm.hfstol'
alias husmaNorm='$HLOOKUP $GTHOME/langs/sma/src/analyser-gt-norm.hfstol'
alias husmeNorm='$HLOOKUP $GTHOME/langs/sme/src/analyser-gt-norm.hfstol'
alias husmjNorm='$HLOOKUP $GTHOME/langs/smj/src/analyser-gt-norm.hfstol'
alias husmnNorm='$HLOOKUP $GTHOME/langs/smn/src/analyser-gt-norm.hfstol'
alias husmsNorm='$HLOOKUP $GTHOME/langs/sms/src/analyser-gt-norm.hfstol'
alias husomNorm='$HLOOKUP $GTHOME/langs/som/src/analyser-gt-norm.hfstol'
alias hutatNorm='$HLOOKUP $GTHOME/langs/tat/src/analyser-gt-norm.hfstol'
alias hutkuNorm='$HLOOKUP $GTHOME/langs/tku/src/analyser-gt-norm.hfstol'
alias hutuvNorm='$HLOOKUP $GTHOME/langs/tuv/src/analyser-gt-norm.hfstol'
alias huudmNorm='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfstol'
alias huvepNorm='$HLOOKUP $GTHOME/langs/vep/src/analyser-gt-norm.hfstol'
alias huvroNorm='$HLOOKUP $GTHOME/langs/vro/src/analyser-gt-norm.hfstol'
alias huyrkNorm='$HLOOKUP $GTHOME/langs/yrk/src/analyser-gt-norm.hfstol'



# Other languages:
alias   hdmh='$HLOOKUP $GTHOME/st/amh/bin/iamh.hfst.ol'
alias   hdces='$HLOOKUP $GTHOME/st/ces/bin/ices.hfst.ol'
alias   hdeng='$HLOOKUP $GTHOME/st/eng/bin/ieng.hfst.ol'
alias   hdiku='$HLOOKUP $GTHOME/st/iku/bin/iiku.hfst.ol'
alias   hdnno='$HLOOKUP $GTHOME/st/nno/bin/inno.hfst.ol'
alias   hdnon='$HLOOKUP $GTHOME/st/non/bin/inon.hfst.ol'

alias   huamh='$HLOOKUP $GTHOME/st/amh/bin/amh.hfst.ol'
alias   huces='$HLOOKUP $GTHOME/st/ces/bin/ces.hfst.ol'
alias   hueng='$HLOOKUP $GTHOME/st/eng/bin/eng.hfst.ol'
alias   huiku='$HLOOKUP $GTHOME/st/iku/bin/iku.hfst.ol'
alias   hunno='$HLOOKUP $GTHOME/st/nno/bin/nno.hfst.ol'
alias   hunon='$HLOOKUP $GTHOME/st/non/bin/non.hfst.ol'


# Other FU languages:


# Cyrillic aliases:
# 'ч' = key h on the Russian Phonetic keyboard (for Hfst)
alias чуком='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias чглщь='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias чумчр='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfstol'
alias чумыв='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfstol'
alias чуудм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfstol'
alias чуырк='$HLOOKUP $GTHOME/langs/yrk/src/analyser-gt-desc.hfstol'
alias чурус='$HLOOKUP $GTHOME/langs/rus/src/analyser-gt-desc.hfstol'

alias чдком='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfstol'
alias чдмчр='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfstol'
alias чдмыв='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfstol'
alias чдудм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfstol'
alias чдырк='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-desc.hfstol'
alias чдрус='$HLOOKUP $GTHOME/langs/rus/src/generator-gt-desc.hfstol'

alias чдкомНорм='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfstol'
alias чдмчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfstol'
alias чдмывНорм='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfstol'
alias чдудмНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfstol'
alias чдыркНорм='$HLOOKUP $GTHOME/langs/yrk/src/generator-gt-norm.hfstol'
alias чдрусНорм='$HLOOKUP $GTHOME/langs/rus/src/generator-gt-norm.hfstol'

alias чукомНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias чглщьНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias чумчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfstol'
alias чумывНорм='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfstol'
alias чуудмНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfstol'
alias чурусНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfstol'

# 'х' = cyrillic h (for Hfst)
alias хуком='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias хглщь='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-desc.hfstol'
alias хумчр='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-desc.hfstol'
alias хумыв='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-desc.hfstol'
alias хуудм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfstol'
alias хуырк='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-desc.hfstol'

alias хдком='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-desc.hfstol'
alias хдмчр='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-desc.hfstol'
alias хдмыв='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-desc.hfstol'
alias хдудм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfstol'
alias хдырк='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-desc.hfstol'

alias хдкомНорм='$HLOOKUP $GTHOME/langs/kpv/src/generator-gt-norm.hfstol'
alias хдмчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/generator-gt-norm.hfstol'
alias хдмывНорм='$HLOOKUP $GTHOME/langs/myv/src/generator-gt-norm.hfstol'
alias хдудмНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfstol'
alias хдыркНорм='$HLOOKUP $GTHOME/langs/udm/src/generator-gt-norm.hfstol'

alias хукомНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias хглщьНорм='$HLOOKUP $GTHOME/langs/kpv/src/analyser-gt-norm.hfstol'
alias хумчрНорм='$HLOOKUP $GTHOME/langs/mhr/src/analyser-gt-norm.hfstol'
alias хумывНорм='$HLOOKUP $GTHOME/langs/myv/src/analyser-gt-norm.hfstol'
alias хуудмНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfstol'
alias хуыркНорм='$HLOOKUP $GTHOME/langs/udm/src/analyser-gt-norm.hfstol'

# Bilingual transducers:
alias hfitswe='$HLOOKUP $GTHOME/kvensk/fitswe/bin/fitswe.hfst.ol'
alias hfkvnob='$HLOOKUP $GTHOME/kvensk/bin/fkvnob.hfst.ol'
alias hkaldan='$HLOOKUP $GTHOME/words/dicts/kaldan/bin/kaldan.hfst.ol'
alias hkaldic='$HLOOKUP $GTHOME/words/dicts/kaldan/bin/kaldic.hfst.ol'
alias hkaleng='$HLOOKUP $GTHOME/words/dicts/kaleng/bin/kaleng.hfst.ol'
alias hnobfkv='$HLOOKUP $GTHOME/kvensk/bin/nobfkv.hfst.ol'
alias hnobsme='$HLOOKUP $GTHOME/words/dicts/smenob/bin/ismenob.hfst.ol'
alias hsmenob='$HLOOKUP $GTHOME/words/dicts/smenob/bin/smenob.hfst.ol'
alias hsmesmj='$HLOOKUP $GTHOME/words/dicts/smesmj/bin/smesmj.hfst.ol'
alias hsmjsme='$HLOOKUP $GTHOME/words/dicts/smesmj/bin/smjsme.hfst.ol'
alias hswefit='$HLOOKUP $GTHOME/kvensk/swefit/bin/swefit.hfst.ol'

# Other transducers
alias ugeo='$LOOKUP $GTHOME/words/dicts/smi/geo/bin/geo.fst'


# Direct sentence analysis:

alias kpvtoka="hfst-tokenise --giella-cg $GTHOME/langs/kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               sed 's/ <W:0.0000000000>//g;'"
alias kpvtoks="hfst-tokenise --giella-cg $GTHOME/langs/kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               vislcg3 -g $GTHOME/langs/kpv/src/syntax/disambiguator.cg3 | \
               sed 's/ <W:0.0000000000>//g;'"
alias kpvtokst="hfst-tokenise --giella-cg $GTHOME/langs/kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               vislcg3 -g $GTHOME/langs/kpv/src/syntax/disambiguator.cg3 -t | \
               sed 's/ <W:0.0000000000>//g;'"

alias myvtoka="hfst-tokenise --giella-cg $GTHOME/langs/myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \  
               sed 's/ <W:0.0000000000>//g;'"
alias myvtoks="hfst-tokenise --giella-cg $GTHOME/langs/myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst |  vislcg3 -g $GTHOME/langs/myv/src/syntax/disambiguator.cg3 | \  
               sed 's/ <W:0.0000000000>//g;'"
alias myvtokst="hfst-tokenise --giella-cg $GTHOME/langs/myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | vislcg3 -g $GTHOME/langs/myv/src/syntax/disambiguator.cg3 -t | \  
               sed 's/ <W:0.0000000000>//g;'"


alias bakdep="sent-proc.sh -l bak -s dep"
alias bakdept="sent-proc.sh -l bak -s dep -t"
alias bakdis="sent-proc.sh -l bak -s dis"
alias bakdist="sent-proc.sh -l bak -s dis -t"

alias bladep="sent-proc.sh -l bla -s dep"
alias bladept="sent-proc.sh -l bla -s dep -t"
alias bladis="sent-proc.sh -l bla -s dis"
alias bladist="sent-proc.sh -l bla -s dis -t"

alias chpdep="sent-proc.sh -l chp -s dep"
alias chpdept="sent-proc.sh -l chp -s dep -t"
alias chpdis="sent-proc.sh -l chp -s dis"
alias chpdist="sent-proc.sh -l chp -s dis -t"

alias ciwdep="sent-proc.sh -l ciw -s dep"
alias ciwdept="sent-proc.sh -l ciw -s dep -t"
alias ciwdis="sent-proc.sh -l ciw -s dis"
alias ciwdist="sent-proc.sh -l ciw -s dis -t"

alias cordep="sent-proc.sh -l cor -s dep"
alias cordept="sent-proc.sh -l cor -s dep -t"
alias cordis="sent-proc.sh -l cor -s dis"
alias cordist="sent-proc.sh -l cor -s dis -t"

alias crkdep="sent-proc.sh -l crk -s dep"
alias crkdept="sent-proc.sh -l crk -s dep -t"
alias crkdis="sent-proc.sh -l crk -s dis"
alias crkdist="sent-proc.sh -l crk -s dis -t"

alias chrdep="sent-proc.sh -l chr -s dep"
alias chrdept="sent-proc.sh -l chr -s dep -t"
alias chrdis="sent-proc.sh -l chr -s dis"
alias chrdist="sent-proc.sh -l chr -s dis -t"

alias estdep="sent-proc.sh -l est -s dep"
alias estdept="sent-proc.sh -l est -s dep -t"
alias estdis="sent-proc.sh -l est -s dis"
alias estdist="sent-proc.sh -l est -s dis -t"

alias evndep="sent-proc.sh -l evn -s dep"
alias evndept="sent-proc.sh -l evn -s dep -t"
alias evndis="sent-proc.sh -l evn -s dis"
alias evndist="sent-proc.sh -l evn -s dis -t"

alias faodep="sent-proc.sh -l fao -s dep"
alias faodept="sent-proc.sh -l fao -s dep -t"
alias faodis="sent-proc.sh -l fao -s dis"
alias faodist="sent-proc.sh -l fao -s dis -t"

alias findep="sent-proc.sh -l fin -s dep"
alias findept="sent-proc.sh -l fin -s dep -t"
alias findis="sent-proc.sh -l fin -s dis"
alias findist="sent-proc.sh -l fin -s dis -t"

alias fkvdep="sent-proc.sh -l fkv -s dep"
alias fkvdept="sent-proc.sh -l fkv -s dep -t"
alias fkvdis="sent-proc.sh -l fkv -s dis"
alias fkvdist="sent-proc.sh -l fkv -s dis -t"

alias ipkdep="sent-proc.sh -l ipk -s dep"
alias ipkdept="sent-proc.sh -l ipk -s dep -t"
alias ipkdis="sent-proc.sh -l ipk -s dis"
alias ipkdist="sent-proc.sh -l ipk -s dis -t"

alias hdndep="sent-proc.sh -l hdn -s dep"
alias hdndept="sent-proc.sh -l hdn -s dep -t"
alias hdndis="sent-proc.sh -l hdn -s dis"
alias hdndist="sent-proc.sh -l hdn -s dis -t"

alias hundep="sent-proc.sh -l hun -s dep"
alias hundept="sent-proc.sh -l hun -s dep -t"
alias hundis="sent-proc.sh -l hun -s dis"
alias hundist="sent-proc.sh -l hun -s dis -t"

alias izhdep="sent-proc.sh -l izh -s dep"
alias izhdept="sent-proc.sh -l izh -s dep -t"
alias izhdis="sent-proc.sh -l izh -s dis"
alias izhdist="sent-proc.sh -l izh -s dis -t"

alias kaldep="sent-proc.sh -l kal -s dep"
alias kaldept="sent-proc.sh -l kal -s dep -t"
alias kaldis="sent-proc.sh -l kal -s dis"
alias kaldist="sent-proc.sh -l kal -s dis -t"

alias kcadep="sent-proc.sh -l kca -s dep"
alias kcadept="sent-proc.sh -l kca -s dep -t"
alias kcadis="sent-proc.sh -l kca -s dis"
alias kcadist="sent-proc.sh -l kca -s dis -t"

alias kpvdep="sent-proc.sh  -l kpv -s dep"
alias kpvdept="sent-proc.sh -l kpv -s dep -t"
alias kpvdis="sent-proc.sh  -l kpv -s dis"
alias kpvdist="sent-proc.sh -l kpv -s dis -t"

alias lavdep="sent-proc.sh -l lav -s dep"
alias lavdept="sent-proc.sh -l lav -s dep -t"
alias lavdis="sent-proc.sh -l lav -s dis"
alias lavdist="sent-proc.sh -l lav -s dis -t"

alias livdep="sent-proc.sh -l liv -s dep"
alias livdept="sent-proc.sh -l liv -s dep -t"
alias livdis="sent-proc.sh -l liv -s dis"
alias livdist="sent-proc.sh -l liv -s dis -t"

alias mdfdep="sent-proc.sh -l mdf -s dep"
alias mdfdept="sent-proc.sh -l mdf -s dep -t"
alias mdfdis="sent-proc.sh -l mdf -s dis"
alias mdfdist="sent-proc.sh -l mdf -s dis -t"

alias mhrdep="sent-proc.sh -l mhr -s dep"
alias mhrdept="sent-proc.sh -l mhr -s dep -t"
alias mhrdis="sent-proc.sh -l mhr -s dis"
alias mhrdist="sent-proc.sh -l mhr -s dis -t"

alias mrjdep="sent-proc.sh -l mrj -s dep"
alias mrjdept="sent-proc.sh -l mrj -s dep -t"
alias mrjdis="sent-proc.sh -l mrj -s dis"
alias mrjdist="sent-proc.sh -l mrj -s dis -t"

alias myvdep="sent-proc.sh -l myv -s dep"
alias myvdept="sent-proc.sh -l myv -s dep -t"
alias myvdis="sent-proc.sh -l myv -s dis"
alias myvdist="sent-proc.sh -l myv -s dis -t"

alias ndldep="sent-proc.sh -l ndl -s dep"
alias ndldept="sent-proc.sh -l ndl -s dep -t"
alias ndldis="sent-proc.sh -l ndl -s dis"
alias ndldist="sent-proc.sh -l ndl -s dis -t"

alias niodep="sent-proc.sh -l nio -s dep"
alias niodept="sent-proc.sh -l nio -s dep -t"
alias niodis="sent-proc.sh -l nio -s dis"
alias niodist="sent-proc.sh -l nio -s dis -t"

alias nobdep="sent-proc.sh -l nob -s dep"
alias nobdept="sent-proc.sh -l nob -s dep -t"
alias nobdis="sent-proc.sh -l nob -s dis"
alias nobdist="sent-proc.sh -l nob -s dis -t"

alias ojidep="sent-proc.sh -l oji -s dep"
alias ojidept="sent-proc.sh -l oji -s dep -t"
alias ojidis="sent-proc.sh -l oji -s dis"
alias ojidist="sent-proc.sh -l oji -s dis -t"

alias otwdep="sent-proc.sh -l otw -s dep"
alias otwdept="sent-proc.sh -l otw -s dep -t"
alias otwdis="sent-proc.sh -l otw -s dis"
alias otwdist="sent-proc.sh -l otw -s dis -t"

alias olodep="sent-proc.sh -l olo -s dep"
alias olodept="sent-proc.sh -l olo -s dep -t"
alias olodis="sent-proc.sh -l olo -s dis"
alias olodist="sent-proc.sh -l olo -s dis -t"

alias rondep="sent-proc.sh -l ron -s dep"
alias rondept="sent-proc.sh -l ron -s dep -t"
alias rondis="sent-proc.sh -l ron -s dis"
alias rondist="sent-proc.sh -l ron -s dis -t"

alias rusdep="sent-proc.sh -l rus -s dep"
alias rusdept="sent-proc.sh -l rus -s dep -t"
alias rusdis="sent-proc.sh -l rus -s dis"
alias rusdist="sent-proc.sh -l rus -s dis -t"

alias sjddep="sent-proc.sh -l sjd -s dep"
alias sjddept="sent-proc.sh -l sjd -s dep -t"
alias sjddis="sent-proc.sh -l sjd -s dis"
alias sjddist="sent-proc.sh -l sjd -s dis -t"

alias sjedep="sent-proc.sh -l sje -s dep"
alias sjedept="sent-proc.sh -l sje -s dep -t"
alias sjedis="sent-proc.sh -l sje -s dis"
alias sjedist="sent-proc.sh -l sje -s dis -t"

alias smadep="sent-proc.sh -l sma -s dep"
alias smadept="sent-proc.sh -l sma -s dep -t"
alias smadis="sent-proc.sh -l sma -s dis"
alias smadist="sent-proc.sh -l sma -s dis -t"

alias smedep="sent-proc.sh -s dep"
alias smedept="sent-proc.sh -s dep -t"
alias smedis="sent-proc.sh -s dis"
alias smedist="sent-proc.sh -s dis -t"
alias smesyn="sent-proc.sh -s syn"
alias smesynt="sent-proc.sh -s syn -t"

alias smjdep="sent-proc.sh -l smj -s dep"
alias smjdept="sent-proc.sh -l smj -s dep -t"
alias smjdis="sent-proc.sh -l smj -s dis"
alias smjdist="sent-proc.sh -l smj -s dis -t"

alias smndep="sent-proc.sh -l smn -s dep"
alias smndept="sent-proc.sh -l smn -s dep -t"
alias smndis="sent-proc.sh -l smn -s dis"
alias smndist="sent-proc.sh -l smn -s dis -t"

alias smsdep="sent-proc.sh -l sms -s dep"
alias smsdept="sent-proc.sh -l sms -s dep -t"
alias smsdis="sent-proc.sh -l sms -s dis"
alias smsdist="sent-proc.sh -l sms -s dis -t"

alias somdep="sent-proc.sh -l som -s dep"
alias somdept="sent-proc.sh -l som -s dep -t"
alias somdis="sent-proc.sh -l som -s dis"
alias somdist="sent-proc.sh -l som -s dis -t"

alias stodep="sent-proc.sh -l sto -s dep"
alias stodept="sent-proc.sh -l sto -s dep -t"
alias stodis="sent-proc.sh -l sto -s dis"
alias stodist="sent-proc.sh -l sto -s dis -t"

alias tkudep="sent-proc.sh -l tku -s dep"
alias tkudept="sent-proc.sh -l tku -s dep -t"
alias tkudis="sent-proc.sh -l tku -s dis"
alias tkudist="sent-proc.sh -l tku -s dis -t"

alias udmdep="sent-proc.sh -l udm -s dep"
alias udmdept="sent-proc.sh -l udm -s dep -t"
alias udmdis="sent-proc.sh -l udm -s dis"
alias udmdist="sent-proc.sh -l udm -s dis -t"

alias vepdep="sent-proc.sh -l vep -s dep"
alias vepdept="sent-proc.sh -l vep -s dep -t"
alias vepdis="sent-proc.sh -l vep -s dis"
alias vepdist="sent-proc.sh -l vep -s dis -t"

alias vrodep="sent-proc.sh -l vro -s dep"
alias vrodept="sent-proc.sh -l vro -s dep -t"
alias vrodis="sent-proc.sh -l vro -s dis"
alias vrodist="sent-proc.sh -l vro -s dis -t"

alias yrkdep="sent-proc.sh -l yrk -s dep"
alias yrkdept="sent-proc.sh -l yrk -s dep -t"
alias yrkdis="sent-proc.sh -l yrk -s dis"
alias yrkdist="sent-proc.sh -l yrk -s dis -t"

alias zuldep="sent-proc.sh -l zul -s dep"
alias zuldept="sent-proc.sh -l zul -s dep -t"
alias zuldis="sent-proc.sh -l zul -s dis"
alias zuldist="sent-proc.sh -l zul -s dis -t"

