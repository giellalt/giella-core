#!/bin/sh

echo ""
echo " This script will compile in our new infrastructure"
echo ""


echo ""
echo "===>     All the newinfra languages      <==="
pushd $GTHOME/langs

echo " -------------------------------------------------------------------------------------- bxr, Buriad "
cd   bxr && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- ciw, Ojibwe "
cd ../ciw && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- cor, Cornish "
cd ../cor && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- crk, Plains Cree "
cd ../crk && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- est, Estonian "
cd ../est && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- fao, Faroese "
cd ../fao && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- fin, Finnish "
cd ../fin && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- hdn, Northern Haida "
cd ../hdn && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- cor, Cornish "
cd ../cor && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- ipk, Iñupiaq "
cd ../ipk && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- izh, Izhorian "
cd ../izh && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- kal, Greenlandic "
echo " "
echo " No, sorry, we skip Greenlandic. It takes to long time to compile."
echo " In order to compile Greenlandic, do this:"
echo " cd $GTHOME/langs/kal/"
echo " ./autogen.sh -l && ./configure --with-hfst && make "
echo " "
cd ../kal && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- kca, Khanty "
cd ../kca && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- kpv, Komi Zyryan "
cd ../kpv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- liv, Livonian "
cd ../liv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- lut, Lushootseed "
cd ../lut && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- mdf, Moksha "
cd ../mdf && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- mhr, Meadow Mari "
cd ../mhr && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst --without-xfst && nice time make 
echo " -------------------------------------------------------------------------------------- mns, Northern Mansi "
cd ../mns && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- mrj, Hill Mari "
cd ../mrj && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- myv, Erzya "
cd ../myv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- ndl, Ndolo "
cd ../ndl && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- nio, Nganasan "
cd ../nio && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- nob, Norwegian Bokmål "
cd ../nob && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- olo, Olonetsian "
cd ../olo && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- ron, Rumanian "
cd ../ron && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- rup, Arumanian "
cd ../rup && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- rus, Russian "
cd ../rus && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- sjd, Kildin Saami "
cd ../sjd && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- sje, Pite Saami "
cd ../sje && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- sma, South Saami "
cd ../sma && pwd && nice ./autogen.sh -l && nice ./configure --enable-oahpa && nice time make   # adjectives.lexc
#cd ../sma && pwd && nice ./autogen.sh -l && nice ./configure --enable-oahpa && nice time make  # adjectives-oahpa.lexc
echo " -------------------------------------------------------------------------------------- smj, Lule Saami "
cd ../smj && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- smn, Inari Saami "
cd ../smn && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- sms, Skolt Saami "
cd ../sms && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- som, Somali "
cd ../som && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- tat, Tatar "
cd ../tat && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- tku, Upper Nekaxa Totonac "
cd ../tku && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- udm, Udmurt "
cd ../udm && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- vep, Veps "
cd ../vep && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- vro, Võro "
cd ../vro && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- yrk, Tundra Nenets "
cd ../yrk && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
echo " -------------------------------------------------------------------------------------- zul, Zulu "
cd ../zul && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 





echo ""
echo "===>     Dictionaries   <===" 
echo ""
echo "===>   South Sámi - Norwegian (South Sámi lemmata only) <===" 
cd $GTHOME/words/dicts/smanob
nice time make
nice time make -f make-smadict
echo ""
echo "===>   North Sámi - Norwegian   <===" 
cd $GTHOME/words/dicts/smenob
nice time make
nice time make -f make-smedict
echo ""
echo "===>   Greenlandic - English   <===" 
cd $GTHOME/words/dicts/kaleng/src/
nice time make
echo ""
echo "===>   Greenlandic - Danish   <===" 
cd $GTHOME/words/dicts/kaldan/
nice time make

echo ""
echo "===>   Geographic fst   <===" 
cd $GTHOME/words/dicts/smi/geo/src/
nice time make
echo ""
echo "===>   Kven - Norwegian   <===" 
cd $GTHOME/words/dicts/fkvnob/
nice time make
echo ""
echo "===>   Norwegian - Kven   <===" 
cd $GTHOME/words/dicts/nobfkv/
nice time make
# fitswe is not in the public domain.
#echo ""
#echo "===>   Meänkieli - Swedish   <===" 
#cd $GTHOME/words/dicts/fitswe/
#nice time make 
#echo ""
#echo "===>   Swedish - Meänkieli   <===" 
#cd $GTHOME/words/dicts/swefit
#nice time make



# echo " -------------------------------------------------------------------------------------- tlh, Klingon "
# cd ../tlh && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 
# echo " -------------------------------------------------------------------------------------- tuv, Turkana "
# cd ../tuv && pwd && nice ./autogen.sh -l && nice ./configure --with-hfst && nice time make 


popd
echo "===>                  <==="
echo "===>                  <==="
echo "===>                  <==="
echo "===> Done, at last  . <==="
echo "===>                  <==="
