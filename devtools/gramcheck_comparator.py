#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import argparse
import pickle
from collections import defaultdict
import gramcheck_tester2
from corpustools import util


def correct_no_suggestion_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_no_suggestions(c_error, d_error)]


def correct_not_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_without_hit(c_error, d_error)]


def corrections_not_in_suggestion_per_sentence(nices, outfile):
    if nices:
        print('~~~~~~', file=outfile)
        print('\tcorrect and dc align, correction not among suggestions', file=outfile)
        for nice in nices:
            print(f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]} -> [{", ".join(nice[1][5])}]', file=outfile)


def corrections_no_suggestion_per_sentence(nices, outfile):
    if nices:
        print('~~~~~~', file=outfile)
        print('\tcorrect and dc align, no suggestions', file=outfile)
        for nice in nices:
            print(f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]}', file=outfile)


def correct_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_with_hit(c_error, d_error)]


def correction_in_suggestion_per_sentence(nices, outfile):
    if nices:
        print('~~~~~~', file=outfile)
        print('\tcorrect and dc align, and correction found in dc', file=outfile)
        for nice in nices:
            print(
                f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]}, position {nice[1][5].index(nice[0]["correct"])}', file=outfile
            )


def corrects_not_in_dc(c_errors, d_errors):
    corrects = []
    for c_error in c_errors:
        for d_error in d_errors:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(c_error)

    return corrects


def marked_errors_not_reported_per_sentence(corrects, outfile):
    if corrects:
        print('~~~~~~', file=outfile)
        print('\tcorrect errors not found in dc', file=outfile)
        for c_error in corrects:
            print(f'\t\t{c_error}', file=outfile)


def dcs_not_in_correct(correct, dc):
    corrects = []
    for d_error in dc:
        for c_error in correct:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(d_error)

    return corrects


def reported_errors_not_marked_per_sentence(corrects, outfile):
    if corrects:
        print('~~~~~~', file=outfile)
        print('\tdc errors not found in correct', file=outfile)
        for c_error in corrects:
            print(f'\t\t{c_error}', file=outfile)


def has_same_range_and_error(c_error, d_error):
    if d_error[3] == 'double-space-before':
        return c_error['start'] == d_error[1] and c_error['end'] == d_error[2]
    else:
        return c_error['start'] == d_error[1] and c_error['end'] == d_error[2] and c_error['error'] == d_error[0]


def has_suggestions_with_hit(c_error, d_error):
    return has_same_range_and_error(
        c_error, d_error) and d_error[5] and c_error['correct'] in d_error[5]


def has_suggestions_without_hit(c_error, d_error):
    return has_same_range_and_error(
        c_error,
        d_error) and d_error[5] and c_error['correct'] not in d_error[5]


def has_no_suggestions(c_error, d_error):
    return has_same_range_and_error(c_error, d_error) and not d_error[5]


def new_errors(sentence, zcheck_file, runner):
    new_d_errors = gramcheck_tester2.gramcheck(sentence, zcheck_file, runner)
    #if len(new_d_errors['errs']) > 1:
        #raise SystemExit('errs too long', new_d_errors['errs'])

    return new_d_errors['errs']


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
        remove_previous = previous_error[1] == d_error[1] and previous_error[2] == d_error[2] and previous_error[3] == 'typo'

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


def filter_dc(d_result, zcheck_file, runner):
    """Remove errors that cover the same area of the typo and msyn types."""
    d_errors = d_result['errs']

    for d_error in d_errors:
        fix_aistton(d_errors, d_errors.index(d_error), zcheck_file, runner)

    indexes = defaultdict(list)
    for d_error in d_errors:
        indexes[(d_error[1], d_error[2])].append(d_error)

    for index in indexes:
        dupelist = indexes[index]
        if len(dupelist) > 1 and 'typo' in [dupe[3] for dupe in dupelist]:
            for dupe in dupelist:
                if dupe[3] != 'typo' and 'msyn' in dupe[3]:
                    d_errors.remove(dupe)

    return d_result


def is_wanted_error(c_error, filters):
    if c_error['type'] == 'errorsyn':
        return is_wanted_errorsyn(c_error)
    else:
        return c_error['type'] not in filters

def is_wanted_errorsyn(c_error):
    return c_error.get('errorinfo') is not None and ('space' in c_error['errorinfo'] or 'cmp' in c_error['errorinfo'])


