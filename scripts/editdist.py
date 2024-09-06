#!/usr/bin/env python3
# see editdist.py --help for usage

import struct
import sys
from argparse import ArgumentParser

DEBUG = False

USAGE_STRING = "usage: {} [options] alphabet"

INFO_STRING = """
Produce an edit distance transducer.

Output is either an arc-by-arc -generated ATT listing (deprecated), or a large
regular expression.

There are three ways to give the alphabet and weights:

* giving the alphabet as a command line argument
    (weights are implicitly 1.0 per error)
* giving a file with specialized configuration syntax
* giving a transducer in optimized-lookup format to induce an alphabet
    (in this case only symbols with length 1 are considered,
    and weights are implicitly 1.0 per error)

These ways may be combined freely.

The specification file should be in the following format:
* First, an (optional) list of tokens separated by newlines
  All transitions involving these tokens that are otherwise unspecified
  are generated with weight 1.0. Symbol weights can be specified by appending
  a tab and a weight to the symbol. Transitions involving such a symbol
  will have the user-specified weight added to it.
* If you want to exclude symbols that may be induced from a transducer,
  add a leading ~ character to that line.
* If you want to specify transitions, insert a line with the content "@@"
  (without the quotes)
* In the following lines, specified transitions with the form
  FROM <TAB> TO <TAB> WEIGHT
  where FROM is the source token, TO is the destination token and WEIGHT is
  a nonnegative floating point number specifying the weight. By default,
  if only one transition involving FROM and TO is specified, the same WEIGHT
  will be used to specify the transition TO -> FROM (assuming that both are
  listed in the list of tokens).
* If the command line option to generate swaps is set, you can also specify swap
  weights with
  FROM,TO <TAB> TO,FROM <TAB> WEIGHT
  Again, unspecified swaps will be generated automatically with weight 1.0.
* Lines starting with ## are comments.

with d for distance and S for size of alphabet plus one
(for epsilon), expected output is a transducer in ATT format with
* Swapless:
** d + 1 states
** d*(S^2 + S - 1) transitions
* Swapful:
** d*(S^2 - 3S + 3) + 1 states
** d*(3S^2 - 5S + 3) transitions
"""

OTHER = "@_UNKNOWN_SYMBOL_@"


class MyArgumentParser(ArgumentParser):
    # This is needed to override the formatting of the help string
    def format_epilog(self, formatter):
        return self.epilog


# Some utility classes


class Header:
    """Read and provide interface to header"""

    def __init__(self, file):
        bytes = file.read(5)  # "HFST\0"
        if str(struct.unpack_from("<5s", bytes, 0)) == "('HFST\\x00',)":
            # just ignore any hfst3 header
            remaining = struct.unpack_from("<H", file.read(3), 0)[0]
            self.handle_hfst3_header(file, remaining)
            # 2 unsigned shorts, 4 unsigned ints and 9 uint-bools
            bytes = file.read(56)
        else:
            bytes = bytes + file.read(56 - 5)
        self.number_of_input_symbols = struct.unpack_from("<H", bytes, 0)[0]
        self.number_of_symbols = struct.unpack_from("<H", bytes, 2)[0]
        self.size_of_transition_index_table = \
            struct.unpack_from("<I", bytes, 4)[0]
        self.size_of_transition_target_table = \
            struct.unpack_from("<I", bytes, 8)[0]
        self.number_of_states = struct.unpack_from("<I", bytes, 12)[0]
        self.number_of_transitions = struct.unpack_from("<I", bytes, 16)[0]
        self.weighted = struct.unpack_from("<I", bytes, 20)[0] != 0
        self.deterministic = struct.unpack_from("<I", bytes, 24)[0] != 0
        self.input_deterministic = struct.unpack_from("<I", bytes, 28)[0] != 0
        self.minimized = struct.unpack_from("<I", bytes, 32)[0] != 0
        self.cyclic = struct.unpack_from("<I", bytes, 36)[0] != 0
        self.has_epsilon_epsilon_transitions = (
            struct.unpack_from("<I", bytes, 40)[0] != 0
        )
        self.has_input_epsilon_transitions = \
            struct.unpack_from("<I", bytes, 44)[0] != 0
        self.has_input_epsilon_cycles = \
            struct.unpack_from("<I", bytes, 48)[0] != 0
        self.has_unweighted_input_epsilon_cycles = (
            struct.unpack_from("<I", bytes, 52)[0] != 0
        )

    def handle_hfst3_header(self, file, remaining):
        _ = struct.unpack_from("<" + str(remaining) +
                               "c", file.read(remaining), 0)
        # assume the h3-header doesn't say anything surprising for now


