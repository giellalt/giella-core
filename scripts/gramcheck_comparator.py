#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""Write report on differences on manual markup and gramdivvun markup"""
import json
import sys
from argparse import ArgumentParser
from collections import Counter, defaultdict
from io import StringIO

import libdivvun
from lxml import etree

from corpustools import ccat, errormarkup, util

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


class GramChecker(object):
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

    def get_data(self, sentence):
        def make_errormarkup(sentence):
            para = etree.Element('p')
            para.text = sentence
            errormarkup.add_error_markup(para)

            return para

        parts = []
        errors = []
        self.extract_error_info(parts, errors, make_errormarkup(sentence))

        return {
            'uncorrected': ''.join(parts),
            'expected_errors': errors,
            'gramcheck_errors': self.check_sentence(''.join(parts))
        }


class GramTest(object):
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
        def max80(self, header, test_case):
            all = f'{header} {test_case}'
            if len(all) < 80:
                return all, len(all)

            parts = []
            x = all[:80].rfind(' ')
            parts.append(all[:x])
            longest = len(parts[-1])
            all = f'{" " * len(header)}{all[x:]}'
            while len(all) > 80:
                x = all[:80].rfind(' ')
                parts.append(all[:x])
                if longest < len(parts[-1]):
                    longest = len(parts[-1])
                all = f'{" " * len(header)}{all[x:]}'

            parts.append(all)
            if longest < len(parts[-1]):
                longest = len(parts[-1])

            return '\n'.join(parts), longest

        def title(self, index, length, test_case):
            text, longest = self.max80(f'Test {index}/{length}:', test_case)

            self.write(colourise("{light_blue}-" * longest + '\n'))
            self.write(f'{text}' + '\n')
            self.write(colourise("-" * longest + '{reset}\n'))

        def success(self, case, total, expected_error, gramcheck_error):
            x = colourise(
                ("[{light_blue}{case:>%d}/{total}{reset}]" +
                 "[{green}PASS tp{reset}] " +
                 "{error}:{correction} ({expectected_type}) {blue}=>{reset} " +
                 "{gramerr}:{errlist} ({gram_type})\n") % len(str(total)),
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
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
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
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
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
                        "True positive: {green}{true_positive:.2f}{reset}\n" +
                        "False positive 1: {red}{fp1:.2f}{reset}\n" +
                        "False positive 2: {red}{fp2:.2f}{reset}\n" +
                        "False negative 1: {red}{fn1:.2f}{reset}\n" +
                        "False negative 2: {red}{fn1:.2f}{reset}\n" +
                        "Precision: {prec:.2f}\n" + "Recall: {recall:.2f}\n" +
                        "F₁ score: {f1score:.2f}\n",
                        true_positive=count['tp'] / total,
                        fp1=count['fp1'] / total,
                        fp2=count['fp2'] / total,
                        fn1=count['fn1'] / total,
                        fn2=count['fn2'] / total,
                        prec=prec,
                        recall=recall,
                        f1score=f1score))
            except ZeroDivisionError:
                pass

    class CompactOutput(AllOutput):
        def result(self, number, count, test_case):
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
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
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
            if fails:
                self.write(colourise("{red}FAIL{reset}\n"))
            else:
                self.write(colourise("{green}PASS{reset}\n"))

    class FinalOutput(AllOutput):
        def final_result(self, count):
            passes = count['tp']
            fails = sum([count[key] for key in count if key != 'tp'])
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

        corrects = self.correct_in_dc(expected_errors, gramcheck_errors)
        if corrects:
            for correct in corrects:
                count['tp'] += 1
                out.success(item[0], length, correct[0], correct[1])

        false_positives_1 = self.correct_not_in_dc(expected_errors,
                                                   gramcheck_errors)
        if false_positives_1:
            for false_positive_1 in false_positives_1:
                count['fp1'] += 1
                out.failure(item[0], length, 'fp1', false_positive_1[0],
                            false_positive_1[1])

        false_positives_2 = self.dcs_not_in_correct(expected_errors,
                                                    gramcheck_errors)
        if false_positives_2:
            expected_error = {'correct': '', 'error': '', 'type': ''}
            for false_positive_2 in false_positives_2:
                count['fp2'] += 1
                out.failure(item[0], length, 'fp2', expected_error,
                            false_positive_2)

        false_negatives_1 = self.correct_no_suggestion_in_dc(
            expected_errors, gramcheck_errors)
        for false_negative_1 in false_negatives_1:
            count['fn1'] += 1
            out.failure(item[0], length, 'fn1', false_negative_1[0],
                        false_negative_1[1])

        false_negatives_2 = self.corrects_not_in_dc(expected_errors,
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

    def correct_in_dc(self, correct, dc):
        if not correct and not dc:
            return [({
                'error': '',
                'correct': '',
                'type': ''
            }, ['', '', '', '', '', ''])]

        return [(c_error, d_error) for c_error in correct for d_error in dc
                if self.has_suggestions_with_hit(c_error, d_error)]

    def correct_not_in_dc(self, correct, dc):
        return [(c_error, d_error) for c_error in correct for d_error in dc
                if self.has_suggestions_without_hit(c_error, d_error)]

    def has_suggestions_without_hit(self, c_error, d_error):
        return self.has_same_range_and_error(
            c_error,
            d_error) and d_error[5] and c_error['correct'] not in d_error[5]

    def dcs_not_in_correct(self, correct, dc):
        corrects = []
        for d_error in dc:
            for c_error in correct:
                if self.has_same_range_and_error(c_error, d_error):
                    break
            else:
                corrects.append(d_error)

        return corrects

    def corrects_not_in_dc(self, c_errors, d_errors):
        corrects = []
        for c_error in c_errors:
            for d_error in d_errors:
                if self.has_same_range_and_error(c_error, d_error):
                    break
            else:
                corrects.append(c_error)

        return corrects

    def correct_no_suggestion_in_dc(self, correct, dc):
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


class UI(ArgumentParser):
    def __init__(self):
        super().__init__(self)
        self.add_argument("-c",
                          "--colour",
                          dest="colour",
                          action="store_true",
                          help="Colours the output")

    def start(self):
        ret = self.test.run()
        sys.stdout.write(str(self.test))
        sys.exit(ret)


#
# Get gramchecker data
#


def make_gramcheck_runs(text, error, filename, zcheck_file, runner):
    try:
        return text, error, filename, gramcheck(text, zcheck_file, runner)
    except json.decoder.JSONDecodeError:
        print(f'gramcheck error: {text, filename}')


def gramcheck(sentence: str, zcheck_file: str,
              runner: util.ExternalCommandRunner) -> dict:
    """Run the gramchecker on the error_sentence."""
    runner.run(f'divvun-checker -a {zcheck_file} '.split(),
               to_stdin=sentence.encode('utf-8'))

    return runner.stdout


def get_all(targets):
    for filename in ccat.find_files(targets, '.xml'):
        root = etree.parse(filename)
        for para in root.iter('p'):
            parts = []
            errors = []
            print_orig(parts, errors, para)
            text = ''.join(parts)
            if not text.startswith('#') and text.strip():
                yield text.replace('\n',
                                   ' '), [error for error in errors
                                          if error], filename


def get_error_corrections(para):
    parts = []
    if para.text is not None:
        parts.append(para.text)
    for child in para:
        parts.append(child.get('correct'))
        for grandchild in child:
            parts.append(get_error_corrections(grandchild))

    if not len(para) and para.tail:
        parts.append(para.tail)

    return ''.join(parts)


def print_orig(parts, errors, para):
    info = {}
    if para.tag.startswith('error'):
        for name, value in para.items():
            info[name] = value
        info['type'] = para.tag
        info['start'] = len("".join(parts))
        info['error'] = get_error_corrections(para) if len(para) else para.text

    if para.text:
        parts.append(para.text)

    for child in para:
        errors.append(print_orig(parts, errors, child))

    if para.tag.startswith('error'):
        info['end'] = len("".join(parts))

    if para.tail:
        parts.append(para.tail)

    return info


def produce_grammarchecker_results(targets, zcheck_file):
    print('Getting all paragraphs that should be checked …')
    paragraphs = {
        paragraph: {
            'error': errors,
            'filename': filename
        }
        for paragraph, errors, filename in get_all(targets) if paragraph
    }
    runner = util.ExternalCommandRunner()
    print('Running grammar checker …')
    gramcheck_output = gramcheck('\n'.join(paragraphs), zcheck_file, runner)
    print('Post processing grammar checker output …')
    for line in gramcheck_output.decode('utf-8').strip().split('\n'):
        gram_error = json.loads(line.encode('utf-8'))
        if gram_error['text'] in paragraphs:
            paragraphs[gram_error['text']]['gram_error'] = filter_dc(
                gram_error, zcheck_file, runner)
        else:
            print(f'{gram_error["text"]} from {line} not in paragraphs')

    results = [(text, paragraphs[text]['error'], paragraphs[text]['filename'],
                paragraphs[text]['gram_error']) for text in paragraphs
               if paragraphs[text].get('gram_error')]

    print(f'{len(results)} of {len(paragraphs)} survived')
    return results


#
# Post process gramchecker results
#


def filter_dc(d_result, zcheck_file, runner):
    """Remove errors that cover the same area of the typo and msyn types."""
    d_errors = d_result['errs']

    fix_double_space(d_result, zcheck_file, runner)

    if any([d_error[3].startswith('punct-aistton') for d_error in d_errors]):
        for d_error in d_errors:
            fix_aistton(d_errors, d_errors.index(d_error), zcheck_file, runner)

    for d_error in d_errors:
        if d_error[3] == 'no-space-before-parent-start':
            fix_no_space_before_parent_start(d_error, d_errors, zcheck_file,
                                             runner)
        if d_error[3] == 'no-space-after-punct-mark':
            fix_no_space_after_punct_mark(d_error, d_errors, zcheck_file,
                                          runner)

    return d_result


def fix_double_space(d_result, zcheck_file, runner):
    d_errors = d_result['errs']

    double_spaces = get_unique_double_spaces(d_errors)
    remove_dupes(double_spaces, d_errors)

    for double_space in double_spaces:
        make_new_double_space_errors(double_space, d_result)

    new_double_spaces = get_unique_double_spaces(d_errors)

    for new_double_space in new_double_spaces:
        make_new_errors(new_double_space, d_result, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def fix_aistton(d_errors, position, zcheck_file, runner):
    d_error = d_errors[position]
    if d_error[3] == 'punct-aistton-left' and len(d_error[0]) > 1:
        sentence = d_error[0][1:]
        d_error[0] = d_error[0][0]
        d_error[5] = ['”']
        d_error[2] = d_error[1] + 1

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] + 1
            new_d_error[0][2] = d_error[1] + 1 + len(sentence)
            d_errors.insert(position + 1, new_d_error[0])

    if d_error[3] == 'punct-aistton-right' and len(d_error[0]) > 1:
        sentence = d_error[0][:-1]
        d_error[0] = d_error[0][-1]
        d_error[5] = ['”']
        d_error[1] = d_error[2] - 1

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] - len(sentence)
            new_d_error[0][2] = d_error[1]
            d_errors.insert(position, new_d_error[0])

    if d_error[3] == 'punct-aistton-both':
        previous_error = d_errors[position - 1]
        remove_previous = previous_error[1] == d_error[1] and previous_error[
            2] == d_error[2] and previous_error[3] == 'typo'

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

        new_d_error = new_errors(sentence, zcheck_file, runner)
        if new_d_error:
            new_d_error[0][1] = d_error[1] + 1
            new_d_error[0][2] = d_error[1] + 1 + len(sentence)
            d_errors.insert(position + 1, new_d_error[0])

        if remove_previous:
            del d_errors[position - 1]


