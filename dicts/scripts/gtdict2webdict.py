#!/usr/bin/env python3
import os
import subprocess
import sys

pair = sys.argv[1]
lang1 = pair[:3]
lang2 = pair[3:]
commands = [
    (
        f"java -cp /usr/share/java/Saxon-HE.jar "
        f"-it:main {os.getenv('GTHOME')}/words/dicts/scripts/collect-dict-parts.xsl "
        f"inDir={os.getenv('GTHOME')}/words/dicts/{pair}/src"
    ),
    (
        f"java -jar /usr/share/java/Saxon-HE.jar "
        f"-it:main {os.getenv('GTHOME')}/words/dicts/scripts/gtdict2simple-apertiumdix.xsl "
        f"inFile={os.getenv('GTHOME')}/words/dicts/{pair}/apertium1/apertium.xml "
        f"outDir={os.getenv('GTHOME')}/words/dicts/{pair}/apertium2/"
    ),
    (
        "apertium-dixtools dix2trie "
        f"{os.getenv('GTHOME')}/words/dicts/{pair}/apertium2/apertium.xml "
        f"lr {os.getenv('GTHOME')}/apps/dicts/apertium_dict/dics/{lang1}-{lang2}-lr-trie.xml"
    ),
]

print(commands[0])
result = subprocess.run(commands[0].split(), capture_output=True)
outdir1 = os.path.join(os.getenv("GTHOME"), "words/dicts", pair, "apertium1")
os.mkdir(outdir1)
outfile1 = os.path.join(outdir1, "apertium.xml")
with open(outfile1, "wb") as outstream1:
    outstream1.write(result.stdout)

print(commands[1])
try:
    subprocess.run(commands[1].split(), capture_output=True)
except subprocess.CalledProcessError as error:
    print(error)
    sys.exit(1)

print(commands[2])
try:
    subprocess.run(commands[2].split(), capture_output=True)
except subprocess.CalledProcessError as error:
    print(error)
    sys.exit(1)