class Alphabet:
    """Read and provide interface to alphabet"""

    def __init__(self, file, number_of_symbols):
        stderr_u8 = sys.stderr
        # list of unicode objects, use foo.encode("utf-8") to print
        self.key_table = []
        for _ in range(number_of_symbols):
            symbol = ""
            while True:
                byte = file.read(1)
                if byte == "\0":  # a symbol has ended
                    symbol = str(symbol, "utf-8")
                    if len(symbol) != 1:
                        stderr_u8.write("Ignored symbol " + symbol + "\n")
                    else:
                        self.key_table.append(symbol)
                    break
                symbol += byte


def p(string):  # stupid python, or possibly stupid me
    return string.encode("utf-8")


def maketrans(from_st, to_st, from_sy, to_sy, weight):
    return (
        str(from_st)
        + "\t"
        + str(to_st)
        + "\t"
        + p(from_sy)
        + "\t"
        + p(to_sy)
        + "\t"
        + str(weight)
    )


class Transducer:
    def __init__(self, alphabet, options, _other=OTHER):
        self.alphabet = alphabet
        self.substitutions = {}
        self.swaps = {}
        self.options = options
        self.other = _other
        self.transitions = []
        # the first self.distance states are always used, for others we
        # grab state numbers from this counter
        self.state_clock = self.options.distance + 1
        self.debug_messages = []

    def process_pair_info(self, specification):
        for pair, weight in specification["edits"].items():
            self.substitutions[pair] = weight
        for pairpair, weight in specification["swaps"].items():
            self.swaps[pairpair] = weight

    def generate(self):
        # for substitutions and swaps that weren't defined by the user,
        # generate standard subs and swaps
        if (self.other, self.options.epsilon) not in self.substitutions:
            self.substitutions[
                (self.other, self.options.epsilon)
            ] = self.options.default_weight
        for symbol in list(self.alphabet.keys()):
            if (self.other, symbol) not in self.substitutions:
                self.substitutions[(self.other, symbol)] = (
                    self.options.default_weight + self.alphabet[symbol]
                )
            if (self.options.epsilon, symbol) not in self.substitutions:
                self.substitutions[(self.options.epsilon, symbol)] = (
                    self.options.default_weight + self.alphabet[symbol]
                )
            if (symbol, self.options.epsilon) not in self.substitutions:
                self.substitutions[(symbol, self.options.epsilon)] = (
                    self.options.default_weight + self.alphabet[symbol]
                )
            for symbol2 in list(self.alphabet.keys()):
                if symbol == symbol2:
                    continue
                if ((symbol, symbol2), (symbol2, symbol)) not in self.swaps:
                    if ((symbol2, symbol), (symbol, symbol2)) in self.swaps:
                        self.swaps[((symbol, symbol2), (symbol2, symbol))] = \
                            self.swaps[((symbol2, symbol), (symbol, symbol2))]
                    else:
                        self.swaps[((symbol, symbol2), (symbol2, symbol))] = (
                            self.options.default_weight
                            + self.alphabet[symbol]
                            + self.alphabet[symbol2]
                        )
                if (symbol, symbol2) not in self.substitutions:
                    if (symbol2, symbol) in self.substitutions:
                        self.substitutions[(symbol, symbol2)] = \
                            self.substitutions[(symbol2, symbol)]
                    else:
                        self.substitutions[(symbol, symbol2)] = (
                            self.options.default_weight
                            + self.alphabet[symbol]
                            + self.alphabet[symbol2]
                        )

    def make_identities(self, state, nextstate=None):
        if nextstate is None:
            nextstate = state

        return [
            maketrans(state, nextstate, symbol, symbol, 0.0)
            for symbol in list(self.alphabet.keys())
            if symbol not in (self.options.epsilon, self.other)
        ]

    def make_swaps(self, state, nextstate=None):
        if nextstate is None:
            nextstate = state + 1
        ret = []
        if self.options.swap:
            for swap in self.swaps:
                swapstate = self.state_clock
                self.state_clock += 1
                self.debug_messages.append(
                    str(swapstate)
                    + " is a swap state for "
                    + swap[0][0]
                    + " and "
                    + swap[0][1]
                )
                ret.append(
                    maketrans(
                        state, swapstate, swap[0][0],
                        swap[0][1], self.swaps[swap]
                    )
                )
                ret.append(maketrans(swapstate, nextstate,
                                     swap[1][0], swap[1][1], 0.0))
        return ret

    # for substitutions, we try to eliminate redundancies by refusing to do
    # deletion right after insertion and insertion right after deletion
    def make_substitutions(self, state, nextstate=None):
        if nextstate is None:
            nextstate = state + 1
        ret = []
        eliminate = False
        # unless we're about to hit the maximum edit or we're not eliminating
        # redundancies, make skip states for delete and insert
        if (nextstate < self.options.distance) and not self.options.no_elim:
            eliminate = True
            delete_skip = self.state_clock
            self.state_clock += 1
            insert_skip = self.state_clock
            self.state_clock += 1
            ret += self.make_identities(delete_skip, nextstate)
            ret += self.make_swaps(delete_skip, nextstate + 1)
            ret += self.make_identities(insert_skip, nextstate)
            ret += self.make_swaps(insert_skip, nextstate + 1)

        for sub in self.substitutions:
            if not eliminate:
                ret.append(
                    maketrans(state, nextstate, sub[0],
                              sub[1], self.substitutions[sub])
                )
            elif sub[1] is self.options.epsilon:  # (eliminating) deletion
                ret.append(
                    maketrans(
                        state, delete_skip, sub[0],
                        sub[1], self.substitutions[sub]
                    )
                )
                for sub2 in self.substitutions:
                    # after deletion, refuse to do insertion
                    if sub2[0] != self.options.epsilon:
                        ret.append(
                            maketrans(
                                delete_skip,
                                nextstate + 1,
                                sub2[0],
                                sub2[1],
                                self.substitutions[sub2],
                            )
                        )
            elif sub[0] is self.options.epsilon:  # (eliminating) insertion
                ret.append(
                    maketrans(
                        state, insert_skip, sub[0],
                        sub[1], self.substitutions[sub]
                    )
                )
                for sub2 in self.substitutions:
                    # after insertion, refuse to do deletion
                    if sub2[1] != self.options.epsilon:
                        ret.append(
                            maketrans(
                                insert_skip,
                                nextstate + 1,
                                sub2[0],
                                sub2[1],
                                self.substitutions[sub2],
                            )
                        )
            else:
                ret.append(
                    maketrans(state, nextstate, sub[0],
                              sub[1], self.substitutions[sub])
                )
        return ret

    def make_transitions(self):
        # If we're not editing in the initial state, there's an extra state
        # where we just want identities
        for state in range(self.options.distance + self.options.no_initial):
            if self.options.minimum_edit != 0:
                self.options.minimum_edit -= 1
            else:
                self.transitions.append(str(state) + "\t0.0")  # final states
            if state == 0 and self.options.no_initial:
                self.transitions += self.make_identities(state, state + 1)
                continue  # Don't do initial corrections
            else:
                self.transitions += self.make_identities(state)
            self.transitions += self.make_substitutions(state)
            self.transitions += self.make_swaps(state)
        self.transitions += self.make_identities(
            self.options.distance + self.options.no_initial
        )
        self.transitions.append(
            str(self.options.distance + self.options.no_initial) + "\t0.0"
        )


