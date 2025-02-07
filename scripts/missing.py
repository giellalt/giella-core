#!/usr/bin/env python3
"""Analyse tokenised input and provide lexc suggestions for missing words.

Make a suggestion for a missing word
    echo "word" | missing.py -l sme

Make a suggestion for a multiword expression
    echo "multi word" | missing.py -l sme

Make a suggestion for an unlexicalised compound or derivation
    echo "compoundword" | missing.py -l sme

Make suggestions for a whole corpus, save it to a file
    missing.py \\
        -l sme \\
        --input sme-tokenised-corpus-words.txt \\
        --output missing_sme_corpus.lexc
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from collections import defaultdict
from dataclasses import dataclass
import os
from pathlib import Path
import re
import subprocess
import sys
from typing import Iterable, Iterator, Optional


@dataclass
class LexcEntry:
    stem: str
    tags: list[str]
    lower: str
    contlex: str
    filename: str
    parent_lexicon: str

    def __str__(self) -> str:
        tags = "+".join(self.tags)
        return (
            f"{self.stem.replace(' ', '% ')}{'+' if tags else ''}{tags}:"
            f"{self.lower.replace(' ', '% ')} {self.contlex} ; "
            f"! {self.filename} {self.parent_lexicon}"
        )


LEXC_LINE_RE = re.compile(
    r"""
    (?P<contlex>\S+)            #  any nonspace
    (?P<translation>\s+".*")?   #  optional translation, might be empty
    \s*;\s*                     #  skip space and semicolon
    (?P<comment>!.*)?           #  followed by an optional comment
    $
""",
    re.VERBOSE | re.UNICODE,
)

LEXC_CONTENT_RE = re.compile(
    r"""
    (?P<exclam>^\s*!\s*)?          #  optional comment
    (?P<content>(<.+>)|(.+))?      #  optional content
