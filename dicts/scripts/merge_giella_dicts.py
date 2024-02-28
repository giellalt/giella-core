"""
Extract all <e> elements from all giella-style dictionaries (.xml files)
in a directory, and gather them into one giant tree, then save this new,
merged dictionary to a file.

This does the same as (and hence replaces) collect-dict-parts.xsl

This script can also be imported from python code, see the comment in the file.
"""
import xml.etree.ElementTree as ET
from pathlib import Path


# To import this function for use in a python script, use the following code:
#
# ```python
# try:
#     # if GUTHOME (the gut directory) environment variable is set...
#     GUTHOME = os.environ["GUTHOME"]
#     script_directory = os.path.join(GUTHOME, "giellalt", "giella-core", "dicts")
#     # ...and the scripts directory have been moved to git ...
#     if not os.path.isdir(script_directory):
#         raise KeyError
# except KeyError:
#     # assuming that GTHOME is set
#     GTHOME = os.environ["GTHOME"]
#     script_directory = os.path.join(GTHOME, "words", "dicts", "scripts")
# finally:
#     sys.path.append(script_directory)
#     from merge_giella_dicts import merge_giella_dicts
#
# # USAGE:
# n_entries = merge_giella_dicts("path/to/dict-xxx-yyy/src", "/some/output/file")
# ```


def merge_giella_dicts(directory, out_file):
    if isinstance(directory, str):
        directory = Path(directory)
    if not isinstance(directory, Path):
        raise TypeError("argument `directory`: must be pathlib.Path or str")
    if out_file is not None and not isinstance(out_file, (Path, str)):
        raise TypeError("argument `out_file`: must be pathlib.Path, str or None")

    directory = directory.resolve()
    if not directory.is_dir():
        raise NotADirectoryError("not a directory")

    xml_files = list(directory.glob("*.xml"))
    if not xml_files:
        raise FileNotFoundError("no .xml files in directory")

    r = ET.Element("r")
    n_entries = 0
    for file in xml_files:
        with open(file) as f:
            text = f.read()
        try:
            tree = ET.fromstring(text)
        except ET.ParseError as e:
            print(f"Warning: XML error in file {file}", file=sys.stderr)
            print("The process continues, but the contents of this file will "
                  "not be included in the merged output")
            print(e, file=sys.stderr)
            continue
        if tree.tag != "r":
            # root node not <r>, not a giella xml dictionary
            # (this can be the meta.xml file, for example)
            continue
        es = list(tree.iter("e"))
        n_entries += len(es)
        r.extend(es)

    merged_tree_s = ET.tostring(r, encoding="unicode", xml_declaration=True)
    if out_file is None:
        print(merged_tree_s)
    else:
        with open(out_file, "w") as f:
            f.write(merged_tree_s)

    return n_entries


if __name__ == "__main__":
    import argparse
    import sys
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("directory",
                        help="The dictionary directory of .xml files")
    parser.add_argument("-o", "--out-file", default=None,
                        help="The file to save to. If not given, print to "
                             "standard output")
    parser.add_argument("--count", action=argparse.BooleanOptionalAction,
                        help="Print how many entries is in the merged output "
                             "tree to stderr after completion. By defaults it "
                             "does not print.")
    args = parser.parse_args()

    try:
        n_entries = merge_giella_dicts(args.directory, args.out_file)
    except (NotADirectoryError, FileNotFoundError) as e:
        print(f"Error: {e}", file=sys.stderr)

    if args.count:
        print(n_entries, file=sys.stderr)