def replace_rules(alphabet, pair_info, weight, swap):
    corr = ' "<CORR>" '
    unk = OTHER
    corrections = "["
    # first, the empty string may become the empty string anywhere
    corrections += '"" -> \t[ "" |\n'
    for a in alphabet:
        this_weight = alphabet[a]
        # insertions
        if ("", a) in pair_info["edits"]:
            this_weight = pair_info["edits"][("", a)] + alphabet[a]
        corrections += f'\t[ "{a}" {corr} ]::{this_weight} |\n'
    # trim the extra left by the last pass
    corrections = corrections[:-3]
    corrections += " ] ,,\n"
    for a in alphabet:
        this_weight = alphabet[a]
        # the left-hand side of the rule
        corrections += f'"{a}" ->\t[ '
        # identity
        corrections += f'"{a}" |\n'
        # deletion
        if (a, "") in pair_info["edits"]:
            this_weight = pair_info["edits"][(a, "")]
        # the actual deletion expression
        corrections += f'\t[ ""{corr}]::{weight} |\n'
        # substitutions
        for b in alphabet:
            this_weight = alphabet[b]  # old: weight + alphabet[b]
            if a == b:
                # we don't handle identities here
                continue
            if (a, b) in pair_info["edits"]:
                this_weight = pair_info["edits"][(a, b)]  # + alphabet[b] # xxx
            corrections += f'\t[ "{b}"{corr}]::{this_weight} |\n'

        corrections = corrections[:-3]
        corrections += " ] ,,\n"
    # now the unknown symbol
    # Initial line unk regex
    corrections += f'"{unk}" -> [\n\t[""{corr}]::{weight} |\n'
    for a in alphabet:  # unk -> the whole alphabet:
        this_weight = alphabet[a]
        # for each target symbol, use the weight of that symbol
        corrections += f'\t[ "{a}"{corr}]::{this_weight} |\n'

    # trim the end again
    corrections = corrections[:-3]
    corrections += " ]]"
    # and finally swaps, if enabled:
    if swap:
        corrections += "\n | \n[\n"
        for a in alphabet:
            for b in alphabet:
                if a == b:
                    # we don't handle identities here
                    continue
                frompair = (a, b)
                topair = (b, a)
                if (frompair, topair) in pair_info["swaps"]:
                    this_weight = pair_info["swaps"][(frompair, topair)]
                    corrections += f'["{a}" "{b}"] -> [ "{b}" "{a}"' + \
                            f'{corr}]::{this_weight} ,\n'
                else:
                    corrections += f'["{a}" "{b}"] -> [ "{b}" "{a}"' + \
                            f'{corr}]::{weight} ,\n'
        corrections = corrections[:-3]
        corrections += " ]"
    return corrections


