# -*- coding:utf-8 -*-

import pickle


def correct_not_in_dc(correct, dc):
    nices = [
        (c_error['error'], c_error['correct'], d_error[5])
        for c_error in correct
        for d_error in dc
        if (c_error['start'] == d_error[1] and c_error['end'] == d_error[2]) and (c_error['error'] == d_error[0] and c_error['correct'] not in d_error[5])
    ]

    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, but correction not found in dc')
        for nice in nices:
            print(f'\t\t{nice[0]} -> {nice[1]}, dc-suggestions {nice[2]}')


def correct_in_dc(correct, dc):
    nices = [
        (c_error['error'], c_error['correct'], d_error[5].index(c_error['correct']))
        for c_error in correct
        for d_error in dc
        if (c_error['start'] == d_error[1] and c_error['end'] == d_error[2] and d_error[5]) and (c_error['error'] == d_error[0] and c_error['correct'] in d_error[5])
    ]

    if nices:
        print('~~~~~~')
        print('\tcorrect and dc align, and correction found in dc')
        for nice in nices:
            print(f'\t\t{nice[0]} -> {nice[1]}, position {nice[2]}')


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


with open('results.pickle', 'rb') as pickle_stream:
    results = pickle.load(pickle_stream)

print(f'Paragraphs {len(results)}')
for result in results:
    if result[1] or result[3]["errs"]:
        print('==========')
        print(result[0])
        corrects_not_in_dc(result[1], result[3]["errs"])
        dcs_not_in_correct(result[1], result[3]["errs"])
        correct_in_dc(result[1], result[3]["errs"])
        correct_not_in_dc(result[1], result[3]["errs"])
        print()
