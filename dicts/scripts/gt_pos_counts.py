#!/usr/bin/env python3

# gt_pos_counts.py
# run in a giellalt/dict-xxx-yyy directory, and print how many lemmas
# are found of each pos in the src/ xml files. E.g. output for dict-nob-sme:
# {"Num": 86, "V": 2348, "Phrase": 260, "Det": 21, "Po": 2, "Adv": 414, "A": 1758, "CC": 8, "CS": 14, "Pron": 88, "N": 21593, "Interj": 13, "total": 26657, "Pr": 52}

import xml.etree.ElementTree as ET
from pathlib import Path
from collections import defaultdict
import json


def handle_file(file):
    try:
        tree = ET.parse(file)
    except Exception:
        # unparsable xml file, ignore
        return

    root = tree.getroot()
    if root.tag != "r":
        # xml file with root that is not <r>, ignore
        return

    poses = defaultdict(int)
    for L in tree.iter("l"):
        poses[L.attrib.get("pos")] += 1
    return poses


def main():
    nlemmas = defaultdict(int)
    for file in Path("src/").glob("*.xml"):
        if result := handle_file(file):
            for k, v in result.items():
                nlemmas[k] += v

    nlemmas["total"] = sum(nlemmas.values())
    print(json.dumps(nlemmas))


if __name__ == "__main__":
    raise SystemExit(main())