def parse_options():
    parser = MyArgumentParser(usage=USAGE_STRING, epilog=INFO_STRING)
    parser.add_argument(
        "-r",
        "--regex",
        action="store_true",
        dest="make_regex",
        help="write a regular expression",
    )
    parser.add_argument(
        "-e",
        "--epsilon",
        dest="epsilon",
        help="specify symbol to use as epsilon, default is @0@",
        metavar="EPS",
    )
    parser.add_argument(
        "-d",
        "--distance",
        type=int,
        dest="distance",
        help="specify edit depth, default is 1",
        metavar="DIST",
    )
    parser.add_argument(
        "-w",
        "--default-weight",
        type=float,
        dest="default_weight",
        help="weight per correction when nothing else is specified (the default weigiht is 1.0)",
        metavar="DIST",
    )
    parser.add_argument(
        "-s",
        "--swap",
        action="store_true",
        dest="swap",
        help="generate swaps (as well as insertions and deletions)",
    )
    parser.add_argument(
        "--no-elim",
        action="store_true",
        dest="no_elim",
        help="don't do redundancy elimination",
    )
    parser.add_argument(
        "-m",
        "--minimum-edit",
        type=int,
        dest="minimum_edit",
        help="minimum accepting edit (default is 1)",
    )
    parser.add_argument(
        "--no-string-initial-correction",
        action="store_true",
        dest="no_initial",
        help="don't make corrections at the beginning of the string",
    )
    parser.add_argument(
        "-i",
        "--input",
        dest="inputfile",
        help="optional file with special edit-distance syntax",
        metavar="INPUT",
    )
    parser.add_argument(
        "-o",
        "--output-file",
        dest="outputfile",
        help="output file (default is stdout)",
        metavar="OUTPUT",
    )
    parser.add_argument(
        "-a",
        "--alphabet",
        dest="alphabetfile",
        help="read the alphabet from an existing" +
             "optimized-lookup format transducer",
        metavar="ALPHABET",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        dest="verbose",
        help="print some diagnostics to standard error",
    )
    parser.add_argument("alphabetstring", nargs="*")
    parser.set_defaults(make_regex=False)
    parser.set_defaults(epsilon="@0@")
    parser.set_defaults(distance=1)
    parser.set_defaults(default_weight=1.0)
    parser.set_defaults(swap=False)
    parser.set_defaults(no_elim=False)
    parser.set_defaults(no_initial=False)
    parser.set_defaults(minimum_edit=0)
    parser.set_defaults(verbose=False)

    return parser.parse_args()


