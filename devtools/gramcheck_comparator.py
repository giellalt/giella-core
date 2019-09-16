# -*- coding:utf-8 -*-

import pickle
from collections import defaultdict


def correct_not_in_dc(correct, dc):
    nices = [
        (c_error['error'], c_error['correct'], d_error[5])
        for c_error in correct for d_error in dc
        if (c_error['start'] == d_error[1] and c_error['end'] == d_error[2])
        and (c_error['error'] == d_error[0]
             and c_error['correct'] not in d_error[5])
    ]

    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, but correction not found in dc')
        for nice in nices:
            print(f'\t\t{nice[0]} -> {nice[1]}, dc-suggestions {nice[2]}')

    return len(nices)


def correct_in_dc(correct, dc):
    nices = [
        (c_error['error'], c_error['correct'],
         d_error[5].index(c_error['correct'])) for c_error in correct
        for d_error in dc
        if (c_error['start'] == d_error[1] and c_error['end'] == d_error[2]
            and d_error[5]) and
        (c_error['error'] == d_error[0] and c_error['correct'] in d_error[5])
    ]

    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, and correction found in dc')
        for nice in nices:
            print(f'\t\t{nice[0]} -> {nice[1]}, position {nice[2]}')

    return len(nices)


def corrects_not_in_dc(correct, dc):
    corrects = []
    for c_error in correct:
        for d_error in dc:
            if c_error['start'] == d_error[1] and c_error['end'] == d_error[2]:
                break
        else:
            corrects.append(c_error)

    if corrects:
        print('~~~~~~')
        print('\tcorrect errors not found in dc')
        for c_error in corrects:
            print(f'\t\t{c_error}')

    return len(corrects)


def dcs_not_in_correct(correct, dc):
    corrects = []
    for d_error in dc:
        for c_error in correct:
            if c_error['start'] == d_error[1] and c_error['end'] == d_error[2]:
                break
        else:
            corrects.append(d_error)

    if corrects:
        print('~~~~~~')
        print('\tdc errors not found in correct')
        for c_error in corrects:
            print(f'\t\t{c_error}')

    return len(corrects)


with open('results.pickle', 'rb') as pickle_stream:
    results = pickle.load(pickle_stream)

print(f'Paragraphs {len(results)}')
counter = defaultdict(int)
for result in results:
    if result[1] or result[3]["errs"]:
        counter['total_manually_marked_errors'] += len(result[1])
        for manual in result[1]:
            counter[f'manually_marked_errors_{manual["type"]}'] += 1
        counter['total_grammarchecker_errors'] += len(result[3]["errs"])
        for dc_error in result[3]["errs"]:
            counter[f'grammarchecker_errors_{dc_error[3].replace(" ", "_")}'] += 1
        print('==========')
        print(result[0])
        counter['total_manual_errors_not_found_by_grammarchecker'] += corrects_not_in_dc(result[1],
                                                     result[3]["errs"])
        counter['total_grammarchecker_errors_not_found_in_manual_markup'] += dcs_not_in_correct(result[1], result[3]["errs"])
        counter['total_manual_and_grammarchecker_align_correction_with_suggestion'] += correct_in_dc(result[1], result[3]["errs"])
        counter['total_manual_and_grammarchecker_align_correction_without_suggestion'] += correct_not_in_dc(
            result[1], result[3]["errs"])
        print()

for label in sorted(counter):
    print(f'{label}: {counter[label]}')
