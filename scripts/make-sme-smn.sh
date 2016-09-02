
# geeavat scripta ná (gos nu terminálas):
# sh make-sme-smn.sh

echo ""
echo ""
echo " ==> Kompileren dál buot prográmmaid sme-smn-MT dihte <=="
echo ""
echo ""
echo " ------------------------------------------ na, ferten muđui dárkkistit gtcore "
echo ""
pushd $GTHOME/giella-core && svn up && make
echo ""
echo " ------------------------------------------ de gtcore lea ortnegis. "
echo ""
echo " ------------------------------------------ Ozan ođđa fiillaid sme:i "
pushd $GTHOME/langs/sme 
echo " svn up..."
echo " ------------------------------------------ ja de kompileren sme (dat ádjána :-(, "
./autogen.sh &&  ./configure --with-hfst --enable-apertium  --enable-reversed-intersect  &&  time make -j3
echo " ------------------------------------------ válmmas "pushd $GTHOME/langs/sme
echo " ------------------------------------------ ja de ođđa smn-fiillat, "
pushd $GTHOME/langs/smn
echo " svn up..."
echo " ------------------------------------------ ja de kompileren smn, "
./autogen.sh &&  ./configure --with-hfst --enable-apertium  --enable-reversed-intersect  &&  time make -j3
echo " ------------------------------------------ válmmas "
pushd $GTAPERTIUM/nursery/apertium-sme-smn/
echo " ------------------------------------------ ja de Apertiuma ođđa fiillat "
svn up
echo " ------------------------------------------ ja Apertiuma kompileren. "
time make -j3

popd
echo ""
echo ""
echo " ==> de buot galgá leat ortnegis. <=="
echo ""
echo ""