def main():
    options = parse_options()
    alphabet = {}
    exclusions = set()
    pair_info = {"edits": {}, "swaps": {}}

    if options.inputfile is None and options.alphabetfile is None \
            and len(options.alphabetstring) == 0:
        print("Specify at least one of INPUT, ALPHABET or alphabet string")
        sys.exit()
    if len(options.alphabetstring) > 1:
        print("Too many options!")
        sys.exit()

    if options.outputfile is None:
        outputfile = sys.stdout
    else:
        outputfile = open(options.outputfile, "w")

    if options.inputfile is not None:
        try:
            inputfile = open(options.inputfile)
        except IOError:
            print("Couldn't open " + options.inputfile)
            sys.exit()
        while True:
            # first the single-symbol info
            line = inputfile.readline()
            if line in ("@@\n", ""):
                break
            if line.strip() != "":
                if line.startswith("##"):
                    continue
                if len(line) > 1 and line.startswith("~"):
                    exclusions.add(line[1:].strip())
                    continue
                if "\t" in line:
                    weight = float(line.split("\t")[1])
                    symbol = line.split("\t")[0]
                else:
                    weight = options.default_weight  # should be default_weight
                    symbol = line.strip("\n")
                alphabet[symbol] = weight
        while True:
            # then pairs
            line = inputfile.readline()
            if line.startswith("##"):
                continue
            if line == "\n":
                continue
            if line == "":
                break
            parts = line.split("\t")
            if len(parts) != 3:
                raise ValueError(
                    "Got specification with "
                    + str(len(parts))
                    + " parts, expected 3:\n"
                )
            weight = float(parts[2])
            if "," in parts[0]:
                frompair = tuple(parts[0].split(","))
                topair = tuple(parts[1].split(","))
                if not len(frompair) == len(topair) == 2:
                    raise ValueError(
                        "Got swap-specification with incorrect number "
                        "of comma separators:\n"
                    )
                if (frompair, topair) not in pair_info["swaps"]:
                    pair_info["swaps"][(frompair, topair)] = weight
                for sym in [frompair[0], frompair[1], topair[0], topair[1]]:
                    if sym != "" and sym not in alphabet:
                        alphabet[sym] = weight
            else:
                if (parts[0], parts[1]) not in pair_info["edits"]:
                    pair_info["edits"][(parts[0], parts[1])] = weight
                for sym in [parts[0], parts[1]]:
                    if sym != "" and sym not in alphabet:
                        alphabet[sym] = weight

    if len(options.alphabetstring) == 1:
        for c in str(options.alphabetstring[0], "utf-8"):
            if c not in list(alphabet.keys()) and c not in exclusions:
                alphabet[c] = 0.0
    if options.alphabetfile is not None:
        afile = open(options.alphabetfile, "rb")
        ol_header = Header(afile)
        ol_alphabet = Alphabet(afile, ol_header.number_of_symbols)
        for c in [x for x in ol_alphabet.key_table[:] if x.strip() != ""]:
            if c not in list(alphabet.keys()) and c not in exclusions:
                alphabet[c] = 0.0
    _ = options.epsilon

    if options.make_regex:
        corrections = replace_rules(
            alphabet, pair_info, options.default_weight, options.swap
        )
        corr_counter = (
            '[[ [? - "<CORR>"]* ( "<CORR>":0 ) [? - "<CORR>"]* ]^'
            + str(options.distance)
            + "]"
        )
        corr_eater = '[[? - "<CORR>"]*]'
        full_regex = (
            corr_eater + "\n.o.\n" + corrections +
            "\n.o.\n" + corr_counter + ";\n"
        )
        outputfile.write(full_regex)
    else:
        transducer = Transducer(alphabet, options)
        transducer.process_pair_info(pair_info)
        transducer.generate()
        transducer.make_transitions()
        for transition in transducer.transitions:
            outputfile.write(transition.decode("utf-8"))
            outputfile.write("\n")

        stderr_u8 = sys.stderr

        if options.verbose:
            stderr_u8.write(
                "\n"
                + str(transducer.state_clock)
                + " states and "
                + str(len(transducer.transitions))
                + " transitions written for "
                + "distance "
                + str(options.distance)
                + " and base alphabet size "
                + str(len(transducer.alphabet))
                + "\n\n"
            )
            stderr_u8.write("The alphabet was:\n")
            for symbol, weight in alphabet.items():
                stderr_u8.write(symbol + "\t" + str(weight) + "\n")
            if len(exclusions) != 0:
                stderr_u8.write("The exclusions were:\n")
                for symbol in exclusions:
                    stderr_u8.write(symbol + "\n")
            print()
            if options.debug:
                for message in transducer.debug_messages:
                    print(message)


if __name__ == "__main__":
    main()
