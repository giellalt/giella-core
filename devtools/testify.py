#!/usr/bin/env -O python3

import ast
import sys


def errtype2sym(errtype: str):
    if errtype.startswith("typo"):
        return "$"
    elif errtype.startswith("msyn"):
        return "£"
    elif errtype.startswith("syn"):
        return "¥"
    else:
        return "§"


def main():
    for line in sys.stdin:
        line = line.strip()
        textstart = line.find("\"text\":\"")
        textend = -2
        text = line[textstart+len("\"text\":\""):textend]
        errstart = line.find("\"errs\":")
        errsegment = line[errstart+len("\"errs\":"):textstart-1]
        # it's json yaml but we just smush it thoruhg literal_eval, ok?
        errs = ast.literal_eval(errsegment[1:-1])
        # if we go stuff through in reverse order we can rewrite text without
        # messing up previous indices as long as errors don't overlap
        safespot = len(text)+1
        for err in errs[::-1]:
            if isinstance(err, int):
                print("weird error data!", err, file=sys.stderr)
                continue
            elif isinstance(err, str):
                print("weird error data:", err, file=sys.stderr)
                continue
            if len(err) != 7:
                print("weird error data ", len(err), err, file=sys.stderr)
                continue
            try:
                if int(err[1]) < safespot:
                    text = text[:int(err[2])] + "}" +\
                            errtype2sym(err[3]) + "{" + \
                            err[3] + "|FIXME}" + text[int(err[2]):]
                    text = text[:int(err[1])] + "{" + text[int(err[1]):]
                    safespot = int(err[1])
            except ValueError as ve:
                print("weird error data??", err, ve, file=sys.stderr)
            except IndexError as ie:
                print("weird error data???", err, ie, file=sys.stderr)
        print(text)


if __name__ == "__main__":
    main()
