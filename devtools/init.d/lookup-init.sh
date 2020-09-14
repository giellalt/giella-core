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

alias deng='$LOOKUP $GTLANGS/lang-eng/src/generator-gt-desc.xfst'
alias dest2='$LOOKUP $GTLANGS/lang-est/src/generator-gt-desc.xfst'


alias dapu='$LOOKUP $GTLANGS/lang-apu/src/generator-gt-desc.xfst'
alias dkhk='$LOOKUP $GTLANGS/lang-khk/src/generator-gt-desc.xfst'
alias dkjh='$LOOKUP $GTLANGS/lang-kjh/src/generator-gt-desc.xfst'
alias dtyv='$LOOKUP $GTLANGS/lang-tyv/src/generator-gt-desc.xfst'
alias dxal='$LOOKUP $GTLANGS/lang-xal/src/generator-gt-desc.xfst'
alias dxwo='$LOOKUP $GTLANGS/lang-xwo/src/generator-gt-desc.xfst'

alias damh='$LOOKUP $GTLANGS/lang-amh/src/generator-gt-desc.xfst'
alias dbak='$LOOKUP $GTLANGS/lang-bak/src/generator-gt-desc.xfst'
alias dbla='$LOOKUP $GTLANGS/lang-bla/src/generator-gt-desc.xfst'
alias devn='$LOOKUP $GTLANGS/lang-evn/src/generator-gt-desc.xfst'
alias dsel='$LOOKUP $GTLANGS/lang-sel/src/generator-gt-desc.xfst'
alias dsrs='$LOOKUP $GTLANGS/lang-srs/src/generator-gt-desc.xfst'
alias dsto='$LOOKUP $GTLANGS/lang-sto/src/generator-gt-desc.xfst'
alias dtlh='$LOOKUP $GTLANGS/lang-tlh/src/generator-gt-desc.xfst'
alias dzul='$LOOKUP $GTLANGS/lang-zul/src/generator-gt-desc.xfst'

alias dbxr='$LOOKUP $GTLANGS/lang-bxr/src/generator-gt-desc.xfst'
alias dchp='$LOOKUP $GTLANGS/lang-chp/src/generator-gt-desc.xfst'
alias dciw='$LOOKUP $GTLANGS/lang-ciw/src/generator-gt-desc.xfst'
alias dcor='$LOOKUP $GTLANGS/lang-cor/src/generator-gt-desc.xfst'
alias dcrk='$LOOKUP $GTLANGS/lang-crk/src/generator-gt-desc.xfst'
alias dchp='$LOOKUP $GTLANGS/lang-chp/src/generator-gt-desc.xfst'
alias dchr='$LOOKUP $GTLANGS/lang-chr/src/generator-gt-desc.xfst'
alias ddeu='$LOOKUP $GTLANGS/lang-deu/src/generator-gt-desc.xfst'
alias dest='$LOOKUP $GTLANGS/lang-est/src/generator-gt-desc.xfst'
alias dfao='$LOOKUP $GTLANGS/lang-fao/src/generator-gt-desc.xfst'
alias dfin='$LOOKUP $GTLANGS/lang-fin/src/generator-gt-desc.xfst'
alias dfkv='$LOOKUP $GTLANGS/lang-fkv/src/generator-gt-desc.xfst'
alias dhdn='$LOOKUP $GTLANGS/lang-hdn/src/generator-gt-desc.xfst'
alias dhun='$LOOKUP $GTLANGS/lang-hun/src/generator-gt-desc.xfst'
alias dipk='$LOOKUP $GTLANGS/lang-ipk/src/generator-gt-desc.xfst'
alias dizh='$LOOKUP $GTLANGS/lang-izh/src/generator-gt-desc.xfst'
alias dkal='$LOOKUP $GTLANGS/lang-kal/src/generator-gt-desc.xfst'
alias dkca='$LOOKUP $GTLANGS/lang-kca/src/generator-gt-desc.xfst'
alias dkoi='$LOOKUP $GTLANGS/lang-koi/src/generator-gt-desc.xfst'
alias dkom='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.xfst'
alias dkpv='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.xfst'
alias dlav='$LOOKUP $GTLANGS/lang-lav/src/generator-gt-desc.xfst'
alias dliv='$LOOKUP $GTLANGS/lang-liv/src/generator-gt-desc.xfst'
alias dmdf='$LOOKUP $GTLANGS/lang-mdf/src/generator-gt-desc.xfst'
alias dmhr='$LOOKUP $GTLANGS/lang-mhr/src/generator-gt-desc.xfst'
alias dmns='$LOOKUP $GTLANGS/lang-mns/src/generator-gt-desc.xfst'
alias dmrj='$LOOKUP $GTLANGS/lang-mrj/src/generator-gt-desc.xfst'
alias dmyv='$LOOKUP $GTLANGS/lang-myv/src/generator-gt-desc.xfst'
alias dndl='$LOOKUP $GTLANGS/lang-ndl/src/generator-gt-desc.xfst'
alias dnio='$LOOKUP $GTLANGS/lang-nio/src/generator-gt-desc.xfst'
alias dnob='$LOOKUP $GTLANGS/lang-nob/src/generator-gt-desc.xfst'
alias dolo='$LOOKUP $GTLANGS/lang-olo/src/generator-gt-desc.xfst'
alias doji='$LOOKUP $GTLANGS/lang-oji/src/generator-gt-desc.xfst'
alias dotw='$LOOKUP $GTLANGS/lang-otw/src/generator-gt-desc.xfst'
alias dron='$LOOKUP $GTLANGS/lang-ron/src/generator-gt-desc.xfst'
alias drus='$LOOKUP $GTLANGS/lang-rus/src/generator-gt-desc.xfst'
alias dsjd='$LOOKUP $GTLANGS/lang-sjd/src/generator-gt-desc.xfst'
alias dsje='$LOOKUP $GTLANGS/lang-sje/src/generator-gt-desc.xfst'
alias dsma='$LOOKUP $GTLANGS/lang-sma/src/generator-gt-desc.xfst'
alias dsme='$LOOKUP $GTLANGS/lang-sme/src/generator-gt-desc.xfst'
alias dsmj='$LOOKUP $GTLANGS/lang-smj/src/generator-gt-desc.xfst'
alias dsmn='$LOOKUP $GTLANGS/lang-smn/src/generator-gt-desc.xfst'
alias dsms='$LOOKUP $GTLANGS/lang-sms/src/generator-gt-desc.xfst'
alias dsom='$LOOKUP $GTLANGS/lang-som/src/generator-gt-desc.xfst'
alias dtat='$LOOKUP $GTLANGS/lang-tat/src/generator-gt-desc.xfst'
alias dtku='$LOOKUP $GTLANGS/lang-tku/src/generator-gt-desc.xfst'
alias dtuv='$LOOKUP $GTLANGS/lang-tuv/src/generator-gt-desc.xfst'
alias dudm='$LOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.xfst'
alias dvep='$LOOKUP $GTLANGS/lang-vep/src/generator-gt-desc.xfst'
alias dvro='$LOOKUP $GTLANGS/lang-vro/src/generator-gt-desc.xfst'
alias dyrk='$LOOKUP $GTLANGS/lang-yrk/src/generator-gt-desc.xfst'


alias ueng='$LOOKUP $GTLANGS/lang-eng/src/analyser-gt-desc.xfst'
alias uest2='$LOOKUP $GTLANGS/lang-est/src/analyser-gt-desc.xfst'


alias uapu='$LOOKUP $GTLANGS/lang-apu/src/analyser-gt-desc.xfst'
alias ukhk='$LOOKUP $GTLANGS/lang-khk/src/analyser-gt-desc.xfst'
alias ukjh='$LOOKUP $GTLANGS/lang-kjh/src/analyser-gt-desc.xfst'
alias utyv='$LOOKUP $GTLANGS/lang-tyv/src/analyser-gt-desc.xfst'
alias uxal='$LOOKUP $GTLANGS/lang-xal/src/analyser-gt-desc.xfst'
alias uxwo='$LOOKUP $GTLANGS/lang-xwo/src/analyser-gt-desc.xfst'


alias uamh='$LOOKUP $GTLANGS/lang-amh/src/analyser-gt-desc.xfst'
alias ubak='$LOOKUP $GTLANGS/lang-bak/src/analyser-gt-desc.xfst'
alias ubla='$LOOKUP $GTLANGS/lang-bla/src/analyser-gt-desc.xfst'
alias uevn='$LOOKUP $GTLANGS/lang-evn/src/analyser-gt-desc.xfst'
alias usel='$LOOKUP $GTLANGS/lang-sel/src/analyser-gt-desc.xfst'
alias usrs='$LOOKUP $GTLANGS/lang-srs/src/analyser-gt-desc.xfst'
alias usto='$LOOKUP $GTLANGS/lang-sto/src/analyser-gt-desc.xfst'
alias utlh='$LOOKUP $GTLANGS/lang-tlh/src/analyser-gt-desc.xfst'
alias uzul='$LOOKUP $GTLANGS/lang-zul/src/analyser-gt-desc.xfst'

