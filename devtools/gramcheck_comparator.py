# -*- coding:utf-8 -*-

import argparse
import pickle
import sys
from collections import defaultdict


def correct_no_suggestion_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_no_suggestions(c_error, d_error)]


def correct_not_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_without_hit(c_error, d_error)]


def corrections_not_in_suggestion_per_sentence(nices):
    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, but dc has no suggestions')
        for nice in nices:
            print(f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]}')


def correct_in_dc(correct, dc):
    return [(c_error, d_error) for c_error in correct for d_error in dc
            if has_suggestions_with_hit(c_error, d_error)]


def correction_in_suggestion_per_sentence(nices):
    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, and correction found in dc')
        for nice in nices:
            print(
                f'\t\t{nice[0]["error"]} -> {nice[0]["correct"]}, position {nice[1][5].index(nice[0]["correct"])}'
            )


def corrects_not_in_dc(correct, dc):
    corrects = []
    for c_error in correct:
        for d_error in dc:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(c_error)

    return corrects


def marked_errors_not_reported_per_sentence(corrects):
    if corrects:
        print('~~~~~~')
        print('\tcorrect errors not found in dc')
        for c_error in corrects:
            print(f'\t\t{c_error}')


def dcs_not_in_correct(correct, dc):
    corrects = []
    for d_error in dc:
        for c_error in correct:
            if has_same_range_and_error(c_error, d_error):
                break
        else:
            corrects.append(d_error)

    return corrects


def reported_errors_not_marked_per_sentence(corrects):
    if corrects:
        print('~~~~~~')
        print('\tdc errors not found in correct')
        for c_error in corrects:
            print(f'\t\t{c_error}')


def has_same_range_and_error(c_error, d_error):
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


def get_results(filters):
    with open('results.pickle', 'rb') as pickle_stream:
        print(f'filters: {filters}')
        return [(result[0], [
            c_error for c_error in result[1] if c_error['type'] not in filters
        ], result[2], result[3])
                for x, result in enumerate(pickle.load(pickle_stream))]


def report_markup_dupes(c_errors, errortags, counter):
    argh = defaultdict(int)
    for c_error in c_errors:
        errortags.add(c_error['type'])
        argh[(c_error['start'], c_error['end'])] += 1

    for indexes in argh:
        if argh[indexes] > 1:
            print(f'Markup duplicates of {indexes}')
            for c_error in c_errors:
                if c_error['start'] == indexes[0] and c_error[
                        'end'] == indexes[1]:
                    counter['markup_dupes'] += 1
                    print(f'\t{c_error}')


def report_dc_dupes(d_errors, counter):
    urgh = defaultdict(int)
    for d_error in d_errors:
        urgh[(d_error[1], d_error[2])] += 1

    for indexes in urgh:
        if urgh[indexes] > 1:
            print(f'dc duplicates of {indexes}')
            for d_error in d_errors:
                if d_error[1] == indexes[0] and d_error[2] == indexes[1]:
                    counter['dc_dupes'] += 1
                    print(f'\t{d_error}')


def report_markup_without_dc_hits(c_errors, d_errors, counter):
    # oppmerkede feil som ikke blir rapportert
    marked_errors_not_reported = corrects_not_in_dc(c_errors, d_errors)
    marked_errors_not_reported_per_sentence(marked_errors_not_reported)
    counter['total_manual_errors_not_found_by_grammarchecker'] += len(
        marked_errors_not_reported)
    for marked_error_not_reported in marked_errors_not_reported:
        counter[
            f'manually_marked_errors_{marked_error_not_reported["type"]}_not_reported'] += 1


def report_dc_not_hitting_markup(c_errors, d_errors, counter):
    # rapporterte feil som ikke er oppmerket
    reported_errors_not_marked = dcs_not_in_correct(c_errors, d_errors)
    reported_errors_not_marked_per_sentence(reported_errors_not_marked)
    counter['total_grammarchecker_errors_not_found_in_manual_markup'] += len(
        reported_errors_not_marked)
    for reported_error_not_marked in reported_errors_not_marked:
        counter[
            f'grammarchecker_errors_{reported_error_not_marked[3]}_not_markedup'] += 1


