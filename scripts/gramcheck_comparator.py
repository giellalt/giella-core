#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""Write report on differences on manual markup and gramdivvun markup"""
import sys
from argparse import ArgumentParser
from collections import Counter
from io import StringIO
from pathlib import Path

import libdivvun
from lxml import etree

from corpustools import ccat, errormarkup

COLORS = {
    "red": "\033[1;31m",
    "green": "\033[0;32m",
    "orange": "\033[0;33m",
    "yellow": "\033[1;33m",
    "blue": "\033[0;34m",
    "light_blue": "\033[0;36m",
    "reset": "\033[m"
}


def colourise(string, *args, **kwargs):
    kwargs.update(COLORS)
    return string.format(*args, **kwargs)


class GramChecker:
    def check_grammar(self, sentence):
        d_errors = libdivvun.proc_errs_bytes(self.checker, sentence)
        errs = [[
            d_error.form, d_error.beg, d_error.end, d_error.err, d_error.dsc,
            list(d_error.rep), d_error.msg
        ] for d_error in d_errors]

        return {'text': sentence, 'errs': errs}

    @staticmethod
    def get_unique_double_spaces(d_errors):
        double_spaces = []
        indexes = set()
        for d_error in d_errors:
            if d_error[3] == 'double-space-before' and (
                    d_error[1], d_error[2]) not in indexes:
                double_spaces.append(d_error)
                indexes.add((d_error[1], d_error[2]))

        return double_spaces

    @staticmethod
    def remove_dupes(double_spaces, d_errors):
        for removable_error in [
                d_error for double_space in double_spaces
                for d_error in d_errors if double_space[1:2] == d_error[1:2]
        ]:
            d_errors.remove(removable_error)

    @staticmethod
    def make_new_double_space_errors(double_space, d_result):
        d_errors = d_result['errs']
        parts = double_space[0].split('  ')

        for position, part in enumerate(parts[1:], start=1):
            error = f'{parts[position - 1]}  {part}'
            start = d_result['text'].find(error)
            end = start + len(error)
            candidate = [
                error, start, end, 'double-space-before',
                f'Leat guokte gaskka ovdal "{part}"',
                [f'{parts[position - 1]} {part}'], 'Sátnegaskameattáhusat'
            ]
            if candidate not in d_errors:
                d_errors.append(candidate)

    def make_new_errors(self, double_space, d_result):
        d_errors = d_result['errs']
        parts = double_space[0].split('  ')

        error = double_space[0]
        min = 0
        max = len(error)
        position = d_errors.index(double_space)
        for new_position, part in enumerate(
            [part for part in double_space[0].split() if part],
                start=position):
            res = self.check_grammar(part)
            part_errors = res['errs']
            min = error[min:max].find(part)
            for p_error in part_errors:
                p_error[1] = min + double_space[1]
                p_error[2] = min + double_space[1] + len(part)
                d_errors.insert(new_position, p_error)

    def get_unique_double_spaces(self, d_errors):
        double_spaces = []
        indexes = set()
        for d_error in d_errors:
            if d_error[3] == 'double-space-before' and (
                    d_error[1], d_error[2]) not in indexes:
                double_spaces.append(d_error)
                indexes.add((d_error[1], d_error[2]))

        return double_spaces

    @staticmethod
    def sortByRange(error):
        return error[1:2]

    def fix_no_space_after_punct_mark(self, punct_error, d_errors):
        self.remove_dupes([punct_error], d_errors)
        error_message = punct_error[4]
        current_punct = error_message[error_message.find('"') +
                                      1:error_message.rfind('"')]
        parenthesis = punct_error[0].find(current_punct)

        d_errors.append([
            punct_error[0][parenthesis:], punct_error[1] + parenthesis,
            punct_error[1] + parenthesis + len(punct_error[0][parenthesis:]),
            punct_error[3], punct_error[4],
            [f'{current_punct} {punct_error[0][parenthesis + 1:]}'],
            punct_error[6]
        ])

        part1 = punct_error[0][:parenthesis]
        start = punct_error[1]
        end = punct_error[1] + len(part1)
        if part1:
            self.add_part(part1, start, end, d_errors)

        part2 = punct_error[0][parenthesis + 1:]
        start = punct_error[1] + parenthesis + 1
        end = punct_error[1] + parenthesis + 1 + len(part2)
        if part2:
            self.add_part(part2, start, end, d_errors)

        d_errors.sort(key=self.sortByRange)

    def add_part(self, part, start, end, d_errors):
        res = self.check_grammar(part)
        errors = res['errs']
        for error in [error for error in errors if error]:
            candidate = [
                error[0], start, end, error[3], error[4], error[5], error[6]
            ]
            if candidate not in d_errors:
                d_errors.append(candidate)

    def fix_no_space_before_parent_start(self, space_error, d_errors):
        for dupe in [
                d_error for d_error in d_errors
                if d_error[1:2] == space_error[1:2]
        ]:
            d_errors.remove(dupe)

        parenthesis = space_error[0].find('(')
        d_errors.append([
            space_error[0][parenthesis:], space_error[1] + parenthesis,
            space_error[2], space_error[3], space_error[4], [' ('],
            space_error[6]
        ])
        part1 = space_error[0][:parenthesis]
        start = space_error[1]
        end = space_error[1] + len(part1)
        if part1:
            self.add_part(part1, start, end, d_errors)

        part2 = space_error[0][parenthesis + 1:]
        start = space_error[1] + parenthesis + 1
        end = space_error[1] + parenthesis + 1 + len(part2)
        if part2:
            self.add_part(part2, start, end, d_errors)

        d_errors.sort(key=self.sortByRange)

    def fix_aistton(self, d_errors, position):
        d_error = d_errors[position]
        if d_error[3] == 'punct-aistton-left' and len(d_error[0]) > 1:
            sentence = d_error[0][1:]
            d_error[0] = d_error[0][0]
            d_error[5] = ['”']
            d_error[2] = d_error[1] + 1

            res = self.check_grammar(sentence)
            new_d_error = res['errs']
            if new_d_error:
                new_d_error[0][1] = d_error[1] + 1
                new_d_error[0][2] = d_error[1] + 1 + len(sentence)
                d_errors.insert(position + 1, new_d_error[0])

        if d_error[3] == 'punct-aistton-right' and len(d_error[0]) > 1:
            sentence = d_error[0][:-1]
            d_error[0] = d_error[0][-1]
            d_error[5] = ['”']
            d_error[1] = d_error[2] - 1

            res = self.check_grammar(sentence)
            new_d_error = res['errs']
            if new_d_error:
                new_d_error[0][1] = d_error[1] - len(sentence)
                new_d_error[0][2] = d_error[1]
                d_errors.insert(position, new_d_error[0])

        if d_error[3] == 'punct-aistton-both':
            previous_error = d_errors[position - 1]
            remove_previous = previous_error[1] == d_error[
                1] and previous_error[2] == d_error[2] and previous_error[
                    3] == 'typo'

            sentence = d_error[0][1:-1]

            right_error = [part for part in d_error]
            right_error[0] = right_error[0][-1]
            right_error[5] = ['”']
            right_error[1] = right_error[2] - 1
            right_error[3] = 'punct-aistton-right'
            d_errors.insert(position + 1, right_error)

            d_error[0] = d_error[0][0]
            d_error[5] = ['”']
            d_error[2] = d_error[1] + 1
            d_error[3] = 'punct-aistton-left'

            res = self.check_grammar(sentence)
            new_d_error = res['errs']
            if new_d_error:
                new_d_error[0][1] = d_error[1] + 1
                new_d_error[0][2] = d_error[1] + 1 + len(sentence)
                d_errors.insert(position + 1, new_d_error[0])

            if remove_previous:
                del d_errors[position - 1]

    def fix_double_space(self, d_result):
        d_errors = d_result['errs']

        double_spaces = self.get_unique_double_spaces(d_errors)
        self.remove_dupes(double_spaces, d_errors)

        for double_space in double_spaces:
            self.make_new_double_space_errors(double_space, d_result)

        new_double_spaces = self.get_unique_double_spaces(d_errors)

        for new_double_space in new_double_spaces:
            self.make_new_errors(new_double_space, d_result)

        d_errors.sort(key=self.sortByRange)

    def get_error_corrections(self, para):
        parts = []
        if para.text is not None:
            parts.append(para.text)
        for child in para:
            parts.append(child.get('correct'))
            for grandchild in child:
                parts.append(self.get_error_corrections(grandchild))

        if not len(para) and para.tail:
            parts.append(para.tail)

        return ''.join(parts)

    def extract_error_info(self, parts, errors, para):
        info = {}
        if para.tag.startswith('error'):
            for name, value in para.items():
                info[name] = value
            info['type'] = para.tag
            info['start'] = len("".join(parts))
            info['error'] = self.get_error_corrections(para) if len(
                para) else para.text

        if para.text:
            parts.append(para.text)

        for child in para:
            errors.append(self.extract_error_info(parts, errors, child))

        if para.tag.startswith('error'):
            info['end'] = len("".join(parts))

        if para.tail:
            parts.append(para.tail)

        return info

    def fix_all_errors(self, d_result):
        """Remove errors that cover the same area of the typo and msyn types."""
        def report_dupes(errors):
            found_errors = set()
            index_set = set()
            for error1 in errors:
                for error2 in errors:
                    if error1[:3] == error2[:3] and error1 != error2:
                        if str(error1) not in found_errors and str(
                                error2) not in found_errors:
                            found_errors.add(str(error1))
                            found_errors.add(str(error2))
                            index_set.add(errors.index(error1))

            for pos in sorted(index_set, reverse=True):
                del errors[pos]

        d_errors = d_result['errs']

        self.fix_double_space(d_result)

        if any(
            [d_error[3].startswith('punct-aistton') for d_error in d_errors]):
            for d_error in d_errors:
                self.fix_aistton(d_errors, d_errors.index(d_error))

        for d_error in d_errors:
            if d_error[3] == 'no-space-before-parent-start':
                self.fix_no_space_before_parent_start(d_error, d_errors)
            if d_error[3] == 'no-space-after-punct-mark':
                self.fix_no_space_after_punct_mark(d_error, d_errors)

        report_dupes(d_errors)

        return d_result

    def check_sentence(self, sentence):
        res = self.check_grammar(sentence)

        return self.fix_all_errors(res)['errs']

    def get_data(self, para):
        parts = []
        errors = []
        self.extract_error_info(parts, errors, para)

        return {
            'uncorrected': ''.join(parts),
            'expected_errors': errors,
            'gramcheck_errors': self.check_sentence(''.join(parts))
        }