alias ubxr='$LOOKUP $GTLANGS/lang-bxr/src/analyser-gt-desc.xfst'
alias uchp='$LOOKUP $GTLANGS/lang-chp/src/analyser-gt-desc.xfst'
alias uchr='$LOOKUP $GTLANGS/lang-chr/src/analyser-gt-desc.xfst'
alias uciw='$LOOKUP $GTLANGS/lang-ciw/src/analyser-gt-desc.xfst'
alias ucor='$LOOKUP $GTLANGS/lang-cor/src/analyser-gt-desc.xfst'
alias ucrk='$LOOKUP $GTLANGS/lang-crk/src/analyser-gt-desc.xfst'
alias udeu='$LOOKUP $GTLANGS/lang-deu/src/analyser-gt-desc.xfst'
alias uest='$LOOKUP $GTLANGS/lang-est/src/analyser-gt-desc.xfst'
alias ufao='$LOOKUP $GTLANGS/lang-fao/src/analyser-gt-desc.xfst'
alias ufin='$LOOKUP $GTLANGS/lang-fin/src/analyser-gt-desc.xfst'
alias ufkv='$LOOKUP $GTLANGS/lang-fkv/src/analyser-gt-desc.xfst'
alias uhdn='$LOOKUP $GTLANGS/lang-hdn/src/analyser-gt-desc.xfst'
alias uhun='$LOOKUP $GTLANGS/lang-hun/src/analyser-gt-desc.xfst'
alias uipk='$LOOKUP $GTLANGS/lang-ipk/src/analyser-gt-desc.xfst'
alias uizh='$LOOKUP $GTLANGS/lang-izh/src/analyser-gt-desc.xfst'
alias ukal='$LOOKUP $GTLANGS/lang-kal/src/analyser-gt-desc.xfst'
alias ukca='$LOOKUP $GTLANGS/lang-kca/src/analyser-gt-desc.xfst'
alias ukoi='$LOOKUP $GTLANGS/lang-koi/src/analyser-gt-desc.xfst'
alias ukom='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.xfst'
alias ukpv='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.xfst'
alias ulav='$LOOKUP $GTLANGS/lang-lav/src/analyser-gt-desc.xfst'
alias uliv='$LOOKUP $GTLANGS/lang-liv/src/analyser-gt-desc.xfst'
alias umdf='$LOOKUP $GTLANGS/lang-mdf/src/analyser-gt-desc.xfst'
alias umhr='$LOOKUP $GTLANGS/lang-mhr/src/analyser-gt-desc.xfst'
alias umns='$LOOKUP $GTLANGS/lang-mns/src/analyser-gt-desc.xfst'
alias umrj='$LOOKUP $GTLANGS/lang-mrj/src/analyser-gt-desc.xfst'
alias umyv='$LOOKUP $GTLANGS/lang-myv/src/analyser-gt-desc.xfst'
alias undl='$LOOKUP $GTLANGS/lang-ndl/src/analyser-gt-desc.xfst'
alias unio='$LOOKUP $GTLANGS/lang-nio/src/analyser-gt-desc.xfst'
alias unob='$LOOKUP $GTLANGS/lang-nob/src/analyser-gt-desc.xfst'
alias uolo='$LOOKUP $GTLANGS/lang-olo/src/analyser-gt-desc.xfst'
alias uoji='$LOOKUP $GTLANGS/lang-oji/src/analyser-gt-desc.xfst'
alias uotw='$LOOKUP $GTLANGS/lang-otw/src/analyser-gt-desc.xfst'
alias uron='$LOOKUP $GTLANGS/lang-ron/src/analyser-gt-desc.xfst'
alias urus='$LOOKUP $GTLANGS/lang-rus/src/analyser-gt-desc.xfst'
alias usjd='$LOOKUP $GTLANGS/lang-sjd/src/analyser-gt-desc.xfst'
alias usje='$LOOKUP $GTLANGS/lang-sje/src/analyser-gt-desc.xfst'
alias usma='$LOOKUP $GTLANGS/lang-sma/src/analyser-gt-desc.xfst'
alias usme='$LOOKUP $GTLANGS/lang-sme/src/analyser-gt-desc.xfst'
alias usmedis='$LOOKUP $GTLANGS/lang-sme/src/analyser-disamb-gt-desc.xfst'
alias usmadis='$LOOKUP $GTLANGS/lang-sma/src/analyser-disamb-gt-desc.xfst'
alias usmjdis='$LOOKUP $GTLANGS/lang-smj/src/analyser-disamb-gt-desc.xfst'
alias usmndis='$LOOKUP $GTLANGS/lang-smn/src/analyser-disamb-gt-desc.xfst'
alias usmsdis='$LOOKUP $GTLANGS/lang-sms/src/analyser-disamb-gt-desc.xfst'
alias ufkvdis='$LOOKUP $GTLANGS/lang-fkv/src/analyser-disamb-gt-desc.xfst'
alias usmj='$LOOKUP $GTLANGS/lang-smj/src/analyser-gt-desc.xfst'
alias usmn='$LOOKUP $GTLANGS/lang-smn/src/analyser-gt-desc.xfst'
alias usms='$LOOKUP $GTLANGS/lang-sms/src/analyser-gt-desc.xfst'
alias usom='$LOOKUP $GTLANGS/lang-som/src/analyser-gt-desc.xfst'
alias utat='$LOOKUP $GTLANGS/lang-tat/src/analyser-gt-desc.xfst'
alias utku='$LOOKUP $GTLANGS/lang-tku/src/analyser-gt-desc.xfst'
alias utuv='$LOOKUP $GTLANGS/lang-tuv/src/analyser-gt-desc.xfst'
alias uudm='$LOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.xfst'
alias uvep='$LOOKUP $GTLANGS/lang-vep/src/analyser-gt-desc.xfst'
alias uvro='$LOOKUP $GTLANGS/lang-vro/src/analyser-gt-desc.xfst'
alias uyrk='$LOOKUP $GTLANGS/lang-yrk/src/analyser-gt-desc.xfst'


# Dictionary transducers

alias usmnDict='$LOOKUP $GTLANGS/lang-smn/src/analyser-dict-gt-desc.xfst'
alias dsmnDict='$LOOKUP $GTLANGS/lang-smn/src/generator-dict-gt-norm.xfst'
alias usmsDict='$LOOKUP $GTLANGS/lang-sms/src/analyser-dict-gt-desc.xfst'
alias dsmsDict='$LOOKUP $GTLANGS/lang-sms/src/generator-dict-gt-norm.xfst'


alias husmnDict='$HLOOKUP $GTLANGS/lang-smn/src/analyser-dict-gt-desc.hfstol'
alias hdsmnDict='$HLOOKUP $GTLANGS/lang-smn/src/generator-dict-gt-norm.hfstol'
alias husmsDict='$HLOOKUP $GTLANGS/lang-sms/src/analyser-dict-gt-desc.hfstol'
alias hdsmsDict='$HLOOKUP $GTLANGS/lang-sms/src/generator-dict-gt-norm.hfstol'



# Languages in newinfra, lazy cyrillic aliases:

alias уком='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.xfst'
alias глщь='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.xfst'
alias умчр='$LOOKUP $GTLANGS/lang-mhr/src/analyser-gt-desc.xfst'
alias умыв='$LOOKUP $GTLANGS/lang-myv/src/analyser-gt-desc.xfst'
alias уудм='$LOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.xfst'
alias уырк='$LOOKUP $GTLANGS/lang-yrk/src/analyser-gt-desc.xfst'
alias урус='$LOOKUP $GTLANGS/lang-rus/src/analyser-gt-desc.xfst'

alias дком='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.xfst'
alias дмчр='$LOOKUP $GTLANGS/lang-mhr/src/generator-gt-desc.xfst'
alias дмыв='$LOOKUP $GTLANGS/lang-myv/src/generator-gt-desc.xfst'
alias дудм='$LOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.xfst'
alias дырк='$LOOKUP $GTLANGS/lang-yrk/src/generator-gt-desc.xfst'
alias друс='$LOOKUP $GTLANGS/lang-rus/src/generator-gt-desc.xfst'


# Languages in newinfra, Normative variants:

alias dapuNorm='$LOOKUP $GTLANGS/lang-apu/src/generator-gt-norm.xfst'
alias dkhkNorm='$LOOKUP $GTLANGS/lang-khk/src/generator-gt-norm.xfst'
alias dkjhNorm='$LOOKUP $GTLANGS/lang-kjh/src/generator-gt-norm.xfst'
alias dtyvNorm='$LOOKUP $GTLANGS/lang-tyv/src/generator-gt-norm.xfst'
alias dxalNorm='$LOOKUP $GTLANGS/lang-xal/src/generator-gt-norm.xfst'
alias dxwoNorm='$LOOKUP $GTLANGS/lang-xwo/src/generator-gt-norm.xfst'