def fix_no_space_before_parent_start(space_error, d_errors, zcheck_file,
                                     runner):
    for dupe in [
            d_error for d_error in d_errors if d_error[1:2] == space_error[1:2]
    ]:
        d_errors.remove(dupe)

    parenthesis = space_error[0].find('(')
    d_errors.append([
        space_error[0][parenthesis:], space_error[1] + parenthesis,
        space_error[2], space_error[3], space_error[4], [' ('], space_error[6]
    ])
    part1 = space_error[0][:parenthesis]
    start = space_error[1]
    end = space_error[1] + len(part1)
    if part1:
        add_part(part1, start, end, d_errors, zcheck_file, runner)

    part2 = space_error[0][parenthesis + 1:]
    start = space_error[1] + parenthesis + 1
    end = space_error[1] + parenthesis + 1 + len(part2)
    if part2:
        add_part(part2, start, end, d_errors, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def fix_no_space_after_punct_mark(punct_error, d_errors, zcheck_file, runner):
    remove_dupes([punct_error], d_errors)
    error_message = punct_error[4]
    current_punct = error_message[error_message.find('"') +
                                  1:error_message.rfind('"')]
    parenthesis = punct_error[0].find(current_punct)

    d_errors.append([
        punct_error[0][parenthesis:], punct_error[1] + parenthesis,
        punct_error[1] + parenthesis + len(punct_error[0][parenthesis:]),
        punct_error[3], punct_error[4],
        [f'{current_punct} {punct_error[0][parenthesis + 1:]}'], punct_error[6]
    ])

    part1 = punct_error[0][:parenthesis]
    start = punct_error[1]
    end = punct_error[1] + len(part1)
    if part1:
        add_part(part1, start, end, d_errors, zcheck_file, runner)

    part2 = punct_error[0][parenthesis + 1:]
    start = punct_error[1] + parenthesis + 1
    end = punct_error[1] + parenthesis + 1 + len(part2)
    if part2:
        add_part(part2, start, end, d_errors, zcheck_file, runner)

    d_errors.sort(key=sortByRange)


def get_unique_double_spaces(d_errors):
    double_spaces = []
    indexes = set()
    for d_error in d_errors:
        if d_error[3] == 'double-space-before' and (d_error[1],
                                                    d_error[2]) not in indexes:
            double_spaces.append(d_error)
            indexes.add((d_error[1], d_error[2]))

    return double_spaces


def remove_dupes(double_spaces, d_errors):
    for removable_error in [
            d_error for double_space in double_spaces for d_error in d_errors
            if double_space[1:2] == d_error[1:2]
    ]:
        d_errors.remove(removable_error)


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


def make_new_errors(double_space, d_result, zcheck_file, runner):
    d_errors = d_result['errs']
    parts = double_space[0].split('  ')

    error = double_space[0]
    min = 0
    max = len(error)
    position = d_errors.index(double_space)
    for new_position, part in enumerate(
        [part for part in double_space[0].split() if part], start=position):
        part_errors = new_errors(part, zcheck_file, runner)
        min = error[min:max].find(part)
        for p_error in part_errors:
            p_error[1] = min + double_space[1]
            p_error[2] = min + double_space[1] + len(part)
            d_errors.insert(new_position, p_error)


def sortByRange(error):
    return error[1:2]


def new_errors(sentence, zcheck_file, runner):
    runner.run(f'divvun-checker -a {zcheck_file} '.split(),
               to_stdin=sentence.encode('utf-8'))

    return json.loads(runner.stdout)['errs']


def add_part(part, start, end, d_errors, zcheck_file, runner):
    errors = new_errors(part, zcheck_file, runner)
    for error in [error for error in errors if error]:
        candidate = [
            error[0], start, end, error[3], error[4], error[5], error[6]
        ]
        if candidate not in d_errors:
            d_errors.append(candidate)


#
# Reporting code
#
REPORTS = {
    'tp': 'GramDivvun found marked up error and has the suggested correction '
    '(tp)',
    'fp1': 'GramDivvun found manually marked up error, but corrected wrongly '
    '(fp1)',
    'fp2': 'GramDivvun found error which is not manually marked up (fp2)',
    'fn1': 'GramDivvun found manually marked up error, but has no correction '
    '(fn1)',
    'fn2': 'GramDivvun did not find manually marked up error (fn2)'
}


def correct_no_suggestion_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_no_suggestions(c_error, d_error)]