class CorpusGramChecker(GramChecker):
    def __init__(self, archive):
        self.archive = archive
        self.checker = self.app()

    def app(self):
        def print_error(string):
            print(string, file=sys.stderr)

        archive_file = Path(self.archive)
        if archive_file.is_file():
            spec = libdivvun.ArCheckerSpec(str(archive_file))
            pipename = spec.defaultPipe()
            verbose = False
            return spec.getChecker(pipename, verbose)
        else:
            print_error('Error in section Archive of the yaml file.\n' +
                        f'The file {archive_file} does not exist')
            sys.exit(2)


class GramTest:
    class AllOutput():
        def __init__(self, args):
            self._io = StringIO()
            self.args = args

        def __str__(self):
            return self._io.getvalue()

        def write(self, data):
            self._io.write(data)

        def info(self, data):
            self.write(data)

        def title(self, *args):
            pass

        def success(self, *args):
            pass

        def failure(self, *args):
            pass

        def false_positive_1(self, *args):
            pass

        def result(self, *args):
            pass

        def final_result(self, count):
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
            self.write(
                colourise("Total passes: {green}{passes}{reset}, " +
                          "Total fails: {red}{fails}{reset}, " +
                          "Total: {light_blue}{total}{reset}\n",
                          passes=passes,
                          fails=fails,
                          total=fails + passes))

    class NormalOutput(AllOutput):
        def title(self, index, length, test_case):
            self.write(f'{colourise("{light_blue}")}')
            self.write('-' * 10)
            self.write(f'\nTest {index}/{length}: {test_case}\n')
            self.write('-' * 10)
            self.write(f'{colourise("{reset}")}\n')

        def success(self, case, total, type, expected_error, gramcheck_error):
            x = colourise(
                ("[{light_blue}{case:>%d}/{total}{reset}]" +
                 "[{green}PASS {type}{reset}] " +
                 "{error}:{correction} ({expectected_type}) {blue}=>{reset} " +
                 "{gramerr}:{errlist} ({gram_type})\n") % len(str(total)),
                type=type,
                error=expected_error['error'],
                correction=expected_error['correct'],
                expectected_type=expected_error['type'],
                case=case,
                total=total,
                gramerr=gramcheck_error[0],
                errlist=f'[{", ".join(gramcheck_error[5])}]',
                gram_type=gramcheck_error[3])
            self.write(x)

        def failure(self, case, total, type, expected_error, gramcheck_error):
            x = colourise(
                ("[{light_blue}{case:>%d}/{total}{reset}][{red}FAIL {type}"
                 "{reset}] {error}:{correction} ({expectected_type}) " +
                 "{blue}=>{reset} {gramerr}:{errlist} ({gram_type})\n") %
                len(str(total)),
                type=type,
                error=expected_error['error'],
                correction=expected_error['correct'],
                expectected_type=expected_error['type'],
                case=case,
                total=total,
                gramerr=gramcheck_error[0],
                errlist=f'[{", ".join(gramcheck_error[5])}]',
                gram_type=gramcheck_error[3])
            self.write(x)

        def result(self, number, count, test_case):
            passes = sum([count[key] for key in count if key.startswith('t')])
            fails = sum([count[key] for key in count if key.startswith('f')])
            text = colourise(
                "Test {number} - Passes: {green}{passes}{reset}, " +
                "Fails: {red}{fails}{reset}, " +
                "Total: {light_blue}{total}{reset}\n\n",
                number=number,
                passes=passes,
                fails=fails,
                total=passes + fails)
            self.write(text)

        def final_result(self, count):
            passes = sum([count[key] for key in count if key.startswith('t')])
            fails = sum([count[key] for key in count if key.startswith('f')])
            self.write(
                colourise("Total passes: {green}{passes}{reset}, " +
                          "Total fails: {red}{fails}{reset}, " +
                          "Total: {light_blue}{total}{reset}\n",
                          passes=passes,
                          fails=fails,
                          total=fails + passes))
            self.precision(count)

        def precision(self, count):
            try:
                true_positives = count['tp']
                false_positives = count['fp1'] + count['fp2']
                false_negatives = count['fn1'] + count['fn2']
                total = true_positives + false_negatives + false_positives

                prec = true_positives / (true_positives + false_positives)
                recall = true_positives / (true_positives + false_negatives)
                f1score = 2 * prec * recall / (prec + recall)

                self.write(
                    colourise(
                        "True positive: {green}{true_positive}{reset}\n" +
                        "True negative: {green}{true_negative}{reset}\n" +
                        "False positive 1: {red}{fp1}{reset}\n" +
                        "False positive 2: {red}{fp2}{reset}\n" +
                        "False negative 1: {red}{fn1}{reset}\n" +
                        "False negative 2: {red}{fn2}{reset}\n" +
                        "Precision: {prec:.1f}%\n" +
                        "Recall: {recall:.1f}%\n" +
                        "F₁ score: {f1score:.1f}%\n",
                        true_positive=count['tp'],
                        true_negative=count['tn'],
                        fp1=count['fp1'],
                        fp2=count['fp2'],
                        fn1=count['fn1'],
                        fn2=count['fn2'],
                        prec=prec * 100,
                        recall=recall * 100,
                        f1score=f1score * 100))
            except ZeroDivisionError:
                pass

    class CompactOutput(AllOutput):
        def result(self, number, count, test_case):
            passes = sum([count[key] for key in count if key.startswith('t')])
            fails = sum([count[key] for key in count if key.startswith('f')])
            out = f'{test_case} {passes}/{fails}/{passes + fails}'
            if fails:
                self.write(colourise("[{red}FAIL{reset}] {}\n", out))
            else:
                self.write(colourise("[{green}PASS{reset}] {}\n", out))

    class TerseOutput(AllOutput):
        def success(self, *args):
            self.write(colourise("{green}.{reset}"))

        def failure(self, *args):
            self.write(colourise("{red}!{reset}"))

        def result(self, *args):
            self.write('\n')

        def final_result(self, count):
            fails = sum([count[key] for key in count if key != 'tp'])
            if fails:
                self.write(colourise("{red}FAIL{reset}\n"))
            else:
                self.write(colourise("{green}PASS{reset}\n"))

    class FinalOutput(AllOutput):
        def final_result(self, count):
            passes = sum([count[key] for key in count if key.startswith('t')])
            fails = sum([count[key] for key in count if key.startswith('f')])
            self.write(f'{passes}/{fails}/{passes+fails}')

    class NoOutput(AllOutput):
        def final_result(self, *args):
            pass

    def __init__(self):
        self.count = Counter()

    def run_tests(self):
        tests = self.tests
        for item in enumerate(tests.items(), start=1):
            self.run_test(item, len(tests))

        self.config.get('out').final_result(self.count)

    def run_test(self, item, length):
        count = Counter()

        out = self.config.get('out')
        out.title(item[0], length, item[1][0])

        expected_errors = item[1][1]['expected_errors']
        gramcheck_errors = item[1][1]['gramcheck_errors']

        true_positives = self.has_true_positives(expected_errors,
                                                 gramcheck_errors)
        for true_positive in true_positives:
            count['tp'] += 1
            out.success(item[0], length, 'tp', true_positive[0],
                        true_positive[1])

        true_negatives = self.has_true_negatives(expected_errors,
                                                 gramcheck_errors)
        for true_negative in true_negatives:
            count['tn'] += 1
            out.success(item[0], length, 'tn', true_negative[0],
                        true_negative[1])

        false_positives_1 = self.has_false_positives_1(expected_errors,
                                                       gramcheck_errors)
        for false_positive_1 in false_positives_1:
            count['fp1'] += 1
            out.failure(item[0], length, 'fp1', false_positive_1[0],
                        false_positive_1[1])

        false_positives_2 = self.has_false_positives_2(expected_errors,
                                                       gramcheck_errors)
        expected_error = {'correct': '', 'error': '', 'type': ''}
        for false_positive_2 in false_positives_2:
            count['fp2'] += 1
            out.failure(item[0], length, 'fp2', expected_error,
                        false_positive_2)

        false_negatives_1 = self.has_false_negatives_1(expected_errors,
                                                       gramcheck_errors)
        for false_negative_1 in false_negatives_1:
            count['fn1'] += 1
            out.failure(item[0], length, 'fn1', false_negative_1[0],
                        false_negative_1[1])

        false_negatives_2 = self.has_false_negatives_2(expected_errors,
                                                       gramcheck_errors)
        for false_negative_2 in false_negatives_2:
            gramcheck_error = ['', '', '', '', '', []]
            count['fn2'] += 1
            out.failure(item[0], length, 'fn2', false_negative_2,
                        gramcheck_error)

        out.result(item[0], count, item[1][0])

        for key in count:
            self.count[key] += count[key]

    def has_same_range_and_error(self, c_error, d_error):
        if d_error[3] == 'double-space-before':
            return c_error['start'] == d_error[1] and c_error[
                'end'] == d_error[2]
        else:
            return c_error['start'] == d_error[1] and c_error[
                'end'] == d_error[2] and c_error['error'] == d_error[0]

    def has_suggestions_with_hit(self, c_error, d_error):
        return self.has_same_range_and_error(
            c_error,
            d_error) and d_error[5] and c_error['correct'] in d_error[5]

    def has_true_negatives(self, correct, dc):
        if not correct and not dc:
            return [({
                'error': '',
                'correct': '',
                'type': ''
            }, ['', '', '', '', '', ''])]

        return []

    def has_true_positives(self, correct, dc):
        return [(c_error, d_error) for c_error in correct for d_error in dc
                if self.has_suggestions_with_hit(c_error, d_error)]

    def has_false_positives_1(self, correct, dc):
        return [(c_error, d_error) for c_error in correct for d_error in dc
                if self.has_suggestions_without_hit(c_error, d_error)]

    def has_suggestions_without_hit(self, c_error, d_error):
        return self.has_same_range_and_error(
            c_error,
            d_error) and d_error[5] and c_error['correct'] not in d_error[5]

    def has_false_positives_2(self, correct, dc):
        corrects = []
        for d_error in dc:
            for c_error in correct:
                if self.has_same_range_and_error(c_error, d_error):
                    break
            else:
                corrects.append(d_error)

        return corrects

    def has_false_negatives_2(self, c_errors, d_errors):
        corrects = []
        for c_error in c_errors:
            for d_error in d_errors:
                if self.has_same_range_and_error(c_error, d_error):
                    break
            else:
                corrects.append(c_error)

        return corrects

    def has_false_negatives_1(self, correct, dc):
        return [(c_error, d_error) for c_error in correct for d_error in dc
                if self.has_no_suggestions(c_error, d_error)]

    def has_no_suggestions(self, c_error, d_error):
        return self.has_same_range_and_error(c_error,
                                             d_error) and not d_error[5]

    def run(self):
        self.run_tests()
        fails = sum([self.count[key] for key in self.count if key != 'tp'])

        return 1 if fails else 0

    def __str__(self):
        return str(self.config.get('out'))

    @property
    def tests(self):
        return {test['uncorrected']: test for test in self.paragraphs}