alias damhNorm='$LOOKUP $GTLANGS/lang-amh/src/generator-gt-norm.xfst'
alias dbakNorm='$LOOKUP $GTLANGS/lang-bak/src/generator-gt-norm.xfst'
alias dblaNorm='$LOOKUP $GTLANGS/lang-bla/src/generator-gt-norm.xfst'
alias devnNorm='$LOOKUP $GTLANGS/lang-evn/src/generator-gt-norm.xfst'
alias dselNorm='$LOOKUP $GTLANGS/lang-sel/src/generator-gt-norm.xfst'
alias dstoNorm='$LOOKUP $GTLANGS/lang-sto/src/generator-gt-norm.xfst'
alias dtlhNorm='$LOOKUP $GTLANGS/lang-tlh/src/generator-gt-norm.xfst'
alias dzulNorm='$LOOKUP $GTLANGS/lang-zul/src/generator-gt-norm.xfst'

alias dbxrNorm='$LOOKUP $GTLANGS/lang-bxr/src/generator-gt-norm.xfst'
alias dchpNorm='$LOOKUP $GTLANGS/lang-chp/src/generator-gt-norm.xfst'
alias dciwNorm='$LOOKUP $GTLANGS/lang-ciw/src/generator-gt-norm.xfst'
alias dcorNorm='$LOOKUP $GTLANGS/lang-cor/src/generator-gt-norm.xfst'
alias dcrkNorm='$LOOKUP $GTLANGS/lang-crk/src/generator-gt-norm.xfst'
alias dchrNorm='$LOOKUP $GTLANGS/lang-chr/src/generator-gt-norm.xfst'
alias destNorm='$LOOKUP $GTLANGS/lang-est/src/generator-gt-norm.xfst'
alias dfaoNorm='$LOOKUP $GTLANGS/lang-fao/src/generator-gt-norm.xfst'
alias dfinNorm='$LOOKUP $GTLANGS/lang-fin/src/generator-gt-norm.xfst'
alias dfkvNorm='$LOOKUP $GTLANGS/lang-fkv/src/generator-gt-norm.xfst'
alias dhdnNorm='$LOOKUP $GTLANGS/lang-hdn/src/generator-gt-norm.xfst'
alias dhunNorm='$LOOKUP $GTLANGS/lang-hun/src/generator-gt-norm.xfst'
alias dipkNorm='$LOOKUP $GTLANGS/lang-ipk/src/generator-gt-norm.xfst'
alias dizhNorm='$LOOKUP $GTLANGS/lang-izh/src/generator-gt-norm.xfst'
alias dkalNorm='$LOOKUP $GTLANGS/lang-kal/src/generator-gt-norm.xfst'
alias dkcaNorm='$LOOKUP $GTLANGS/lang-kca/src/generator-gt-norm.xfst'
alias dkoiNorm='$LOOKUP $GTLANGS/lang-koi/src/generator-gt-norm.xfst'
alias dkomNorm='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.xfst'
alias dkpvNorm='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.xfst'
alias dlavNorm='$LOOKUP $GTLANGS/lang-lav/src/generator-gt-norm.xfst'
alias dlivNorm='$LOOKUP $GTLANGS/lang-liv/src/generator-gt-norm.xfst'
alias dmdfNorm='$LOOKUP $GTLANGS/lang-mdf/src/generator-gt-norm.xfst'
alias dmhrNorm='$LOOKUP $GTLANGS/lang-mhr/src/generator-gt-norm.xfst'
alias dmnsNorm='$LOOKUP $GTLANGS/lang-mns/src/generator-gt-norm.xfst'
alias dmrjNorm='$LOOKUP $GTLANGS/lang-mrj/src/generator-gt-norm.xfst'
alias dmyvNorm='$LOOKUP $GTLANGS/lang-myv/src/generator-gt-norm.xfst'
alias dndlNorm='$LOOKUP $GTLANGS/lang-ndl/src/generator-gt-norm.xfst'
alias dnioNorm='$LOOKUP $GTLANGS/lang-nio/src/generator-gt-norm.xfst'
alias dnobNorm='$LOOKUP $GTLANGS/lang-nob/src/generator-gt-norm.xfst'
alias doloNorm='$LOOKUP $GTLANGS/lang-olo/src/generator-gt-norm.xfst'
alias dojiNorm='$LOOKUP $GTLANGS/lang-oji/src/generator-gt-norm.xfst'
alias dotwNorm='$LOOKUP $GTLANGS/lang-otw/src/generator-gt-norm.xfst'
alias dronNorm='$LOOKUP $GTLANGS/lang-ron/src/generator-gt-norm.xfst'
alias drusNorm='$LOOKUP $GTLANGS/lang-rus/src/generator-gt-norm.xfst'
alias dsjdNorm='$LOOKUP $GTLANGS/lang-sjd/src/generator-gt-norm.xfst'
alias dsjeNorm='$LOOKUP $GTLANGS/lang-sje/src/generator-gt-norm.xfst'
alias dsmaNorm='$LOOKUP $GTLANGS/lang-sma/src/generator-gt-norm.xfst'
alias dsmeNorm='$LOOKUP $GTLANGS/lang-sme/src/generator-gt-norm.xfst'
alias dsmjNorm='$LOOKUP $GTLANGS/lang-smj/src/generator-gt-norm.xfst'
alias dsmnNorm='$LOOKUP $GTLANGS/lang-smn/src/generator-gt-norm.xfst'
alias dsmsNorm='$LOOKUP $GTLANGS/lang-sms/src/generator-gt-norm.xfst'
alias dsomNorm='$LOOKUP $GTLANGS/lang-som/src/generator-gt-norm.xfst'
alias dtatNorm='$LOOKUP $GTLANGS/lang-tat/src/generator-gt-norm.xfst'
alias dtkuNorm='$LOOKUP $GTLANGS/lang-tku/src/generator-gt-norm.xfst'
alias dtuvNorm='$LOOKUP $GTLANGS/lang-tuv/src/generator-gt-norm.xfst'
alias dudmNorm='$LOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.xfst'
alias dvepNorm='$LOOKUP $GTLANGS/lang-vep/src/generator-gt-norm.xfst'
alias dvroNorm='$LOOKUP $GTLANGS/lang-vro/src/generator-gt-norm.xfst'
alias dyrkNorm='$LOOKUP $GTLANGS/lang-yrk/src/generator-gt-norm.xfst'


alias uapuNorm='$LOOKUP $GTLANGS/lang-apu/src/analyser-gt-norm.xfst'
alias ukhkNorm='$LOOKUP $GTLANGS/lang-khk/src/analyser-gt-norm.xfst'
alias ukjhNorm='$LOOKUP $GTLANGS/lang-kjh/src/analyser-gt-norm.xfst'
alias utyvNorm='$LOOKUP $GTLANGS/lang-tyv/src/analyser-gt-norm.xfst'
alias uxalNorm='$LOOKUP $GTLANGS/lang-xal/src/analyser-gt-norm.xfst'
alias uxwoNorm='$LOOKUP $GTLANGS/lang-xwo/src/analyser-gt-norm.xfst'



alias uamhNorm='$LOOKUP $GTLANGS/lang-amh/src/analyser-gt-norm.xfst'
alias ubakNorm='$LOOKUP $GTLANGS/lang-bak/src/analyser-gt-norm.xfst'
alias ublaNorm='$LOOKUP $GTLANGS/lang-bla/src/analyser-gt-norm.xfst'
alias uevnNorm='$LOOKUP $GTLANGS/lang-evn/src/analyser-gt-norm.xfst'
alias uselNorm='$LOOKUP $GTLANGS/lang-sel/src/analyser-gt-norm.xfst'
alias ustoNorm='$LOOKUP $GTLANGS/lang-sto/src/analyser-gt-norm.xfst'
alias utlhNorm='$LOOKUP $GTLANGS/lang-tlh/src/analyser-gt-norm.xfst'
alias uzulNorm='$LOOKUP $GTLANGS/lang-zul/src/analyser-gt-norm.xfst'