def report_markup_dc_align_correct_in_suggestion(c_errors, d_errors, counter):
    # Oppmerket feil blir rapportert, rapporterte feil har forslag, og manuell retting er blant disse
    corrections_in_suggestion = correct_in_dc(c_errors, d_errors)
    correction_in_suggestion_per_sentence(corrections_in_suggestion)
    counter['correction_in_suggestion'] += len(corrections_in_suggestion)
    for correction_in_suggestion in corrections_in_suggestion:
        counter[
            f'correction_in_suggestion_{correction_in_suggestion[0]["type"]}_{correction_in_suggestion[1][3]}'] += 1


def report_markup_dc_align_correct_not_in_suggestion(c_errors, d_errors,
                                                     counter):
    # Oppmerket feil blir rapportert, rapporterte feil har forslag, og manuell retting er *ikke* blant disse
    corrections_not_in_suggestion = correct_not_in_dc(c_errors, d_errors)
    corrections_not_in_suggestion_per_sentence(corrections_not_in_suggestion)
    counter['correction_not_in_suggestion'] += len(
        corrections_not_in_suggestion)
    for correction_not_in_suggestion in corrections_not_in_suggestion:
        counter[
            f'correction_not_in_suggestion_{correction_not_in_suggestion[0]["type"]}_{correction_not_in_suggestion[1][3]}'] += 1


def report_markup_dc_align_no_suggestion(c_errors, d_errors, counter):
    # Oppmerket feil blir rapportert, rapporterte feil har ingen forslag
    corrections_no_suggestion = correct_no_suggestion_in_dc(c_errors, d_errors)
    corrections_not_in_suggestion_per_sentence(corrections_no_suggestion)
    counter['correction_no_suggestion'] += len(corrections_no_suggestion)
    for correction_no_suggestion in corrections_no_suggestion:
        counter[
            f'correction_no_suggestion_{correction_no_suggestion[0]["type"]}_{correction_no_suggestion[1][3]}'] += 1


def per_sentence(results, counter, errortags):
    for result in results:
        if result[1] or result[3]['errs']:
            counter['paragraphs_with_errors'] += 1
            counter['total_manually_marked_errors'] += len(result[1])
            for manual in result[1]:
                counter[f'manually_marked_errors_{manual["type"]}'] += 1
            counter['total_grammarchecker_errors'] += len(result[3]["errs"])
            for dc_error in result[3]["errs"]:
                counter[
                    f'grammarchecker_errors_{dc_error[3].replace(" ", "_")}'] += 1
            print('==========')
            print(result[0])

            report_markup_dupes(result[1], errortags, counter)
            report_dc_dupes(result[3]['errs'], counter)
            report_markup_without_dc_hits(result[1], result[3]["errs"],
                                          counter)
            report_dc_not_hitting_markup(result[1], result[3]["errs"], counter)
            report_markup_dc_align_correct_in_suggestion(
                result[1], result[3]["errs"], counter)
            report_markup_dc_align_correct_not_in_suggestion(
                result[1], result[3]["errs"], counter)
            report_markup_dc_align_no_suggestion(result[1], result[3]["errs"],
                                                 counter)
            print()


def overview_header(results, counter, used_categories):
    print(f'Paragraphs {len(results)}')
    print(f'Paragraphs with errors {counter["paragraphs_with_errors"]}\n')
    used_categories.add("paragraphs_with_errors")


def overview_markup(counter, used_categories):
    print(f'Manually marked errors: {counter["total_manually_marked_errors"]}')
    used_categories.add("total_manually_marked_errors")
    print(
        f'Manually marked errors found by the grammarchecker: {counter["total_manually_marked_errors"] - counter["total_manual_errors_not_found_by_grammarchecker"]}'
    )
    print(
        f'Manually marked errors not found by the grammarchecker: {counter["total_manual_errors_not_found_by_grammarchecker"]}'
    )
    used_categories.add("total_manual_errors_not_found_by_grammarchecker")
    print('By type')
    for label in [
            label for label in counter
            if label.startswith('manually_marked_errors')
            and not label.endswith('not_reported')
    ]:
        print(f'{label}: {counter[label]}')
        print(f'{label + "_not_reported"}: {counter[label + "_not_reported"]}')
        print(
            f'{label + "_found"}: {counter[label] - counter[label + "_not_reported"]}'
        )
        used_categories.add(label)
        used_categories.add(label + "_not_reported")

    print('\n\n')