def correct_not_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_without_hit(c_error, d_error)]


def false_positives_1_per_sentence(nices, outfile):
    def report_output(nice):
        return (f'{initial_nice(nice)}' f' -> [{", ".join(nice[1][5])}]')

    report_outputs = [report_output(nice) for nice in nices]
    if report_outputs:
        print(f'~~~~~~\n\t{REPORTS["fp1"]}', file=outfile)
        print('\n'.join(report_outputs), file=outfile)


def initial_nice(nice):
    return (f'\t\t{nice[0]["type"]} -> {nice[1][3]}\n'
            f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]}')


def false_negatives_1_per_sentence(nices, outfile):
    report_outputs = [initial_nice(nice) for nice in nices]

    if report_outputs:
        print(f'~~~~~~\n\t{REPORTS["fn1"]}', file=outfile)
        print('\n'.join(report_outputs), file=outfile)


def correct_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_with_hit(c_error, d_error)]


def true_positive_per_sentence(nices, outfile):
    def report_output(nice):
        return (f'{initial_nice(nice)}'
                f', position {nice[1][5].index(nice[0]["correct"])}')

    report_outputs = [report_output(nice) for nice in nices]
    if report_outputs:
        print(f'~~~~~~\n\t{REPORTS["tp"]}', file=outfile)
        print('\n'.join(report_outputs), file=outfile)