alias ubxrNorm='$LOOKUP $GTLANGS/lang-bxr/src/analyser-gt-norm.xfst'
alias uchpNorm='$LOOKUP $GTLANGS/lang-chp/src/analyser-gt-norm.xfst'
alias uciwNorm='$LOOKUP $GTLANGS/lang-ciw/src/analyser-gt-norm.xfst'
alias ucorNorm='$LOOKUP $GTLANGS/lang-cor/src/analyser-gt-norm.xfst'
alias ucrkNorm='$LOOKUP $GTLANGS/lang-crk/src/analyser-gt-norm.xfst'
alias uchrNorm='$LOOKUP $GTLANGS/lang-chr/src/analyser-gt-norm.xfst'
alias uestNorm='$LOOKUP $GTLANGS/lang-est/src/analyser-gt-norm.xfst'
alias ufaoNorm='$LOOKUP $GTLANGS/lang-fao/src/analyser-gt-norm.xfst'
alias ufinNorm='$LOOKUP $GTLANGS/lang-fin/src/analyser-gt-norm.xfst'
alias ufkvNorm='$LOOKUP $GTLANGS/lang-fkv/src/analyser-gt-norm.xfst'
alias uhdnNorm='$LOOKUP $GTLANGS/lang-hdn/src/analyser-gt-norm.xfst'
alias uhunNorm='$LOOKUP $GTLANGS/lang-hun/src/analyser-gt-norm.xfst'
alias uipkNorm='$LOOKUP $GTLANGS/lang-ipk/src/analyser-gt-norm.xfst'
alias uizhNorm='$LOOKUP $GTLANGS/lang-izh/src/analyser-gt-norm.xfst'
alias ukalNorm='$LOOKUP $GTLANGS/lang-kal/src/analyser-gt-norm.xfst'
alias ukcaNorm='$LOOKUP $GTLANGS/lang-kca/src/analyser-gt-norm.xfst'
alias ukoiNorm='$LOOKUP $GTLANGS/lang-koi/src/analyser-gt-norm.xfst'
alias ukomNorm='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.xfst'
alias ukpvNorm='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.xfst'
alias ulavNorm='$LOOKUP $GTLANGS/lang-lav/src/analyser-gt-norm.xfst'
alias ulivNorm='$LOOKUP $GTLANGS/lang-liv/src/analyser-gt-norm.xfst'
alias umdfNorm='$LOOKUP $GTLANGS/lang-mdf/src/analyser-gt-norm.xfst'
alias umhrNorm='$LOOKUP $GTLANGS/lang-mhr/src/analyser-gt-norm.xfst'
alias umnsNorm='$LOOKUP $GTLANGS/lang-mns/src/analyser-gt-norm.xfst'
alias umrjNorm='$LOOKUP $GTLANGS/lang-mrj/src/analyser-gt-norm.xfst'
alias umyvNorm='$LOOKUP $GTLANGS/lang-myv/src/analyser-gt-norm.xfst'
alias undlNorm='$LOOKUP $GTLANGS/lang-ndl/src/analyser-gt-norm.xfst'
alias unioNorm='$LOOKUP $GTLANGS/lang-nio/src/analyser-gt-norm.xfst'
alias unobNorm='$LOOKUP $GTLANGS/lang-nob/src/analyser-gt-norm.xfst'
alias uojiNorm='$LOOKUP $GTLANGS/lang-oji/src/analyser-gt-norm.xfst'
alias uotwNorm='$LOOKUP $GTLANGS/lang-otw/src/analyser-gt-norm.xfst'
alias uoloNorm='$LOOKUP $GTLANGS/lang-olo/src/analyser-gt-norm.xfst'
alias uronNorm='$LOOKUP $GTLANGS/lang-ron/src/analyser-gt-norm.xfst'
alias urusNorm='$LOOKUP $GTLANGS/lang-rus/src/analyser-gt-norm.xfst'
alias usjdNorm='$LOOKUP $GTLANGS/lang-sjd/src/analyser-gt-norm.xfst'
alias usjeNorm='$LOOKUP $GTLANGS/lang-sje/src/analyser-gt-norm.xfst'
alias usmaNorm='$LOOKUP $GTLANGS/lang-sma/src/analyser-gt-norm.xfst'
alias usmeNorm='$LOOKUP $GTLANGS/lang-sme/src/analyser-gt-norm.xfst'
alias usmjNorm='$LOOKUP $GTLANGS/lang-smj/src/analyser-gt-norm.xfst'
alias usmnNorm='$LOOKUP $GTLANGS/lang-smn/src/analyser-gt-norm.xfst'
alias usmsNorm='$LOOKUP $GTLANGS/lang-sms/src/analyser-gt-norm.xfst'
alias usomNorm='$LOOKUP $GTLANGS/lang-som/src/analyser-gt-norm.xfst'
alias utatNorm='$LOOKUP $GTLANGS/lang-tat/src/analyser-gt-norm.xfst'
alias utkuNorm='$LOOKUP $GTLANGS/lang-tku/src/analyser-gt-norm.xfst'
alias utuvNorm='$LOOKUP $GTLANGS/lang-tuv/src/analyser-gt-norm.xfst'
alias uudmNorm='$LOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.xfst'
alias uvepNorm='$LOOKUP $GTLANGS/lang-vep/src/analyser-gt-norm.xfst'
alias uvroNorm='$LOOKUP $GTLANGS/lang-vro/src/analyser-gt-norm.xfst'
alias uyrkNorm='$LOOKUP $GTLANGS/lang-yrk/src/analyser-gt-norm.xfst'

# Languages in newinfra, lazy cyrillic aliases:

alias дкомНорм='$LOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.xfst'
alias дмчрНорм='$LOOKUP $GTLANGS/lang-mhr/src/generator-gt-norm.xfst'
alias дмывНорм='$LOOKUP $GTLANGS/lang-myv/src/generator-gt-norm.xfst'
alias дудмНорм='$LOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.xfst'
alias дыркНорм='$LOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.xfst'

alias укомНорм='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.xfst'
alias глщьНорм='$LOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.xfst'
alias умчрНорм='$LOOKUP $GTLANGS/lang-mhr/src/analyser-gt-norm.xfst'
alias умывНорм='$LOOKUP $GTLANGS/lang-myv/src/analyser-gt-norm.xfst'
alias уудмНорм='$LOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.xfst'
alias уыркНорм='$LOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.xfst'


# Other languages in the old infra:

alias   damh='$LOOKUP $GTLANGS/lang-amh/bin/iamh.fst'
alias   dces='$LOOKUP $GTLANGS/lang-ces/bin/ices.fst'
alias   deus='$LOOKUP $GTLANGS/lang-eus/bin/ieus.fst'
alias   diku='$LOOKUP $GTLANGS/lang-iku/bin/iiku.fst'
alias   dnno='$LOOKUP $GTLANGS/lang-nno/bin/inno.fst'
alias   dnon='$LOOKUP $GTLANGS/lang-non/bin/inon.fst'

alias   uamh='$LOOKUP $GTLANGS/lang-amh/bin/amh.fst'
alias   uces='$LOOKUP $GTLANGS/lang-ces/bin/ces.fst'
alias   ueus='$LOOKUP $GTLANGS/lang-eus/bin/eus.fst'
alias   uiku='$LOOKUP $GTLANGS/lang-iku/bin/iku.fst'
alias   unno='$LOOKUP $GTLANGS/lang-nno/bin/nno.fst'
alias   unon='$LOOKUP $GTLANGS/lang-non/src/analyser-gt-desc.xfst'


alias   дбхр='$LOOKUP $GTLANGS/lang-bxr/bin/ibxr.fst'
alias   убхр='$LOOKUP $GTLANGS/lang-bxr/bin/bxr.fst'

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

alias hdapu='$HLOOKUP $GTLANGS/lang-apu/src/generator-gt-desc.hfstol'
alias hdkhk='$HLOOKUP $GTLANGS/lang-khk/src/generator-gt-desc.hfstol'
alias hdkjh='$HLOOKUP $GTLANGS/lang-kjh/src/generator-gt-desc.hfstol'
alias hdtyv='$HLOOKUP $GTLANGS/lang-tyv/src/generator-gt-desc.hfstol'
alias hdxal='$HLOOKUP $GTLANGS/lang-xal/src/generator-gt-desc.hfstol'
alias hdxwo='$HLOOKUP $GTLANGS/lang-xwo/src/generator-gt-desc.hfstol'

alias hdamh='$HLOOKUP $GTLANGS/lang-amh/src/generator-gt-desc.hfstol'
alias hdbak='$HLOOKUP $GTLANGS/lang-bak/src/generator-gt-desc.hfstol'
alias hdbla='$HLOOKUP $GTLANGS/lang-bla/src/generator-gt-desc.hfstol'
alias hdevn='$HLOOKUP $GTLANGS/lang-evn/src/generator-gt-desc.hfstol'
alias hdsel='$HLOOKUP $GTLANGS/lang-sel/src/generator-gt-desc.hfstol'
alias hdsrs='$HLOOKUP $GTLANGS/lang-srs/src/generator-gt-desc.hfstol'
alias hdsto='$HLOOKUP $GTLANGS/lang-sto/src/generator-gt-desc.hfstol'
alias hdtlh='$HLOOKUP $GTLANGS/lang-tlh/src/generator-gt-desc.hfstol'
alias hdzul='$HLOOKUP $GTLANGS/lang-zul/src/generator-gt-desc.hfstol'

