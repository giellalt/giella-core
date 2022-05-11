#!/usr/bin/env python3
import sys
import subprocess

commands = """
cd $GTHOME/words/dicts/scripts
mkdir ../smenob/apertium1
java -jar /usr/share/java/Saxon-HE.jar -it:mai/n collect-dict-parts.xsl inDir=../smenob/src > ../smenob/apertium1/apertium.xml
java -jar /usr/share/java/Saxon-HE.jar -it:main gtdict2simple-apertiumdix.xsl inFile=../smenob/apertium1/apertium.xml outDir=../smenob/apertium2/
~/repos/githubs/apertium-dixtools/apertium-dixtools dix2trie ../smenob/apertium2/apertium.xml lr aha.xml

"""
pair = sys.argv[1]
lang1 = pair[:3]
lang2 = pair[3:]
commands = [
    (
        f"java -jar /usr/share/java/Saxon-HE.jar "
        "-it:main $GTHOME/words/dicts/scripts/collect-dict-parts.xsl "
        "inDir=$GTHOME/words/dicts/{pair}/src > $GTHOME/words/dicts/{pair}/apertium1/apertium.xml"
    ),
    (
        f"java -jar /usr/share/java/Saxon-HE.jar "
        "-it:main $GTHOME/words/dicts/scripts/gtdict2simple-apertiumdix.xsl "
        "inFile=$GTHOME/words/dicts/{pair}/apertium1/apertium.xml outDir=$GTHOME/words/dicts/{pair}/apertium2/"
    ),
    (
        "apertium-dixtools dix2trie "
        f"$GTHOME/words/dicts/{pair}/real/apertium.xml "
        f"lr $GTHOME/apps/dicts/apertium_dict/dics/{lang1}-{lang2}-lr-trie.xml"
    ),
]

for command in commands:
    print(command)
    try:
        subprocess.run(command.split())
    except subprocess.CalledProcessError as error:
        print(error)
        sys.exit(1)