def corrects_not_in_dc(c_errors, d_errors):
    corrects = []
    for c_error in c_errors:
        for d_error in d_errors:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(c_error)

    return corrects


def false_negatives_2_per_sentence(corrects, outfile):
    if corrects:
        print(f'~~~~~~\n\t{REPORTS["fn2"]}', file=outfile)
        print('\n'.join([f'\t\t{c_error}' for c_error in corrects]),
              file=outfile)


def dcs_not_in_correct(correct, dc):
    corrects = []
    for d_error in dc:
        for c_error in correct:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(d_error)

    return corrects


def false_positives_2_per_sentence(corrects, outfile):
    if corrects:
        print(f'~~~~~~\n\t{REPORTS["fp2"]}', file=outfile)
        print('\n'.join([f'\t\t{c_error}' for c_error in corrects]),
              file=outfile)


def has_same_range_and_error(c_error, d_error):
    if d_error[3] == 'double-space-before':
        return c_error['start'] == d_error[1] and c_error['end'] == d_error[2]
    else:
        return c_error['start'] == d_error[1] and c_error['end'] == d_error[
            2] and c_error['error'] == d_error[0]


def has_suggestions_with_hit(c_error, d_error):
    return has_same_range_and_error(
        c_error, d_error) and d_error[5] and c_error['correct'] in d_error[5]