alias hdbxr='$HLOOKUP $GTLANGS/lang-bxr/src/generator-gt-desc.hfstol'
alias hdchp='$HLOOKUP $GTLANGS/lang-chp/src/generator-gt-desc.hfstol'
alias hdciw='$HLOOKUP $GTLANGS/lang-ciw/src/generator-gt-desc.hfstol'
alias hdcor='$HLOOKUP $GTLANGS/lang-cor/src/generator-gt-desc.hfstol'
alias hdcrk='$HLOOKUP $GTLANGS/lang-crk/src/generator-gt-desc.hfstol'
alias hdchr='$HLOOKUP $GTLANGS/lang-chr/src/generator-gt-desc.hfstol'
alias hddeu='$HLOOKUP $GTLANGS/lang-deu/src/generator-gt-desc.hfstol'
alias hdest='$HLOOKUP $GTLANGS/lang-est/src/generator-gt-desc.hfstol'
alias hdfao='$HLOOKUP $GTLANGS/lang-fao/src/generator-gt-desc.hfstol'
alias hdfin='$HLOOKUP $GTLANGS/lang-fin/src/generator-gt-desc.hfstol'
alias hdfkv='$HLOOKUP $GTLANGS/lang-fkv/src/generator-gt-desc.hfstol'
alias hdhdn='$HLOOKUP $GTLANGS/lang-hdn/src/generator-gt-desc.hfstol'
alias hdhun='$HLOOKUP $GTLANGS/lang-hun/src/generator-gt-desc.hfstol'
alias hdipk='$HLOOKUP $GTLANGS/lang-ipk/src/generator-gt-desc.hfstol'
alias hdizh='$HLOOKUP $GTLANGS/lang-izh/src/generator-gt-desc.hfstol'
alias hdkal='$HLOOKUP $GTLANGS/lang-kal/src/generator-gt-desc.hfstol'
alias hdkca='$HLOOKUP $GTLANGS/lang-kca/src/generator-gt-desc.hfstol'
alias hdkoi='$HLOOKUP $GTLANGS/lang-koi/src/generator-gt-desc.hfstol'
alias hdkom='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.hfstol'
alias hdkpv='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.hfstol'
alias hdlav='$HLOOKUP $GTLANGS/lang-lav/src/generator-gt-desc.hfstol'
alias hdliv='$HLOOKUP $GTLANGS/lang-liv/src/generator-gt-desc.hfstol'
alias hdlut='$HLOOKUP $GTLANGS/lang-lut/src/generator-gt-desc.hfstol'
alias hdmdf='$HLOOKUP $GTLANGS/lang-mdf/src/generator-gt-desc.hfstol'
alias hdmhr='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-desc.hfstol'
alias hdmns='$HLOOKUP $GTLANGS/lang-mns/src/generator-gt-desc.hfstol'
alias hdmrj='$HLOOKUP $GTLANGS/lang-mrj/src/generator-gt-desc.hfstol'
alias hdmyv='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-desc.hfstol'
alias hdndl='$HLOOKUP $GTLANGS/lang-ndl/src/generator-gt-desc.hfstol'
alias hdnio='$HLOOKUP $GTLANGS/lang-nio/src/generator-gt-desc.hfstol'
alias hdnob='$HLOOKUP $GTLANGS/lang-nob/src/generator-gt-desc.hfstol'
alias hdoji='$HLOOKUP $GTLANGS/lang-oji/src/generator-gt-desc.hfstol'
alias hdotw='$HLOOKUP $GTLANGS/lang-otw/src/generator-gt-desc.hfstol'
alias hdolo='$HLOOKUP $GTLANGS/lang-olo/src/generator-gt-desc.hfstol'
alias hdron='$HLOOKUP $GTLANGS/lang-ron/src/generator-gt-desc.hfstol'
alias hdrus='$HLOOKUP $GTLANGS/lang-rus/src/generator-gt-desc.hfstol'
alias hdsjd='$HLOOKUP $GTLANGS/lang-sjd/src/generator-gt-desc.hfstol'
alias hdsje='$HLOOKUP $GTLANGS/lang-sje/src/generator-gt-desc.hfstol'
alias hdsma='$HLOOKUP $GTLANGS/lang-sma/src/generator-gt-desc.hfstol'
alias hdsme='$HLOOKUP $GTLANGS/lang-sme/src/generator-gt-desc.hfstol'
alias hdsmj='$HLOOKUP $GTLANGS/lang-smj/src/generator-gt-desc.hfstol'
alias hdsmn='$HLOOKUP $GTLANGS/lang-smn/src/generator-gt-desc.hfstol'
alias hdsms='$HLOOKUP $GTLANGS/lang-sms/src/generator-gt-desc.hfstol'
alias hdsom='$HLOOKUP $GTLANGS/lang-som/src/generator-gt-desc.hfstol'
alias hdtat='$HLOOKUP $GTLANGS/lang-tat/src/generator-gt-desc.hfstol'
alias hdtku='$HLOOKUP $GTLANGS/lang-tku/src/generator-gt-desc.hfstol'
alias hdtuv='$HLOOKUP $GTLANGS/lang-tuv/src/generator-gt-desc.hfstol'
alias hdudm='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.hfstol'
alias hdvep='$HLOOKUP $GTLANGS/lang-vep/src/generator-gt-desc.hfstol'
alias hdvro='$HLOOKUP $GTLANGS/lang-vro/src/generator-gt-desc.hfstol'
alias hdyrk='$HLOOKUP $GTLANGS/lang-yrk/src/generator-gt-desc.hfstol'


alias huapu='$HLOOKUP $GTLANGS/lang-apu/src/analyser-gt-desc.hfstol'
alias hukhk='$HLOOKUP $GTLANGS/lang-khk/src/analyser-gt-desc.hfstol'
alias hukjh='$HLOOKUP $GTLANGS/lang-kjh/src/analyser-gt-desc.hfstol'
alias hutyv='$HLOOKUP $GTLANGS/lang-tyv/src/analyser-gt-desc.hfstol'
alias huxal='$HLOOKUP $GTLANGS/lang-xal/src/analyser-gt-desc.hfstol'
alias huxwo='$HLOOKUP $GTLANGS/lang-xwo/src/analyser-gt-desc.hfstol'


alias huamh='$HLOOKUP $GTLANGS/lang-amh/src/analyser-gt-desc.hfstol'
alias hubak='$HLOOKUP $GTLANGS/lang-bak/src/analyser-gt-desc.hfstol'
alias hubla='$HLOOKUP $GTLANGS/lang-bla/src/analyser-gt-desc.hfstol'
alias huevn='$HLOOKUP $GTLANGS/lang-evn/src/analyser-gt-desc.hfstol'
alias husto='$HLOOKUP $GTLANGS/lang-sto/src/analyser-gt-desc.hfstol'
alias hutlh='$HLOOKUP $GTLANGS/lang-tlh/src/analyser-gt-desc.hfstol'
alias huzul='$HLOOKUP $GTLANGS/lang-zul/src/analyser-gt-desc.hfstol'

