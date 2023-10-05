for i in *.xml
do
  perl tagharmonising.pl $i > new/$i
done