class CorpusGramTest(GramTest):
    def __init__(self, args):
        super().__init__()
        self.archive = args.archive
        self.targets = args.targets
        self.config = {'out': GramTest.NormalOutput(args)}
        if not args.colour:
            for key in list(COLORS.keys()):
                COLORS[key] = ""

    @property
    def paragraphs(self):
        grammarchecker = CorpusGramChecker(self.archive)

        for filename in ccat.find_files(self.targets, '.xml'):
            root = etree.parse(filename)
            for para in root.iter('p'):
                yield grammarchecker.get_data(para)


class UI(ArgumentParser):
    def __init__(self):
        super().__init__()
        self.add_argument("-c",
                          "--colour",
                          dest="colour",
                          action="store_true",
                          help="Colours the output")
        self.test = None

    def start(self):
        ret = self.test.run()
        sys.stdout.write(str(self.test))
        sys.exit(ret)


class CorpusUI(UI):
    def __init__(self):
        super().__init__()
        self.add_argument('archive', help='The grammarchecker archive')
        self.add_argument('targets',
                          nargs='+',
                          help='''Name of the file or directories to process.
                        If a directory is given, all files in this directory
                        and its subdirectories will be listed.''')

        self.test = CorpusGramTest(self.parse_args())


def main():
    try:
        ui = CorpusUI()
        ui.start()
    except KeyboardInterrupt:
        sys.exit(130)


if __name__ == "__main__":
    try:
        main()
    except (FileNotFoundError, errormarkup.ErrorMarkupError) as error:
        raise SystemExit(error)