alias hubxr='$HLOOKUP $GTLANGS/lang-bxr/src/analyser-gt-desc.hfstol'
alias huchp='$HLOOKUP $GTLANGS/lang-chp/src/analyser-gt-desc.hfstol'
alias huciw='$HLOOKUP $GTLANGS/lang-ciw/src/analyser-gt-desc.hfstol'
alias hucor='$HLOOKUP $GTLANGS/lang-cor/src/analyser-gt-desc.hfstol'
alias hucrk='$HLOOKUP $GTLANGS/lang-crk/src/analyser-gt-desc.hfstol'
alias huchr='$HLOOKUP $GTLANGS/lang-chr/src/analyser-gt-desc.hfstol'
alias hudeu='$HLOOKUP $GTLANGS/lang-deu/src/analyser-gt-desc.hfstol'
alias huest='$HLOOKUP $GTLANGS/lang-est/src/analyser-gt-desc.hfstol'
alias hufao='$HLOOKUP $GTLANGS/lang-fao/src/analyser-gt-desc.hfstol'
alias hufin='$HLOOKUP $GTLANGS/lang-fin/src/analyser-gt-desc.hfstol'
alias hufkv='$HLOOKUP $GTLANGS/lang-fkv/src/analyser-gt-desc.hfstol'
alias huhdn='$HLOOKUP $GTLANGS/lang-hdn/src/analyser-gt-desc.hfstol'
alias huhun='$HLOOKUP $GTLANGS/lang-hun/src/analyser-gt-desc.hfstol'
alias huipk='$HLOOKUP $GTLANGS/lang-ipk/src/analyser-gt-desc.hfstol'
alias huizh='$HLOOKUP $GTLANGS/lang-izh/src/analyser-gt-desc.hfstol'
alias hukal='$HLOOKUP $GTLANGS/lang-kal/src/analyser-gt-desc.hfstol'
alias hukca='$HLOOKUP $GTLANGS/lang-kca/src/analyser-gt-desc.hfstol'
alias hukoi='$HLOOKUP $GTLANGS/lang-koi/src/analyser-gt-desc.hfstol'
alias hukom='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias hukpv='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias hulav='$HLOOKUP $GTLANGS/lang-lav/src/analyser-gt-desc.hfstol'
alias huliv='$HLOOKUP $GTLANGS/lang-liv/src/analyser-gt-desc.hfstol'
alias hulut='$HLOOKUP $GTLANGS/lang-lut/src/analyser-gt-desc.hfstol'
alias humdf='$HLOOKUP $GTLANGS/lang-mdf/src/analyser-gt-desc.hfstol'
alias humhr='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-desc.hfstol'
alias humns='$HLOOKUP $GTLANGS/lang-mns/src/analyser-gt-desc.hfstol'
alias humrj='$HLOOKUP $GTLANGS/lang-mrj/src/analyser-gt-desc.hfstol'
alias humyv='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-desc.hfstol'
alias hundl='$HLOOKUP $GTLANGS/lang-ndl/src/analyser-gt-desc.hfstol'
alias hunio='$HLOOKUP $GTLANGS/lang-nio/src/analyser-gt-desc.hfstol'
alias hunob='$HLOOKUP $GTLANGS/lang-nob/src/analyser-gt-desc.hfstol'
alias huoji='$HLOOKUP $GTLANGS/lang-oji/src/analyser-gt-desc.hfstol'
alias huotw='$HLOOKUP $GTLANGS/lang-otw/src/analyser-gt-desc.hfstol'
alias huolo='$HLOOKUP $GTLANGS/lang-olo/src/analyser-gt-desc.hfstol'
alias huron='$HLOOKUP $GTLANGS/lang-ron/src/analyser-gt-desc.hfstol'
alias hurus='$HLOOKUP $GTLANGS/lang-rus/src/analyser-gt-desc.hfstol'
alias husel='$HLOOKUP $GTLANGS/lang-sel/src/analyser-gt-desc.hfstol'
alias husrs='$HLOOKUP $GTLANGS/lang-srs/src/analyser-gt-desc.hfstol'
alias husjd='$HLOOKUP $GTLANGS/lang-sjd/src/analyser-gt-desc.hfstol'
alias husje='$HLOOKUP $GTLANGS/lang-sje/src/analyser-gt-desc.hfstol'
alias husjedis='$HLOOKUP $GTLANGS/lang-sje/src/analyser-disamb-gt-desc.hfstol'
alias husma='$HLOOKUP $GTLANGS/lang-sma/src/analyser-gt-desc.hfstol'
alias husme='$HLOOKUP $GTLANGS/lang-sme/src/analyser-gt-desc.hfstol'
alias husmedis='$HLOOKUP $GTLANGS/lang-sme/src/analyser-disamb-gt-desc.hfstol'
alias husmj='$HLOOKUP $GTLANGS/lang-smj/src/analyser-gt-desc.hfstol'
alias husmjdis='$HLOOKUP $GTLANGS/lang-smj/src/analyser-disamb-gt-desc.hfstol'
alias husmadis='$HLOOKUP $GTLANGS/lang-sma/src/analyser-disamb-gt-desc.hfstol'
alias husmn='$HLOOKUP $GTLANGS/lang-smn/src/analyser-gt-desc.hfstol'
alias husms='$HLOOKUP $GTLANGS/lang-sms/src/analyser-gt-desc.hfstol'
alias husmsdis='$HLOOKUP $GTLANGS/lang-sms/src/analyser-disamb-gt-desc.hfstol'
alias husom='$HLOOKUP $GTLANGS/lang-som/src/analyser-gt-desc.hfstol'
alias hutat='$HLOOKUP $GTLANGS/lang-tat/src/analyser-gt-desc.hfstol'
alias hutku='$HLOOKUP $GTLANGS/lang-tku/src/analyser-gt-desc.hfstol'
alias hutuv='$HLOOKUP $GTLANGS/lang-tuv/src/analyser-gt-desc.hfstol'
alias huudm='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.hfstol'
alias huvep='$HLOOKUP $GTLANGS/lang-vep/src/analyser-gt-desc.hfstol'
alias huvro='$HLOOKUP $GTLANGS/lang-vro/src/analyser-gt-desc.hfstol'
alias huyrk='$HLOOKUP $GTLANGS/lang-yrk/src/analyser-gt-desc.hfstol'


# Normative variants:
alias hdamhNorm='$HLOOKUP $GTLANGS/lang-amh/src/generator-gt-norm.hfstol'
alias hdapuNorm='$HLOOKUP $GTLANGS/lang-apu/src/generator-gt-norm.hfstol'
alias hdbakNorm='$HLOOKUP $GTLANGS/lang-bak/src/generator-gt-norm.hfstol'
alias hdblaNorm='$HLOOKUP $GTLANGS/lang-bla/src/generator-gt-norm.hfstol'
alias hdevnNorm='$HLOOKUP $GTLANGS/lang-evn/src/generator-gt-norm.hfstol'
alias hdstoNorm='$HLOOKUP $GTLANGS/lang-sto/src/generator-gt-norm.hfstol'
alias hdselNorm='$HLOOKUP $GTLANGS/lang-sel/src/generator-gt-norm.hfstol'
alias hdtlhNorm='$HLOOKUP $GTLANGS/lang-tlh/src/generator-gt-norm.hfstol'
alias hdzulNorm='$HLOOKUP $GTLANGS/lang-zul/src/generator-gt-norm.hfstol'

alias hdbxrNorm='$HLOOKUP $GTLANGS/lang-bxr/src/generator-gt-norm.hfstol'
alias hdchpNorm='$HLOOKUP $GTLANGS/lang-chp/src/generator-gt-norm.hfstol'
alias hdciwNorm='$HLOOKUP $GTLANGS/lang-ciw/src/generator-gt-norm.hfstol'
alias hdcorNorm='$HLOOKUP $GTLANGS/lang-cor/src/generator-gt-norm.hfstol'
alias hdcrkNorm='$HLOOKUP $GTLANGS/lang-crk/src/generator-gt-norm.hfstol'
alias hdchrNorm='$HLOOKUP $GTLANGS/lang-chr/src/generator-gt-norm.hfstol'
alias hddeuNorm='$HLOOKUP $GTLANGS/lang-deu/src/generator-gt-norm.hfstol'
alias hdestNorm='$HLOOKUP $GTLANGS/lang-est/src/generator-gt-norm.hfstol'
alias hdfaoNorm='$HLOOKUP $GTLANGS/lang-fao/src/generator-gt-norm.hfstol'
alias hdfinNorm='$HLOOKUP $GTLANGS/lang-fin/src/generator-gt-norm.hfstol'
alias hdfkvNorm='$HLOOKUP $GTLANGS/lang-fkv/src/generator-gt-norm.hfstol'
alias hdhdnNorm='$HLOOKUP $GTLANGS/lang-hdn/src/generator-gt-norm.hfstol'
alias hdhunNorm='$HLOOKUP $GTLANGS/lang-hun/src/generator-gt-norm.hfstol'
alias hdipkNorm='$HLOOKUP $GTLANGS/lang-ipk/src/generator-gt-norm.hfstol'
alias hdizhNorm='$HLOOKUP $GTLANGS/lang-izh/src/generator-gt-norm.hfstol'
alias hdkalNorm='$HLOOKUP $GTLANGS/lang-kal/src/generator-gt-norm.hfstol'
alias hdkcaNorm='$HLOOKUP $GTLANGS/lang-kca/src/generator-gt-norm.hfstol'
alias hdkoiNorm='$HLOOKUP $GTLANGS/lang-koi/src/generator-gt-norm.hfstol'
alias hdkomNorm='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.hfstol'
alias hdkpvNorm='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.hfstol'
alias hdlavNorm='$HLOOKUP $GTLANGS/lang-lav/src/generator-gt-norm.hfstol'
alias hdlivNorm='$HLOOKUP $GTLANGS/lang-liv/src/generator-gt-norm.hfstol'
alias hdlutNorm='$HLOOKUP $GTLANGS/lang-lut/src/generator-gt-norm.hfstol'
alias hdmdfNorm='$HLOOKUP $GTLANGS/lang-mdf/src/generator-gt-norm.hfstol'
alias hdmhrNorm='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-norm.hfstol'
alias hdmnsNorm='$HLOOKUP $GTLANGS/lang-mns/src/generator-gt-norm.hfstol'
alias hdmrjNorm='$HLOOKUP $GTLANGS/lang-mrj/src/generator-gt-norm.hfstol'
alias hdmyvNorm='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-norm.hfstol'
alias hdndlNorm='$HLOOKUP $GTLANGS/lang-ndl/src/generator-gt-norm.hfstol'
alias hdnioNorm='$HLOOKUP $GTLANGS/lang-nio/src/generator-gt-norm.hfstol'
alias hdnobNorm='$HLOOKUP $GTLANGS/lang-nob/src/generator-gt-norm.hfstol'
alias hdojiNorm='$HLOOKUP $GTLANGS/lang-oji/src/generator-gt-norm.hfstol'
alias hdotwNorm='$HLOOKUP $GTLANGS/lang-otw/src/generator-gt-norm.hfstol'
alias hdronNorm='$HLOOKUP $GTLANGS/lang-ron/src/generator-gt-norm.hfstol'
alias hdrusNorm='$HLOOKUP $GTLANGS/lang-rus/src/generator-gt-norm.hfstol'
alias hdsjdNorm='$HLOOKUP $GTLANGS/lang-sjd/src/generator-gt-norm.hfstol'
alias hdsjeNorm='$HLOOKUP $GTLANGS/lang-sje/src/generator-gt-norm.hfstol'
alias hdsmaNorm='$HLOOKUP $GTLANGS/lang-sma/src/generator-gt-norm.hfstol'
alias hdsmeNorm='$HLOOKUP $GTLANGS/lang-sme/src/generator-gt-norm.hfstol'
alias hdsmjNorm='$HLOOKUP $GTLANGS/lang-smj/src/generator-gt-norm.hfstol'
alias hdsmnNorm='$HLOOKUP $GTLANGS/lang-smn/src/generator-gt-norm.hfstol'
alias hdsmsNorm='$HLOOKUP $GTLANGS/lang-sms/src/generator-gt-norm.hfstol'
alias hdsomNorm='$HLOOKUP $GTLANGS/lang-som/src/generator-gt-norm.hfstol'
alias hdtatNorm='$HLOOKUP $GTLANGS/lang-tat/src/generator-gt-norm.hfstol'
alias hdtkuNorm='$HLOOKUP $GTLANGS/lang-tku/src/generator-gt-norm.hfstol'
alias hdtuvNorm='$HLOOKUP $GTLANGS/lang-tuv/src/generator-gt-norm.hfstol'
alias hdudmNorm='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.hfstol'
alias hdvepNorm='$HLOOKUP $GTLANGS/lang-vep/src/generator-gt-norm.hfstol'
alias hdvroNorm='$HLOOKUP $GTLANGS/lang-vro/src/generator-gt-norm.hfstol'
alias hdyrkNorm='$HLOOKUP $GTLANGS/lang-yrk/src/generator-gt-norm.hfstol'



