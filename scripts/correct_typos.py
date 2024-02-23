#!/usr/bin/env python3
"""Read a corrections file (path as first argument to the script)
and then read line by line from standard input, and substitute each
word with the correct one from the corrections file."""
from sys import stdin, argv

if len(argv) <= 1:
    exit("usage: python {argv[0]} <correction_file>")


def read_corrections_file(path):
    lookups = {}
    with open(path, "r") as f:
        lines = f.readlines()
        for line in lines:
            line = line.strip()
            try:
                wrong, right = line.split("\t")
            except ValueError:
                pass
            else:
                lookups[wrong] = right
    return lookups


def main():
    correction_file = argv[1]
    corrections = read_corrections_file(correction_file)

    for line in stdin.readlines():
        line = line.strip()
        if not line:
            continue
        print(corrections.get(line, line), flush=True)


if __name__ == "__main__":
    raise SystemExit(main())