def filter_markup(filters, c_errors):
    return [
        c_error for c_error in c_errors
        if is_wanted_error(c_error, filters)
    ]


def get_results(filters, pickle_file, zcheck_file, outfile):
    runner = util.ExternalCommandRunner()
    with open(pickle_file, 'rb') as pickle_stream:
        print(f'filters: {filters}, file: {pickle_file}', file=outfile)
        return [(result[0], filter_markup(filters, result[1]), result[2],
                 filter_dc(result[3], zcheck_file, runner))
                for x, result in enumerate(pickle.load(pickle_stream))]


def report_markup_dupes(c_errors, errortags, counter, outfile):
    indexes = defaultdict(int)
    for c_error in c_errors:
        errortags.add(c_error['type'])
        indexes[(c_error['start'], c_error['end'])] += 1

    for index in indexes:
        if indexes[index] > 1:
            print(f'Markup duplicates of {indexes}', file=outfile)
            for c_error in c_errors:
                if c_error['start'] == index[0] and c_error[
                        'end'] == index[1]:
                    counter['markup_dupes'] += 1
                    print(f'\t{c_error}', file=outfile)


def report_dc_dupes(d_errors, counter, outfile):
    indexes = defaultdict(int)
    for d_error in d_errors:
        indexes[(d_error[1], d_error[2])] += 1

    for index in indexes:
        if indexes[index] > 1:
            print(f'dc duplicates of {index}', file=outfile)
            for d_error in d_errors:
                if d_error[1] == index[0] and d_error[2] == index[1]:
                    counter['dc_dupes'] += 1
                    print(f'\t{d_error}', file=outfile)


def report_markup_without_dc_hits(c_errors, d_errors, counter, outfile):
    # oppmerkede feil som ikke blir rapportert
    marked_errors_not_reported = corrects_not_in_dc(c_errors, d_errors)
    marked_errors_not_reported_per_sentence(marked_errors_not_reported, outfile)
    counter['total_manual_errors_not_found_by_grammarchecker'] += len(
        marked_errors_not_reported)
    for marked_error_not_reported in marked_errors_not_reported:
        counter[
            f'manually_marked_errors_{marked_error_not_reported["type"]}_not_reported'] += 1


def report_dc_not_hitting_markup(c_errors, d_errors, counter, outfile):
    # rapporterte feil som ikke er oppmerket
    reported_errors_not_marked = dcs_not_in_correct(c_errors, d_errors)
    reported_errors_not_marked_per_sentence(reported_errors_not_marked, outfile)
    counter['total_grammarchecker_errors_not_found_in_manual_markup'] += len(
        reported_errors_not_marked)
    for reported_error_not_marked in reported_errors_not_marked:
        counter[
            f'grammarchecker_errors_{reported_error_not_marked[3]}_not_markedup'] += 1


def report_markup_dc_align_correct_in_suggestion(c_errors, d_errors, counter, outfile):
    # Oppmerket feil blir rapportert, rapporterte feil har forslag, og manuell retting er blant disse
    corrections_in_suggestion = correct_in_dc(c_errors, d_errors)
    correction_in_suggestion_per_sentence(corrections_in_suggestion, outfile)
    counter['correction_in_suggestion'] += len(corrections_in_suggestion)
    for correction_in_suggestion in corrections_in_suggestion:
        counter[
            f'correction_in_suggestion_{correction_in_suggestion[0]["type"]}_{correction_in_suggestion[1][3]}'] += 1


def report_markup_dc_align_correct_not_in_suggestion(c_errors, d_errors,
                                                     counter, outfile):
    # Oppmerket feil blir rapportert, rapporterte feil har forslag, og manuell retting er *ikke* blant disse
    corrections_not_in_suggestion = correct_not_in_dc(c_errors, d_errors)
    corrections_not_in_suggestion_per_sentence(corrections_not_in_suggestion, outfile)
    counter['correction_not_in_suggestion'] += len(
        corrections_not_in_suggestion)
    for correction_not_in_suggestion in corrections_not_in_suggestion:
        counter[
            f'correction_not_in_suggestion_{correction_not_in_suggestion[0]["type"]}_{correction_not_in_suggestion[1][3]}'] += 1