def has_suggestions_without_hit(c_error, d_error):
    return has_same_range_and_error(
        c_error,
        d_error) and d_error[5] and c_error['correct'] not in d_error[5]


def has_no_suggestions(c_error, d_error):
    return has_same_range_and_error(c_error, d_error) and not d_error[5]


def is_wanted_error(c_error, filters):
    if not filters:
        return True

    return c_error['type'] not in filters


def filter_markup(filters, c_errors):
    return [
        c_error for c_error in c_errors if is_wanted_error(c_error, filters)
    ]


def report_markup_dupes(c_errors, errortags, counter, outfile):
    indexes = defaultdict(int)
    for c_error in c_errors:
        errortags.add(c_error['type'])
        indexes[(c_error['start'], c_error['end'])] += 1

    for index in indexes:
        if indexes[index] > 1:
            print(f'Markup duplicates of {indexes}', file=outfile)
            for c_error in c_errors:
                if c_error['start'] == index[0] and c_error['end'] == index[1]:
                    counter['markup_dupes'] += 1
                    print(f'\t{c_error}', file=outfile)


def find_dc_dupes(d_errors):
    indexes = defaultdict(int)
    for d_error in d_errors:
        indexes[(d_error[1], d_error[2])] += 1

    return indexes


def report_dc_dupes(d_errors, counter, outfile, dupesets):
    these_dupes = set()
    indexes = find_dc_dupes(d_errors)

    for index in indexes:
        if indexes[index] > 1:
            print(f'dc duplicates of {index}', file=outfile)
            for d_error in d_errors:
                if d_error[1] == index[0] and d_error[2] == index[1]:
                    counter['dc_dupes'] += 1
                    counter[f'dc_dupes_{d_error[3]}'] += 1
                    these_dupes.add(d_error[3])
                    print(f'\t{d_error}', file=outfile)

    counter[str(these_dupes)] += 1
    if len(these_dupes) and these_dupes not in dupesets:
        dupesets.append(these_dupes)