alias huamhNorm='$HLOOKUP $GTLANGS/lang-amh/src/analyser-gt-norm.hfstol'
alias huapuNorm='$HLOOKUP $GTLANGS/lang-apu/src/analyser-gt-norm.hfstol'
alias hubakNorm='$HLOOKUP $GTLANGS/lang-bak/src/analyser-gt-norm.hfstol'
alias hublaNorm='$HLOOKUP $GTLANGS/lang-bla/src/analyser-gt-norm.hfstol'
alias huevnNorm='$HLOOKUP $GTLANGS/lang-evn/src/analyser-gt-norm.hfstol'
alias huselNorm='$HLOOKUP $GTLANGS/lang-sel/src/analyser-gt-norm.hfstol'
alias hustoNorm='$HLOOKUP $GTLANGS/lang-sto/src/analyser-gt-norm.hfstol'
alias huzulNorm='$HLOOKUP $GTLANGS/lang-zul/src/analyser-gt-norm.hfstol'
alias hutlhNorm='$HLOOKUP $GTLANGS/lang-tlh/src/analyser-gt-norm.hfstol'

alias hubxrNorm='$HLOOKUP $GTLANGS/lang-bxr/src/analyser-gt-norm.hfstol'
alias huchpNorm='$HLOOKUP $GTLANGS/lang-chp/src/analyser-gt-norm.hfstol'
alias huciwNorm='$HLOOKUP $GTLANGS/lang-ciw/src/analyser-gt-norm.hfstol'
alias hucorNorm='$HLOOKUP $GTLANGS/lang-cor/src/analyser-gt-norm.hfstol'
alias hucrkNorm='$HLOOKUP $GTLANGS/lang-crk/src/analyser-gt-norm.hfstol'
alias huchrNorm='$HLOOKUP $GTLANGS/lang-chr/src/analyser-gt-norm.hfstol'
alias huestNorm='$HLOOKUP $GTLANGS/lang-est/src/analyser-gt-norm.hfstol'
alias hufaoNorm='$HLOOKUP $GTLANGS/lang-fao/src/analyser-gt-norm.hfstol'
alias hufinNorm='$HLOOKUP $GTLANGS/lang-fin/src/analyser-gt-norm.hfstol'
alias hufkvNorm='$HLOOKUP $GTLANGS/lang-fkv/src/analyser-gt-norm.hfstol'
alias huhdnNorm='$HLOOKUP $GTLANGS/lang-hdn/src/analyser-gt-norm.hfstol'
alias huhunNorm='$HLOOKUP $GTLANGS/lang-hun/src/analyser-gt-norm.hfstol'
alias huipkNorm='$HLOOKUP $GTLANGS/lang-ipk/src/analyser-gt-norm.hfstol'
alias huizhNorm='$HLOOKUP $GTLANGS/lang-izh/src/analyser-gt-norm.hfstol'
alias hukalNorm='$HLOOKUP $GTLANGS/lang-kal/src/analyser-gt-norm.hfstol'
alias hukcaNorm='$HLOOKUP $GTLANGS/lang-kca/src/analyser-gt-norm.hfstol'
alias hukoiNorm='$HLOOKUP $GTLANGS/lang-koi/src/analyser-gt-norm.hfstol'
alias hukomNorm='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias hukpvNorm='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias hulavNorm='$HLOOKUP $GTLANGS/lang-lav/src/analyser-gt-norm.hfstol'
alias hulivNorm='$HLOOKUP $GTLANGS/lang-liv/src/analyser-gt-norm.hfstol'
alias hulutNorm='$HLOOKUP $GTLANGS/lang-lut/src/analyser-gt-norm.hfstol'
alias humdfNorm='$HLOOKUP $GTLANGS/lang-mdf/src/analyser-gt-norm.hfstol'
alias humhrNorm='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-norm.hfstol'
alias humnsNorm='$HLOOKUP $GTLANGS/lang-mns/src/analyser-gt-norm.hfstol'
alias humrjNorm='$HLOOKUP $GTLANGS/lang-mrj/src/analyser-gt-norm.hfstol'
alias humyvNorm='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-norm.hfstol'
alias hundlNorm='$HLOOKUP $GTLANGS/lang-ndl/src/analyser-gt-norm.hfstol'
alias hunioNorm='$HLOOKUP $GTLANGS/lang-nio/src/analyser-gt-norm.hfstol'
alias hunobNorm='$HLOOKUP $GTLANGS/lang-nob/src/analyser-gt-norm.hfstol'
alias huojiNorm='$HLOOKUP $GTLANGS/lang-oji/src/analyser-gt-norm.hfstol'
alias huotwNorm='$HLOOKUP $GTLANGS/lang-otw/src/analyser-gt-norm.hfstol'
alias huoloNorm='$HLOOKUP $GTLANGS/lang-olo/src/analyser-gt-norm.hfstol'
alias huronNorm='$HLOOKUP $GTLANGS/lang-ron/src/analyser-gt-norm.hfstol'
alias hurusNorm='$HLOOKUP $GTLANGS/lang-rus/src/analyser-gt-norm.hfstol'
alias husjdNorm='$HLOOKUP $GTLANGS/lang-sjd/src/analyser-gt-norm.hfstol'
alias husjeNorm='$HLOOKUP $GTLANGS/lang-sje/src/analyser-gt-norm.hfstol'
alias husmaNorm='$HLOOKUP $GTLANGS/lang-sma/src/analyser-gt-norm.hfstol'
alias husmeNorm='$HLOOKUP $GTLANGS/lang-sme/src/analyser-gt-norm.hfstol'
alias husmjNorm='$HLOOKUP $GTLANGS/lang-smj/src/analyser-gt-norm.hfstol'
alias husmnNorm='$HLOOKUP $GTLANGS/lang-smn/src/analyser-gt-norm.hfstol'
alias husmsNorm='$HLOOKUP $GTLANGS/lang-sms/src/analyser-gt-norm.hfstol'
alias husomNorm='$HLOOKUP $GTLANGS/lang-som/src/analyser-gt-norm.hfstol'
alias hutatNorm='$HLOOKUP $GTLANGS/lang-tat/src/analyser-gt-norm.hfstol'
alias hutkuNorm='$HLOOKUP $GTLANGS/lang-tku/src/analyser-gt-norm.hfstol'
alias hutuvNorm='$HLOOKUP $GTLANGS/lang-tuv/src/analyser-gt-norm.hfstol'
alias huudmNorm='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.hfstol'
alias huvepNorm='$HLOOKUP $GTLANGS/lang-vep/src/analyser-gt-norm.hfstol'
alias huvroNorm='$HLOOKUP $GTLANGS/lang-vro/src/analyser-gt-norm.hfstol'
alias huyrkNorm='$HLOOKUP $GTLANGS/lang-yrk/src/analyser-gt-norm.hfstol'



# Other languages:
alias   hdmh='$HLOOKUP $GTLANGS/lang-amh/bin/iamh.hfst.ol'
alias   hdces='$HLOOKUP $GTLANGS/lang-ces/bin/ices.hfst.ol'
alias   hdeng='$HLOOKUP $GTLANGS/lang-eng/bin/ieng.hfst.ol'
alias   hdiku='$HLOOKUP $GTLANGS/lang-iku/bin/iiku.hfst.ol'
alias   hdnno='$HLOOKUP $GTLANGS/lang-nno/bin/inno.hfst.ol'
alias   hdnon='$HLOOKUP $GTLANGS/lang-non/bin/inon.hfst.ol'

alias   huamh='$HLOOKUP $GTLANGS/lang-amh/bin/amh.hfst.ol'
alias   huces='$HLOOKUP $GTLANGS/lang-ces/bin/ces.hfst.ol'
alias   hueng='$HLOOKUP $GTLANGS/lang-eng/bin/eng.hfst.ol'
alias   huiku='$HLOOKUP $GTLANGS/lang-iku/bin/iku.hfst.ol'
alias   hunno='$HLOOKUP $GTLANGS/lang-nno/bin/nno.hfst.ol'
alias   hunon='$HLOOKUP $GTLANGS/lang-non/bin/non.hfst.ol'