""",
    re.VERBOSE | re.UNICODE,
)


def parse_line(old_match, lexc_filename: str, lexicon_name: str) -> Optional[LexcEntry]:
    """Parse a lexc line.

    Arguments:
        old_match:

    Returns:
        The entries inside the lexc line expressed as a dict
    """
    line_dict = defaultdict(str)

    line_dict["contlex"] = old_match.get("contlex")

    line = old_match.get("content")
    if not line:
        return None

    try:
        upper, lower = line.split(":")
    except ValueError:
        return None

    uppers = upper.split("+")
    line_dict["stem"] = uppers[0]
    line_dict["tags"] = uppers[1:]
    line_dict["lower"] = lower.strip()
    line_dict["filename"] = lexc_filename
    line_dict["parent_lexicon"] = lexicon_name

    return LexcEntry(**line_dict)


def make_lexc_entry(
    line: str, lexc_filename: str, lexicon_name: str
) -> Optional[dict[str, str]]:
    """Turn line into a dict using regexes.

    Args:
        line: The line to parse.

    Returns:
        The line as a dict.
    """
    match = LEXC_LINE_RE.search(line)

    if match:
        content = match.groupdict()
        match2 = LEXC_CONTENT_RE.match(LEXC_LINE_RE.sub("", line))
        if match2:
            content.update(match2.groupdict())
            return content

    return None


def line_to_lexicon_name(line: str) -> str:
    """Get the lexicon name from a line."""
    l_name = line.split(" ")[1]
    return l_name.strip()


def get_lexc_lines(lexc_file: Path) -> Iterable[str]:
    """Get lexc lines from a file."""
    return (
        line
        for line in lexc_file.read_text().split("\n")
        if not line.startswith("!") or line.strip()
    )


def get_lexc_files(lang_directory: Path) -> Iterable[Path]:
    """Get lexc files from a directory."""
    morphology_directory = Path(lang_directory) / "src" / "fst" / "morphology"
    return (
        lexc_file
        for subdir in ["stems", "generated_files"]
        for lexc_file in (morphology_directory / subdir).glob("*.lexc")
    )


def handle_lexc_lines(lines: Iterable[str], lexc_filename) -> Iterable[LexcEntry]:
    """Handle lexc lines from a file."""
    lexicon_name = None
    for line in lines:
        if line.startswith("LEXICON"):
            lexicon_name = line_to_lexicon_name(line.strip())
            continue
        if lexicon_name is not None:
            try:
                content = make_lexc_entry(line, lexc_filename, lexicon_name)
                if content is None:
                    continue
            except TypeError:
                print(f"Could not parse line {line}", file=sys.stderr)
                continue

            lexc_entry = parse_line(content, lexc_filename, lexicon_name)
            if lexc_entry is not None:
                yield lexc_entry


def read_lexc_files(lang_directory: Path) -> dict[str, list[LexcEntry]]:
    """Read lexc entries from a language file.

    Args:
        lang_directory: The directory to read from.

    Returns:
        A dictionary with the stems as keys and list of LexcEntries are values.
    """

    lexc_dict = defaultdict(list)
    for lexc_file in get_lexc_files(lang_directory):
        for lexc_entry in handle_lexc_lines(
            lines=get_lexc_lines(lexc_file), lexc_filename=lexc_file.name
        ):
            lexc_dict[lexc_entry.stem].append(lexc_entry)

    return lexc_dict


def parse_hfst_line(hfst_line: str) -> tuple[str, str]:
    """Parse a line from HFST output.

    Args:
        hfst_line: The line to parse.

    Returns:
        A tuple with the stem and the analysis.
    """
    fields = hfst_line.split("\t")
    if len(fields) != 3:
        raise ValueError("Invalid HFST line: {}".format(hfst_line))

    return fields[0], fields[1]


def parse_hfst_output(
    lines: Iterable[str],
) -> dict[str, list[str]]:
    """Parse HFST output.

    Args:
        lines: The lines to parse.

    Returns:
        A dictionary with the stems as keys and the analyses as values.
    """
    result: dict[str, list[str]] = {}

    for line in lines:
        stem, analysis = parse_hfst_line(line)
        result.setdefault(stem, []).append(analysis)

    return result


def filter_derivations_and_compounds(
    parsed_hfst_output: dict[str, list[str]]
) -> dict[str, list[str]]:
    """Pick stems that are unlexicalised compounds or derivations.

    Args:
        parsed_hfst_output: The parsed hfst output.

    Returns:
        A dictionary with the stems as keys and the analyses as values.
        It contains only stems that are unlexicalised compounds or derivations.
    """
    return {
        stem: analyses
        for stem, analyses in parsed_hfst_output.items()
        if all("+Cmp#" in analysis or "+Der" in analysis for analysis in analyses)
    }


def remove_typos(parsed_hfst_output: dict[str, list[str]]) -> dict[str, list[str]]:
    """Remove entries not contained in the analyser.

    Args:
        parsed_hfst_output: The parsed hfst output.

    Returns:
        A dictionary with the stems as keys and the analyses as values.
        It contains only stems that are not typos.
    """
    return {
        stem: analyses
        for stem, analyses in parsed_hfst_output.items()
        if not all(analysis.endswith("?") for analysis in analyses)
    }


def analyse_expressions(fst: Path, lines: Iterable[str]) -> list[str]:
    """Analyse a list of expressions using a HFST FST.

    Args:
        fst: The path to the HFST FST.
        lines: The expressions to analyse.

    Returns:
        The analyses of the expressions.
    """
    command = ["hfst-lookup", fst.as_posix()]
    result = subprocess.run(
        command,
        capture_output=True,
        check=False,
        input="\n".join(lines).encode("utf-8"),
    )
    return [
        line.strip()
        for line in result.stdout.decode("utf-8").split("\n")
        if line.strip()
    ]


def get_longest_cmp_stem(analyses: list[str]) -> str:
    """Get the longest last compound stem from a list of analyses."""
    return max(
        [analysis.split("#")[-1].split("+")[0] for analysis in analyses],
        key=len,
    )


def lexicalise_compound(
    unlexicalised_compound_stem: str,
    analyses: list[str],
    lexc_dict: dict[str, list[LexcEntry]],
) -> Iterator[LexcEntry]:
    """Lexicalise an unlexicalised compound stem.

    Args:
        unlexicalised_compound_stem: The unlexicalised compound stem.
        analyses: The analyses of the compound stem.
        lexc_dict: The lexc dictionary.

    Returns:
        An iterator of lexicalised lexc entries.
    """
    longest_last_stem = get_longest_cmp_stem(analyses)

    if longest_last_stem not in lexc_dict:
        raise ValueError(f"Longest stem {longest_last_stem} not found in lexc")

    prefix = unlexicalised_compound_stem[
        : unlexicalised_compound_stem.find(longest_last_stem)
    ]
    matching_lexc_entries = lexc_dict.get(longest_last_stem, [])

    return (
        LexcEntry(
            stem=f"{prefix}{longest_last_stem}",
            tags=entry.tags,
            lower=f"{prefix}#{entry.lower}",
            contlex=entry.contlex,
            filename=entry.filename,
            parent_lexicon=entry.parent_lexicon,
        )
        for entry in matching_lexc_entries
    )


def get_matching_lexc_stems(
    hfst_stem: str, lexc_stems: list[str]
) -> tuple[str, list[str]]:
    """Get the matching lexc stems for a HFST stem.

    Args:
        hfst_stem: The HFST stem.
        lexc_stems: The lexc stems, keys from the lexc dictionary.

    Returns:
        A tuple with the common ending and a list of the matching lexc stems.
    """
    for index in range(1, len(hfst_stem) - 3):
        ending = hfst_stem[index:]
        hits = [stem for stem in lexc_stems if stem.endswith(ending)]
        if hits:
            return ending, hits

    return "", []


def make_missing_lexc_entry(
    hfst_stem: str, common_ending: str, lexc_entry: LexcEntry
) -> LexcEntry:
    """Make a lexc entry for stem not found in the analyser.

    Args:
        hfst_stem: The HFST stem.
        common_ending: The common ending of the HFST and lexc stems.
        lexc_entry: The lexc entry.

    Returns:
        A modified version of the incoming lexc entry for the missing stem.
    """
    hfst_prefix = hfst_stem[: hfst_stem.find(common_ending)]
    lower_prefix = lexc_entry.stem[: lexc_entry.stem.find(common_ending)]

    return LexcEntry(
        stem=hfst_stem,
        tags=lexc_entry.tags,
        lower=f"{hfst_prefix}{lexc_entry.lower[len(lower_prefix) :]}",
        contlex=lexc_entry.contlex,
        filename=lexc_entry.filename,
        parent_lexicon=lexc_entry.parent_lexicon,
    )


def get_shortest_matching_lexc_entries(
    lexc_entries: Iterable[LexcEntry],
) -> list[LexcEntry]:
    """Find lexc entries with the shortest stems.

    A stem may multiple contination lexicons and with multiple
    parent lexicons. We would like to present the linguist with the
    shortest stem for each unique combination of contlex and parent lexicon.

    Args:
        lexc_entries: The lexc entries that matches an ending.

    Returns:
        The lexc entries with the shortest stem for each unique combination
        of contlex and parent lexicon.
    """

    map_by_lexicons: dict[str, list[LexcEntry]] = {}
    for entry in lexc_entries:
        map_by_lexicons.setdefault(
            f"{entry.contlex}_{entry.parent_lexicon}", []
        ).append(entry)

    return [
        min(entries, key=lambda entry: len(entry.stem))
        for entries in map_by_lexicons.values()
    ]


def print_typos(descriptive_typos: dict[str, list[str]]) -> None:
    """Print typos with their analyses.

    Args:
        descriptive_typos: These are typos, since they are found in the
            descriptive analyser, but not in the normative analyser.
    """
    if descriptive_typos:
        print("\n\n!!! Typos !!!")
        "\n".join(
            f"! {hfst_stem}\n"
            + "\n".join(f"!\t{analysis}" for analysis in analyses)
            + "\n"
            for hfst_stem, analyses in descriptive_typos.items()
        )


def print_lexicalised_compounds(
    lexc_dict: dict[str, list[LexcEntry]],
    compounds_and_derivations_only: dict[str, list[str]],
    comment_string: str,
) -> None:
    """Lexicalise compounds and derivations

    Present tentive lexc entries to the linguist.

    Args:
        lexc_dict: The lexc dictionary.
        compounds_and_derivations_only: The compounds and derivations that are not
            lexicalised.
    """
    if compounds_and_derivations_only:
        print("\n\n!!! Compounds and derivations only !!!")
        print(
            "\n".join(
                [
                    str(lexc_entry) + comment_string
                    for hfst_stem, analyses in compounds_and_derivations_only.items()
                    for lexc_entry in lexicalise_compound(
                        hfst_stem, analyses, lexc_dict
                    )
                ]
            )
        )


def print_missing_suggestions(
    lexc_dict: dict[str, list[LexcEntry]],
    missing_desc_words: set[str],
    comment_string: str,
) -> None:
    """Print suggestions for missing words in the descriptive analyser.

    Match the missing words with the lexc dictionary and present tentive lexc
    entries to the linguist.

    Args:
        lexc_dict: The lexc dictionary.
        missing_desc_words: Words that are unknown to both the normative
            and descriptive analyser.
    """
    for desc_missing_word in missing_desc_words:
        common_ending, matching_lexc_stems = get_matching_lexc_stems(
            desc_missing_word, list(lexc_dict.keys())
        )
        matching_entries = get_shortest_matching_lexc_entries(
            [
                lexc_entry
                for stem in matching_lexc_stems
                for lexc_entry in lexc_dict[stem]
            ]
        )
        print(
            "\n".join(
                str(
                    make_missing_lexc_entry(
                        desc_missing_word, common_ending, matching_entry
                    )
                )
                + comment_string
                for matching_entry in matching_entries
            )
        )
        print()


def parse_args():
    parser = ArgumentParser(
        description=__doc__, formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-i",
        "--input",
        default=sys.stdin,
        type=Path,
        dest="infile",
        help="source of analysis data",
    )
    parser.add_argument(
        "-l",
        "--language",
        required=True,
        help="The language to analyse. This should be the language code, e.g., 'sme' for Northern Sami.",
    )
    parser.add_argument(
        "-o", "--output", default=sys.stdout, type=Path, help="output file"
    )
    parser.add_argument(
        "-t",
        "--no-typos",
        action="store_false",
        help="Do not print typos",
    )
    parser.add_argument(
        "-n",
        "--normative-fst",
        help="The path to the normative FST",
        default=None,
        type=Path,
    )
    parser.add_argument(
        "-d",
        "--descriptive-fst",
        help="The path to the descriptive FST",
        default=None,
        type=Path,
    )
    parser.add_argument(
        "-c", "--comment", help="A freestyle comment to add to the output", default=""
    )
    parser.add_argument(
        "-r",
        "--lang-root",
        help="The root of the language directory",
        default=None,
        type=Path,
    )

    return parser.parse_args()


def get_language_parent(lang_root: Optional[str]) -> Optional[Path]:
    if lang_root is None:
        lang_parent = os.getenv("GTLANGS")
        if not lang_parent:
            raise SystemExit("GTLANGS environment variable not set")
    else:
        lang_parent = lang_root

    lang_path = Path(lang_parent)
    if not lang_path.exists():
        raise SystemExit(f"Could not find the language directory {lang_path}")

    return lang_path


def get_analysers(
    normative_analyser: Optional[str],
    descriptive_analyser: Optional[str],
    lang_directory: Path,
    language: str,
) -> tuple[Path, Path]:
    if normative_analyser is not None and descriptive_analyser is not None:
        return Path(normative_analyser), Path(descriptive_analyser)

    for prefix in [
        lang_directory / "src/fst/",
        Path("/usr/local/share/giella/") / language,
        Path("/usr/share/giella/") / language,
    ]:
        normative_path = prefix / "analyser-gt-norm.hfstol"
        descriptive_path = prefix / "analyser-gt-desc.hfstol"

        if normative_path.exists() and descriptive_path.exists():
            return normative_path, descriptive_path

    raise SystemExit("Could not find the normative and descriptive analyser.")


def main():
    # Setup
    args = parse_args()

    lang_parent = get_language_parent(args.lang_root)
    lang_directory = lang_parent / f"lang-{args.language}"

    normative_analyser, descriptive_analyser = get_analysers(
        args.normative_fst, args.descriptive_fst, lang_directory, args.language
    )

    # Read lexc files
    lexc_dict = read_lexc_files(lang_directory)

    # Save output from the normative analyser.
    input_stream = sys.stdin if args.infile == sys.stdin else args.infile.open()
    norm_output = analyse_expressions(
        fst=normative_analyser, lines={line for line in input_stream if line.strip()}
    )

    # Save the words unknown to the normative analyser.
    missing_norm_words = {
        line.split("\t")[0] for line in norm_output if line.endswith("inf")
    }

    # The words that are missing in the normative analyser may be typos.
    # Sending those words through the descriptive analyser gives us a list of
    # typos and really unknown words.
    descriptive_output = analyse_expressions(
        fst=descriptive_analyser, lines=missing_norm_words
    )

    input_filename = (
        f" Inputfile: {str(args.infile.absolute()).replace(lang_parent, '$GTLANGS')}"
        if args.infile != sys.stdin
        else ""
    )

    comment = f" Comment: {args.comment}" if args.comment else ""

    # Present the result of the analysis to the linguist.
    # The categories are:
    # 1. Suggestions for unlexicalised words and multiword expressions
    # 2. Suggestions for unlexicalised compounds and derivations
    # 3. Optionally, typos

    # The words unknown to both the normative and the descriptive analyser
    # are given as the second argument.
    print_missing_suggestions(
        lexc_dict=lexc_dict,
        missing_desc_words={
            line.split("\t")[0] for line in descriptive_output if line.endswith("inf")
        },
        comment_string=comment + input_filename,
    )
    print_lexicalised_compounds(
        lexc_dict,
        compounds_and_derivations_only=filter_derivations_and_compounds(
            parse_hfst_output(
                {line for line in norm_output if not line.endswith("inf")}
            )
        ),
        comment_string=comment + input_filename,
    )
    if not args.no_typos:
        print_typos(
            descriptive_typos=remove_typos(parse_hfst_output(descriptive_output))
        )


if __name__ == "__main__":
    main()