def overview_grammarchecker(counter, used_categories):
    print(
        f'Errors reported by grammarchecker: {counter["total_grammarchecker_errors"]}'
    )
    used_categories.add("total_grammarchecker_errors")
    print(
        f'Grammar checker errors that align with manually marked up errors: {counter["total_grammarchecker_errors"] - counter["total_grammarchecker_errors_not_found_in_manual_markup"]}'
    )
    print(
        f'Grammar checker errors that don\'t align with manually marked up errors: {counter["total_grammarchecker_errors_not_found_in_manual_markup"]}'
    )
    used_categories.add(
        "total_grammarchecker_errors_not_found_in_manual_markup")
    print('By type')
    for label in [
            label for label in counter
            if label.startswith('grammarchecker_errors')
            and not label.endswith('not_markedup')
    ]:
        print(f'{label}: {counter[label]}')
        print(f'{label + "_not_markedup"}: {counter[label + "_not_markedup"]}')
        print(
            f'{label + "_found"}: {counter[label] - counter[label + "_not_markedup"]}'
        )
        used_categories.add(label)
        used_categories.add(label + "_not_markedup")

    print('\n\n')


def overview_hits_with_hit_in_suggestions(counter, used_categories):
    print(
        f'Manually marked errors and reported errors that align: {counter["correction_in_suggestion"] + counter["correction_not_in_suggestion"] + counter["correction_no_suggestion"]}\n'
    )
    print(
        f'Reported errors where correction is among suggestions {counter["correction_in_suggestion"]}'
    )
    used_categories.add("correction_in_suggestion")
    print('By manual error and grammarchecker error pairs')
    for label in [
            label for label in counter
            if label.startswith('correction_in_suggestion_')
    ]:
        print(f'{label}: {counter[label]}')
        used_categories.add(label)

    print()


def overview_hits_without_hit_in_suggestions(counter, used_categories):
    print(
        f'Reported errors where correction is not among suggestions {counter["correction_not_in_suggestion"]}'
    )
    used_categories.add("correction_not_in_suggestion")
    print('By manual error and grammarchecker error pairs')
    for label in [
            label for label in counter
            if label.startswith('correction_not_in_suggestion_')
    ]:
        print(f'{label}: {counter[label]}')
        used_categories.add(label)

    print()


def overview_hits_no_suggestions(counter, used_categories):
    print(
        f'Reported errors without suggestions {counter["correction_no_suggestion"]}'
    )
    used_categories.add("correction_no_suggestion")
    print('By manual error and grammarchecker error pairs')
    for label in [
            label for label in counter
            if label.startswith('correction_no_suggestion_')
    ]:
        print(f'{label}: {counter[label]}')
        used_categories.add(label)


def overview_hits(counter, used_categories):
    overview_hits_with_hit_in_suggestions(counter, used_categories)
    overview_hits_without_hit_in_suggestions(counter, used_categories)
    overview_hits_no_suggestions(counter, used_categories)


def overview(results, counter, used_categories):
    overview_header(results, counter, used_categories)
    overview_markup(counter, used_categories)
    overview_grammarchecker(counter, used_categories)
    overview_hits(counter, used_categories)


def parse_options():
    """Parse the options given to the program."""
    parser = argparse.ArgumentParser(
        description='Report on manual markup versus grammarchecker.')

    parser.add_argument('--filtererror', help='Remove named errortags')

    args = parser.parse_args()
    return args


def main():
    args = parse_options()
    counter = defaultdict(int)
    errortags = set()

    #errormorphsyn
    #errorlang
    #errorortreal
    #errorlex
    #errorsyn
    #errorort

    results = get_results(args.filtererror.split(',') if args.filtererror else [])
    per_sentence(results, counter, errortags)
    used_categories = set()
    overview(results, counter, used_categories)

    all_categories = {label for label in counter}
    not_used = all_categories - used_categories
    if not_used:
        print('\n\nnot used\n\n')
        for label in not_used:
            print(f'{label}: {counter[label]}')

    print('Errortags')
    for errortag in errortags:
        print(errortag)


if __name__ == '__main__':
    main()