def report_markup_dc_align_no_suggestion(c_errors, d_errors, counter, outfile):
    # Oppmerket feil blir rapportert, rapporterte feil har ingen forslag
    corrections_no_suggestion = correct_no_suggestion_in_dc(c_errors, d_errors)
    corrections_no_suggestion_per_sentence(corrections_no_suggestion, outfile)
    counter['correction_no_suggestion'] += len(corrections_no_suggestion)
    for correction_no_suggestion in corrections_no_suggestion:
        counter[
            f'correction_no_suggestion_{correction_no_suggestion[0]["type"]}_{correction_no_suggestion[1][3]}'] += 1


def per_sentence(sentence, filename, c_errors, d_errors, counter, errortags, outfile):
    counter['paragraphs_with_errors'] += 1
    counter['total_manually_marked_errors'] += len(c_errors)
    for manual in c_errors:
        counter[f'manually_marked_errors_{manual["type"]}'] += 1
    counter['total_grammarchecker_errors'] += len(d_errors)
    for dc_error in d_errors:
        counter[
            f'grammarchecker_errors_{dc_error[3].replace(" ", "_")}'] += 1
    print('==========', file=outfile)
    print(sentence, '<-', filename, file=outfile)

    report_markup_dupes(c_errors, errortags, counter, outfile)
    report_dc_dupes(d_errors, counter, outfile)
    report_markup_without_dc_hits(c_errors, d_errors,
                                    counter, outfile)
    report_dc_not_hitting_markup(c_errors, d_errors, counter, outfile)
    report_markup_dc_align_correct_in_suggestion(
        c_errors, d_errors, counter, outfile)
    report_markup_dc_align_correct_not_in_suggestion(
        c_errors, d_errors, counter, outfile)
    report_markup_dc_align_no_suggestion(c_errors, d_errors,
                                            counter, outfile)
    print(file=outfile)


def overview_header(results, counter, used_categories, outfile):
    print(f'Paragraphs {len(results)}', file=outfile)
    print(f'Paragraphs with errors {counter["paragraphs_with_errors"]}\n', file=outfile)
    used_categories.add("paragraphs_with_errors")


def overview_markup(counter, used_categories, outfile):
    print(f'Manually marked errors: {counter["total_manually_marked_errors"]}', file=outfile)
    used_categories.add("total_manually_marked_errors")
    print(
        f'Manually marked errors found by the grammarchecker: {counter["total_manually_marked_errors"] - counter["total_manual_errors_not_found_by_grammarchecker"]}', file=outfile
    )
    print(
        f'Manually marked errors not found by the grammarchecker: {counter["total_manual_errors_not_found_by_grammarchecker"]} == False negatives', file=outfile
    )
    used_categories.add("total_manual_errors_not_found_by_grammarchecker")
    print('By type', file=outfile)
    for label in [
            label for label in counter
            if label.startswith('manually_marked_errors')
            and not label.endswith('not_reported')
    ]:
        print(f'{label}: {counter[label]}', file=outfile)
        print(f'{label + "_not_reported"}: {counter[label + "_not_reported"]}', file=outfile)
        print(
            f'{label + "_found"}: {counter[label] - counter[label + "_not_reported"]}', file=outfile
        )
        used_categories.add(label)
        used_categories.add(label + "_not_reported")

    print('\n\n', file=outfile)


def overview_grammarchecker(counter, used_categories, outfile):
    print(
        f'Errors reported by grammarchecker: {counter["total_grammarchecker_errors"]}', file=outfile
    )
    used_categories.add("total_grammarchecker_errors")
    print(
        f'Grammar checker errors that align with manually marked up errors: {counter["total_grammarchecker_errors"] - counter["total_grammarchecker_errors_not_found_in_manual_markup"]} == True positives', file=outfile
    )
    print(
        f'Grammar checker errors that don\'t align with manually marked up errors: {counter["total_grammarchecker_errors_not_found_in_manual_markup"]} == False positives', file=outfile
    )

    used_categories.add(
        "total_grammarchecker_errors_not_found_in_manual_markup")
    print('By type', file=outfile)
    for label in [
            label for label in counter
            if label.startswith('grammarchecker_errors')
            and not label.endswith('not_markedup')
    ]:
        print(f'{label}: {counter[label]}', file=outfile)
        print(f'{label + "_not_markedup"}: {counter[label + "_not_markedup"]}', file=outfile)
        print(
            f'{label + "_found"}: {counter[label] - counter[label + "_not_markedup"]}', file=outfile
        )
        used_categories.add(label)
        used_categories.add(label + "_not_markedup")

    print('\n\n', file=outfile)


