import numpy as np
import csv
import os.path
from os import path
import math

def clean_readings(file):
    test_text = str(open(file, "r").read())
    test_text = test_text.replace("\n", "").replace("c", "").split("!")
    if test_text[-1] == '':
        test_text = test_text[:-1]
    test_text = list(map(int, test_text))
    return test_text

def append_to_csv(filename, starting_sep = "Error", increment = 50, files = ["screenlog.0"]):
    data = acquire_existing_data(filename)
    if len(data) != 0:
        prev_sep = float(data[-1][0])
    else:
        prev_sep = starting_sep+increment
    for file in files:
        saved_data = clean_readings(file)
        for datapoint in saved_data:
            data.append([prev_sep-increment, datapoint])
    data_array = np.asarray(data)
    np.savetxt(filename, data_array, delimiter=",", fmt='%s')
    return data_array

def acquire_existing_data(filename):
    if path.exists(filename):
        with open(filename, newline='') as csvfile:
            data = list(csv.reader(csvfile))
    else:
        data = []
    return data

append_to_csv("area3.csv", 2800)
os.remove("screenlog.0")
