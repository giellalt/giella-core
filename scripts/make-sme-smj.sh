
# geeavat scripta ná (gos nu terminálas):
# sh make-sme-smj.sh

echo ""
echo ""
echo " ==> Kompileren dál buot prográmmaid sme-smj-MT dihte <=="
echo ""
echo ""
echo " ------------------------------------------ na, ferten muđui dárkkistit giella-core "
echo ""
pushd $GTHOME/giella-core && svn up && make
echo ""
echo " ------------------------------------------ de giella-core lea ortnegis. "
echo ""
echo " ------------------------------------------ Ozan ođđa fiillaid sme:i "
pushd $GTHOME/langs/sme 
echo " svn up..."
echo " ------------------------------------------ ja de kompileren sme (dat ádjána :-(, "
./autogen.sh &&  ./configure --with-hfst --enable-apertium  --enable-reversed-intersect  &&  time make -j3
echo " ------------------------------------------ válmmas "pushd $GTHOME/langs/sme
echo " ------------------------------------------ ja de ođđa smj-fiillat, "
pushd $GTHOME/langs/smj
echo " svn up..."
echo " ------------------------------------------ ja de kompileren smj, "
./autogen.sh &&  ./configure --with-hfst --enable-apertium  --enable-reversed-intersect  &&  time make -j3
echo " ------------------------------------------ válmmas "
pushd $GTAPERTIUM/nursery/apertium-sme-smj/
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