def report_false_negative_2(c_errors, d_errors, counter, outfile):
    # oppmerkede feil som ikke blir rapportert
    false_negatives_2 = corrects_not_in_dc(c_errors, d_errors)
    false_negatives_2_per_sentence(false_negatives_2, outfile)
    counter['total_false_negative_2'] += len(false_negatives_2)
    for false_negative_2 in false_negatives_2:
        counter[f'{false_negative_2["type"]}_false_negative_2'] += 1


def grammar_to_manual(grammartype):
    if grammartype == 'typo':
        return 'errorort'
    elif grammartype in [
            'double-space-before', 'punct-aistton-left', 'punct-aistton-right',
            'no-space-after-punct-mark', 'space-before-punct-mark',
            'no-space-before-parent-start', 'no-space-after-parent-end',
            'space-after-paren-beg', 'space-before-paren-end'
    ]:
        return 'errorformat'
    elif grammartype.startswith('msyn-'):
        return 'errorsyn'
    elif grammartype.startswith('real-'):
        return 'errorortreal'
    else:
        return 'bingo'


def report_false_positive_2(c_errors, d_errors, counter, outfile):
    """Grammatikkontrollen har funnet feil som ikke er oppmerket"""
    false_positives_2 = dcs_not_in_correct(c_errors, d_errors)
    false_positives_2_per_sentence(false_positives_2, outfile)
    counter['total_false_positive_2'] += len(false_positives_2)
    for false_positive_2 in false_positives_2:
        counter[
            f'{grammar_to_manual(false_positive_2[3])}_false_positive_2'] += 1


def report_true_positive(c_errors, d_errors, counter, outfile):
    """Oppmerket feil blir oppdaget av grammatikkontrollen
    * Grammatikkontrollen har forslag
    * Manuell retting er blant disse
    """
    true_positives = correct_in_dc(c_errors, d_errors)
    true_positive_per_sentence(true_positives, outfile)
    counter['total_true_positive'] += len(true_positives)
    for true_positive in true_positives:
        counter[f'{grammar_to_manual(true_positive[1][3])}_true_positive'] += 1