# Other FU languages:


# Cyrillic aliases:
# 'ч' = key h on the Russian Phonetic keyboard (for Hfst)
alias чуком='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias чглщь='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias чумчр='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-desc.hfstol'
alias чумыв='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-desc.hfstol'
alias чуудм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.hfstol'
alias чуырк='$HLOOKUP $GTLANGS/lang-yrk/src/analyser-gt-desc.hfstol'
alias чурус='$HLOOKUP $GTLANGS/lang-rus/src/analyser-gt-desc.hfstol'

alias чдком='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.hfstol'
alias чдмчр='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-desc.hfstol'
alias чдмыв='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-desc.hfstol'
alias чдудм='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.hfstol'
alias чдырк='$HLOOKUP $GTLANGS/lang-yrk/src/generator-gt-desc.hfstol'
alias чдрус='$HLOOKUP $GTLANGS/lang-rus/src/generator-gt-desc.hfstol'

alias чдкомНорм='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.hfstol'
alias чдмчрНорм='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-norm.hfstol'
alias чдмывНорм='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-norm.hfstol'
alias чдудмНорм='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.hfstol'
alias чдыркНорм='$HLOOKUP $GTLANGS/lang-yrk/src/generator-gt-norm.hfstol'
alias чдрусНорм='$HLOOKUP $GTLANGS/lang-rus/src/generator-gt-norm.hfstol'

alias чукомНорм='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias чглщьНорм='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias чумчрНорм='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-norm.hfstol'
alias чумывНорм='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-norm.hfstol'
alias чуудмНорм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.hfstol'
alias чурусНорм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.hfstol'

# 'х' = cyrillic h (for Hfst)
alias хуком='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias хглщь='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-desc.hfstol'
alias хумчр='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-desc.hfstol'
alias хумыв='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-desc.hfstol'
alias хуудм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.hfstol'
alias хуырк='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-desc.hfstol'

alias хдком='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-desc.hfstol'
alias хдмчр='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-desc.hfstol'
alias хдмыв='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-desc.hfstol'
alias хдудм='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.hfstol'
alias хдырк='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-desc.hfstol'

alias хдкомНорм='$HLOOKUP $GTLANGS/lang-kpv/src/generator-gt-norm.hfstol'
alias хдмчрНорм='$HLOOKUP $GTLANGS/lang-mhr/src/generator-gt-norm.hfstol'
alias хдмывНорм='$HLOOKUP $GTLANGS/lang-myv/src/generator-gt-norm.hfstol'
alias хдудмНорм='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.hfstol'
alias хдыркНорм='$HLOOKUP $GTLANGS/lang-udm/src/generator-gt-norm.hfstol'

alias хукомНорм='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias хглщьНорм='$HLOOKUP $GTLANGS/lang-kpv/src/analyser-gt-norm.hfstol'
alias хумчрНорм='$HLOOKUP $GTLANGS/lang-mhr/src/analyser-gt-norm.hfstol'
alias хумывНорм='$HLOOKUP $GTLANGS/lang-myv/src/analyser-gt-norm.hfstol'
alias хуудмНорм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.hfstol'
alias хуыркНорм='$HLOOKUP $GTLANGS/lang-udm/src/analyser-gt-norm.hfstol'

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

alias kpvtoka="hfst-tokenise --giella-cg $GTLANGS/lang-kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               sed 's/ <W:0.0000000000>//g;'"
alias kpvtoks="hfst-tokenise --giella-cg $GTLANGS/lang-kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               vislcg3 -g $GTLANGS/lang-kpv/src/cg3/disambiguator.cg3 | \
               sed 's/ <W:0.0000000000>//g;'"
alias kpvtokst="hfst-tokenise --giella-cg $GTLANGS/lang-kpv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               vislcg3 -g $GTLANGS/lang-kpv/src/cg3/disambiguator.cg3 -t | \
               sed 's/ <W:0.0000000000>//g;'"

alias myvtoka="hfst-tokenise --giella-cg $GTLANGS/lang-myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | \
               sed 's/ <W:0.0000000000>//g;'"
alias myvtoks="hfst-tokenise --giella-cg $GTLANGS/lang-myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst |  vislcg3 -g $GTLANGS/lang-myv/src/cg3/disambiguator.cg3 | \
               sed 's/ <W:0.0000000000>//g;'"
alias myvtokst="hfst-tokenise --giella-cg $GTLANGS/lang-myv/tools/tokenisers/tokeniser-disamb-gt-desc.pmhfst | vislcg3 -g $GTLANGS/lang-myv/src/cg3/disambiguator.cg3 -t | \
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

alias koidep="sent-proc.sh  -l koi -s dep"
alias koidept="sent-proc.sh -l koi -s dep -t"
alias koidis="sent-proc.sh  -l koi -s dis"
alias koidist="sent-proc.sh -l koi -s dis -t"

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





alias   damh='$LOOKUP $GTLANGS/lang-amh/src/generator-gt-desc.xfst'
alias   dces='$LOOKUP $GTLANGS/lang-ces/src/generator-gt-desc.xfst'
alias   deus='$LOOKUP $GTLANGS/lang-eus/src/generator-gt-desc.xfst'
alias   diku='$LOOKUP $GTLANGS/lang-iku/src/generator-gt-desc.xfst'
alias   dnno='$LOOKUP $GTLANGS/lang-nno/src/generator-gt-desc.xfst'
alias   dnon='$LOOKUP $GTLANGS/lang-non/src/generator-gt-desc.xfst'

alias   uamh='$LOOKUP $GTLANGS/lang-amh/src/analyser-gt-desc.xfst'
alias   uces='$LOOKUP $GTLANGS/lang-ces/src/analyser-gt-desc.xfst'
alias   ueus='$LOOKUP $GTLANGS/lang-eus/src/analyser-gt-desc.xfst'
alias   uiku='$LOOKUP $GTLANGS/lang-iku/src/analyser-gt-desc.xfst'
alias   unno='$LOOKUP $GTLANGS/lang-nno/src/analyser-gt-desc.xfst'
alias   убхр='$LOOKUP $GTLANGS/lang-bxr/src/analyser-gt-desc.xfst'
alias   дбхр='$LOOKUP $GTLANGS/lang-bxr/src/generator-gt-desc.xfst'

alias dfit='$LOOKUP $GTLANGS/lang-fit/src/generator-gt-desc.xfst'
alias dfitNorm='$LOOKUP $GTLANGS/lang-fit/src/generator-gt-norm.xfst'
alias finkpv='$LOOKUP $GTHOME/words/dicts/finkpv/bin/finkpv-all.fst'
alias finnob='$LOOKUP $GTHOME/words/dicts/finnob/bin/finnob-all.fst'
alias finsms='$LOOKUP $GTHOME/words/dicts/finsms/bin/finsms-all.fst'

alias fitdep="sent-proc.sh -l fit -s dep"
alias fitdept="sent-proc.sh -l fit -s dep -t"
alias fitdis="sent-proc.sh -l fit -s dis"
alias fitdist="sent-proc.sh -l fit -s dis -t"

alias hdfit='$HLOOKUP $GTLANGS/lang-fit/src/generator-gt-desc.hfstol'
alias hdfitNorm='$HLOOKUP $GTLANGS/lang-fit/src/generator-gt-norm.hfstol'
alias hdspa='$HLOOKUP $GTLANGS/lang-spa/src/generator-gt-desc.hfstol'
alias hufit='$HLOOKUP $GTLANGS/lang-fit/src/analyser-gt-desc.hfstol'
alias hufitNorm='$HLOOKUP $GTLANGS/lang-fit/src/analyser-gt-norm.hfstol'
alias huspa='$HLOOKUP $GTLANGS/lang-spa/src/analyser-gt-desc.hfstol'
alias kpvfin='$LOOKUP $GTHOME/words/dicts/kpv2X/bin/kpvfin-all.fst'
alias mhreng='$LOOKUP $GTHOME/words/dicts/mhreng/bin/mhreng-all.fst'
alias mhrmrj='$LOOKUP $GTHOME/words/dicts/mhrmrj/bin/mhrmrj-all.fst'
alias mhrrus='$LOOKUP $GTHOME/words/dicts/mhrrus/bin/mhrrus-all.fst'

alias nobfin='$LOOKUP $GTHOME/words/dicts/nobfin/bin/nobfin-all.fst'
alias smespa='$LOOKUP $GTHOME/words/dicts/smespa/bin/smespa-all.fst'
alias spasme='$LOOKUP $GTHOME/words/dicts/spasme/bin/spasme-all.fst'
alias ufit='$LOOKUP $GTLANGS/lang-fit/src/analyser-gt-desc.xfst'
alias ufitNorm='$LOOKUP $GTLANGS/lang-fit/src/analyser-gt-norm.xfst'


