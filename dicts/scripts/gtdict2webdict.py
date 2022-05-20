#!/usr/bin/env python3
import os
import subprocess
import sys


def get_saxonlib():
    saxonplaces = [
        "/usr/share/java/Saxon-HE.jar",
        "/opt/local/share/java/saxon9he.jar",
        f"{os.getenv('HOME')}/lib/saxon9.jar",
    ]
    for saxonlib in saxonplaces:
        if os.path.exists(saxonlib):
            return saxonlib

    print(f"Saxon was not found. Expected to find it one of these places:")
    print("\n".join(saxonplaces))


def sanity_check():
    ok = True
    if os.getenv("GTHOME") is None:
        print("The environment variable GTHOME is not defined.")
        ok = False

    if not os.path.exists("/usr/local/bin/apertium-dixtools"):
        print("apertium-dixtools is not installed. Please install it.")
        ok = False

    return ok


def convert(pair, saxonlib, pairdir):
    lang1 = pair[:3]
    lang2 = pair[3:]
    commands = [
        (
            f"java -jar {saxonlib} "
            f"-it:main {os.getenv('GTHOME')}/words/dicts/scripts/collect-dict-parts.xsl "
            f"inDir={pairdir}/src"
        ),
        (
#            f"java -jar /usr/share/java/Saxon-HE.jar "
            f"java -jar {saxonlib} "
            f"-it:main {os.getenv('GTHOME')}/words/dicts/scripts/gtdict2simple-apertiumdix.xsl "
            f"inFile={pairdir}/apertium1/apertium.xml "
            f"outDir={pairdir}/apertium2/"
        ),
        (
            "apertium-dixtools dix2trie "
            f"{pairdir}/apertium2/apertium.xml "
            f"lr {os.getenv('GTHOME')}/apps/dicts/apertium_dict/dics/{lang1}-{lang2}-lr-trie.xml"
        ),
    ]

    print(commands[0])
    result = subprocess.run(commands[0].split(), capture_output=True)
    outdir1 = os.path.join(pairdir, "apertium1")
    if not os.path.exists(outdir1):
        os.mkdir(outdir1)
    outfile1 = os.path.join(outdir1, "apertium.xml")
    with open(outfile1, "wb") as outstream1:
        outstream1.write(result.stdout)

    stream_lined_commands(commands[1:])


def stream_lined_commands(commands):
    for command in commands:
        print(command)
        try:
            subprocess.run(command.split(), capture_output=True)
        except subprocess.CalledProcessError as error:
            print("error:", error)
            sys.exit(1)


def main():
    if len(sys.argv) != 2:
        print("Error: Too few arguments.")
        print("usage: gtdict2webdict.py <languagepair>")
        print(
            f'<languagepair> is a directory in {os.path.join(os.getenv("GTHOME"), "words", "dicts")}'
        )
        sys.exit(1)

    pair = sys.argv[1]
    saxonlib = get_saxonlib()

    if not sanity_check():
        print("Cannot run, fix the above errors and try again")
        sys.exit(1)

    pairdir = os.path.join(os.getenv("GTHOME"), "words", "dicts", pair)
    if not os.path.exists(pairdir):
        print(f"The dictionary directory {pairdir} does not exist.")
        sys.exit(1)

    convert(pair, saxonlib, pairdir)


if __name__ == "__main__":
    main()
