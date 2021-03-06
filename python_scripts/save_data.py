import numpy as np
import csv
import os.path
from os import path
import math

def clean_readings(file):
    test_text = str(open(file, "r").read())
    test_text = test_text.replace("\n", "").replace("c", "").split("!")
    test_text = remove_extra_commands(test_text)
    # if test_text[-1] == '':
    #     test_text = test_text[:-1]
    test_text = list(map(int, test_text))
    return test_text

def remove_extra_commands(text):
    new_text = []
    for element in text:
        if element.isdigit():
            new_text.append(element)
    return new_text


def append_to_csv(filename, starting_sep = "Error", increment = -20, files = ["screenlog.0"], toggle = False, offset = 128):
    data = acquire_existing_data(filename)
    if len(data) != 0:
        prev_sep = float(data[-1][0])
        prev_batch = float(data[-1][2])
        prev_offset = 127+ prev_batch
    else:
        prev_sep = starting_sep+increment
        prev_batch = 0
        prev_offset = 127
    for file in files:
        saved_data = clean_readings(file)
        for datapoint in saved_data:
            cap = convert_to_cap(datapoint, offset)
            if toggle:
                data.append([toggle*((prev_batch)%2), datapoint, prev_batch+1, cap])
            else:
                data.append([prev_sep-increment, datapoint, prev_batch+1, cap])
    data_array = np.asarray(data)
    np.savetxt(filename, data_array, delimiter=",", fmt='%s')
    return data_array

def convert_to_cap(datapoint, offset):
    datapoint = (datapoint)*(4.8828125e-7) - 4.096 + (offset - 128)*(.148)
    # (.3013)
    # (.1328125)
    return datapoint

def acquire_existing_data(filename):
    if path.exists(filename):
        with open(filename, newline='') as csvfile:
            data = list(csv.reader(csvfile))
    else:
        data = []
    return data

append_to_csv("csv_files/7-09_control1_se.csv", 0, increment = -20, offset = 128)
os.remove("screenlog.0")