def report_false_positive_1(c_errors, d_errors, counter, outfile):
    """Oppmerket feil blir oppdaget av grammatikkontrollen
    * Grammatikkontrollen har forslag
    * Manuell retting er *ikke* blant disse
    """
    false_positives_1 = correct_not_in_dc(c_errors, d_errors)
    false_positives_1_per_sentence(false_positives_1, outfile)
    counter['total_false_positive_1'] += len(false_positives_1)
    for false_positive_1 in false_positives_1:
        counter[
            f'{grammar_to_manual(false_positive_1[1][3])}_false_positive_1'] += 1


def report_false_negative_1(c_errors, d_errors, counter, outfile):
    """Oppmerket feil blir oppdaget av grammatikkontrollen
    * Grammatikkontrollen har ingen forslag
    """
    false_negatives_1 = correct_no_suggestion_in_dc(c_errors, d_errors)
    false_negatives_1_per_sentence(false_negatives_1, outfile)
    counter['total_false_negative_1'] += len(false_negatives_1)
    for false_negative_1 in false_negatives_1:
        counter[
            f'{grammar_to_manual(false_negative_1[1][3])}_false_negative1'] += 1


def remove_unknown_propers(c_errors, d_errors):
    """Pretend that we have a proper noun detector.

    All grammarchecker errors that do have no manually marked counterpart
    and where the error string starts with an uppercase letter are simply
    removed from the errors that the divvun-checker report.

    This lifts the overall precision.
    """
    with_propers = dcs_not_in_correct(c_errors, d_errors)
    propers = [
        d_error for d_error in with_propers
        if d_error[0][0].upper() == d_error[0][0] and d_error[3] == 'typo'
    ]
    for proper in propers:
        d_errors.remove(proper)


def per_sentence(sentence, filename, c_errors, d_errors, counter, errortags,
                 outfile, dupesets):
    remove_unknown_propers(c_errors, d_errors)

    counter['paragraphs_with_errors'] += 1
    counter['total_manually_marked_errors'] += len(c_errors)
    counter['total_grammarchecker_errors'] += len(d_errors)
    print('==========', file=outfile)
    print(sentence, '<-', filename, file=outfile)

    report_markup_dupes(c_errors, errortags, counter, outfile)
    report_dc_dupes(d_errors, counter, outfile, dupesets)
    report_false_negative_2(c_errors, d_errors, counter, outfile)
    report_false_positive_2(c_errors, d_errors, counter, outfile)
    report_true_positive(c_errors, d_errors, counter, outfile)
    report_false_positive_1(c_errors, d_errors, counter, outfile)
    report_false_negative_1(c_errors, d_errors, counter, outfile)
    print(file=outfile)


def templates(counter, category):
    for template in [
        ('* True positives: {} (GramDivvun found manually marked up error '
         'and has the suggested correction)', f'{category}_true_positive'),
        ('* False positives, type 1: {} (GramDivvun found manually marked '
         'up error, but gave only wrong suggestions)',
         f'{category}_false_positive_1'),
        ('* False positives, type 2: {} (GramDivvun found error which is not '
         'manually marked up)', f'{category}_false_positive_2'),
        ('* False negatives, type 1: {} (GramDivvun found manually marked up '
         'error, but has no correction)', f'{category}_false_negative_1'),
        ('* False negatives, type 2: {} (GramDivvun did not find manually '
         'marked up error)', f'{category}_false_negative_2')
    ]:
        yield template[0].format(counter[template[1]])


def overview_markup(counter, used_categories, outfile):
    print(f'Paragraphs with errors {counter["paragraphs_with_errors"]}',
          file=outfile)
    print(f'Manually marked errors: {counter["total_manually_marked_errors"]}',
          file=outfile)
    print(
        'Errors reported by grammarchecker: '
        f'{counter["total_grammarchecker_errors"]}',
        file=outfile)

    print('Statistics by type', file=outfile)
    precision('total', counter, outfile=outfile)
    for label in sorted({
            label.split('_')[0]
            for label in counter if label.startswith('error') and '_' in label
    }):
        precision(label, counter, outfile=outfile)


