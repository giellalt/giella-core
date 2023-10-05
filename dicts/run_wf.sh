
make clean S_LANG=sme T_LANG=nob
make S_LANG=sme T_LANG=nob wordform_macdict
pushd /Users/cipriangerstenberger/Library/Dictionaries/ActualDict
rm -rf *
cp -r ~cipriangerstenberger/gtsvn/words/dicts/smenob/macdir/objects .
popd