def overview_hits_with_hit_in_suggestions(counter, used_categories, outfile):
    print(
        f'Manually marked errors and reported errors that align: {counter["correction_in_suggestion"] + counter["correction_not_in_suggestion"] + counter["correction_no_suggestion"]}\n', file=outfile
    )
    print(
        f'Reported errors where correction is among suggestions {counter["correction_in_suggestion"]}', file=outfile
    )
    used_categories.add("correction_in_suggestion")
    print('By manual error and grammarchecker error pairs', file=outfile)
    for label in [
            label for label in counter
            if label.startswith('correction_in_suggestion_')
    ]:
        print(f'{label}: {counter[label]}', file=outfile)
        used_categories.add(label)

    print(file=outfile)


def overview_hits_without_hit_in_suggestions(counter, used_categories, outfile):
    print(
        f'Reported errors where correction is not among suggestions {counter["correction_not_in_suggestion"]}', file=outfile
    )
    used_categories.add("correction_not_in_suggestion")
    print('By manual error and grammarchecker error pairs', file=outfile)
    for label in [
            label for label in counter
            if label.startswith('correction_not_in_suggestion_')
    ]:
        print(f'{label}: {counter[label]}', file=outfile)
        used_categories.add(label)

    print(file=outfile)


def overview_hits_no_suggestions(counter, used_categories, outfile):
    print(
        f'Reported errors without suggestions {counter["correction_no_suggestion"]}', file=outfile
    )
    used_categories.add("correction_no_suggestion")
    print('By manual error and grammarchecker error pairs', file=outfile)
    for label in [
            label for label in counter
            if label.startswith('correction_no_suggestion_')
    ]:
        print(f'{label}: {counter[label]}', file=outfile)
        used_categories.add(label)


def overview_hits(counter, used_categories, outfile):
    overview_hits_with_hit_in_suggestions(counter, used_categories, outfile)
    overview_hits_without_hit_in_suggestions(counter, used_categories, outfile)
    overview_hits_no_suggestions(counter, used_categories, outfile)


def overview_precision_recall(counter, outfile):
    """
    precision: TP / TP + FP =
    Recall: TP / TP + FN =
    Accuracty = TP + TN / TP + TN + FP + FN
    """
    true_positives = counter["total_grammarchecker_errors"] - counter[
        "total_grammarchecker_errors_not_found_in_manual_markup"]
    false_positives = counter[
        "total_grammarchecker_errors_not_found_in_manual_markup"]
    # TP + FP = all errors found by grammarchecker
    false_negatives = counter["total_grammarchecker_errors"] - counter[
        "total_manually_marked_errors"]
    print(
        f'\nOverall precision: {true_positives/counter["total_grammarchecker_errors"]:.2f} ({true_positives}/{counter["total_grammarchecker_errors"]})', file=outfile
    )
    print(
        f'Overall recall: {true_positives/(true_positives + false_negatives):.2f} ({true_positives}/{(true_positives + false_negatives)})\n', file=outfile
    )


def overview(results, counter, used_categories, outfile):
    overview_header(results, counter, used_categories, outfile)
    overview_markup(counter, used_categories, outfile)
    overview_grammarchecker(counter, used_categories, outfile)
    overview_hits(counter, used_categories, outfile)
    overview_precision_recall(counter, outfile)


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(
        description='Report on manual markup versus grammarchecker.')

    parser.add_argument('--filtererror', help='Remove named errortags')
    parser.add_argument('zcheck_file', help='The grammarchecker archive')
    parser.add_argument('pickle_file', help='The pickle file')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()
    counter = defaultdict(int)
    errortags = set()

    outfile_name = f'{args.pickle_file.replace("/", "_")}.pickle.txt'

    with open(outfile_name, 'w') as outfile:
        results = get_results(
            args.filtererror.split(',') if args.filtererror else [],
            f'{args.pickle_file.replace("/", "_")}.pickle', args.zcheck_file, outfile)
        for result in results:
            if result[1] or result[3]['errs']:
                per_sentence(result[0], result[2], result[1], result[3]['errs'], counter, errortags, outfile)
        used_categories = set()
        overview(results, counter, used_categories, outfile)

        all_categories = {label for label in counter}
        not_used = all_categories - used_categories
        if not_used:
            print('\n\nnot used\n\n', file=outfile)
            for label in not_used:
                print(f'{label}: {counter[label]}', file=outfile)

        print('Errortags', file=outfile)
        for errortag in errortags:
            print(errortag, file=outfile)


if __name__ == '__main__':
    main()