def precision(category, counter, outfile):
    """
        precision: TP / (TP + FP)
        recall: TP / (TP + FN)
        F₁ score: 2 * precision * recall / (precision + recall)
    """
    try:
        print(f'\n{category} statistics', file=outfile)
        for template in templates(counter, category):
            print(template, file=outfile)

        true_positives = counter[f'{category}_true_positive']
        false_positives = counter[f'{category}_false_positive_1'] + counter[
            f'{category}_false_positive_2']
        false_negatives = counter[f'{category}_false_negative_1'] + counter[
            f'{category}_false_negative_2']

        prec = true_positives / (true_positives + false_positives)
        recall = true_positives / (true_positives + false_negatives)
        f1score = 2 * prec * recall / (prec + recall)

        print(
            f'{category} precision: {100 * prec:.1f}% '
            f'(100 * {true_positives}/{true_positives + false_positives})',
            file=outfile)
        print(
            f'{category} recall: {100 * recall:.1f}% '
            f'(100 * {true_positives}/{(true_positives + false_negatives)})',
            file=outfile)
        print(
            f'{category} F₁ score: {100 * f1score:.1f}% '
            f'(100* {2 * prec * recall:.2f}/{prec + recall:.2f})\n',
            file=outfile)
    except ZeroDivisionError:
        pass


def overview_precision_recall(counter, outfile):
    true_positives = counter['total_true_positive']
    false_positives = counter['total_false_positive_1'] + counter[
        'total_false_positive_2']
    # TP + FP = all errors found by grammarchecker
    false_negatives = counter['total_true_negative_1'] + counter[
        'total_true_negative_2']
    precision('Overall', true_positives, false_positives, false_negatives,
              outfile)


def overview(results, counter, outfile):
    used_categories = set()
    overview_markup(counter, used_categories, outfile)

    return used_categories


def per_sentence_report(args, outfile, results):
    counter = defaultdict(int)
    errortags = set()
    dupesets = []

    for result in results:
        if result[1] or result[3]['errs']:
            per_sentence(result[0], result[2], result[1], result[3]['errs'],
                         counter, errortags, outfile, dupesets)

    return counter, errortags, dupesets


def category_usage(used_categories, counter, outfile, errortags):
    all_categories = {label for label in counter}
    not_used = all_categories - used_categories
    if not_used:
        print('\n\nnot used\n\n', file=outfile)
        for label in not_used:
            print(f'{label}: {counter[label]}', file=outfile)

    print('Errortags', file=outfile)
    for errortag in errortags:
        print(errortag, file=outfile)


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(
        description='Report on manual markup versus grammarchecker.')

    parser.add_argument('--filtererror',
                        help='Remove named errortags',
                        nargs='+',
                        choices=[
                            'error', 'errorortreal', 'errormorphsyn',
                            'errorsyn', 'errorlex', 'errorformat', 'errorlang'
                        ])
    parser.add_argument('zcheck_file', help='The grammarchecker archive')
    parser.add_argument('targets',
                        nargs='+',
                        help='Name of the file or directories to process. \
                        If a directory is given, all files in this directory \
                        and its subdirectories will be listed.')

    return parser.parse_args()


def main():
    args = parse_options()

    wops = 'goldstandard' if 'goldstandard' in args.targets[
        0] else 'correct-no-gs'

    with open(f'report.{wops}.txt', 'w') as outfile:
        print(f'filters: {args.filtererror}, file: {wops}', file=outfile)

        results = [(old_result[0],
                    filter_markup(args.filtererror,
                                  old_result[1]), old_result[2], old_result[3])
                   for old_result in produce_grammarchecker_results(
                       args.targets, args.zcheck_file)]

        counter, errortags, dupesets = per_sentence_report(
            args, outfile, results)
        used_categories = overview(results, counter, outfile)
        # category_usage(used_categories, counter, outfile, errortags)

        for dupeset in sorted(dupesets):
            print(dupeset)


if __name__ == '__main__':
    main()
