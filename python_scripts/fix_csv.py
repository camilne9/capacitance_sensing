import numpy as np
import csv
import os.path
from os import path
import math

def load_csv(filename):
    print("load")
    with open(filename) as csvfile:
        data_array = list(csv.reader(csvfile))
    # data_array = str(open(filename, "r").read())
    # data_array = list(map(int, data_array))
    return data_array

def column(matrix, i):
    return [row[i] for row in matrix]

def fix_csv(data_array):
    ramp_voltage(data_array)
    # print("fix")
    # for index in range(len(data_array)):
    #     data_array[index][3] = raw_to_cap(float(data_array[index][1]), 165)
    # TODO
    # this function is where the actual fixing takes place
    # and will generally be custom to whatever went wrong during collection
    return data_array

def raw_to_cap(raw, offset=128):
    cap = (raw)*(4.8828125e-7) - 4.096 + (offset - 128)*(.3013)
    # (.1328125)
    return cap

def cap_to_raw(cap, offset=128):
    raw = (cap + 4.096 - (offset - 128)*(.1328125))/(4.8828125e-7)
    return raw

def ramp_voltage(data_array, step = 25, trials = 3):
    for index in range(len(data_array)):
        voltage = step*math.floor((float(data_array[index][2])-22)/trials)
        if voltage > 175:
            voltage = 175 - (voltage - 175)
        data_array[index].append(voltage)
    return data_array

def overwrite(data_array, filename):
    print("overwrite")
    print(filename)
    data_array = np.asarray(data_array)
    np.savetxt(filename, data_array, delimiter=",", fmt='%s')
    return


def main(filename):
    overwrite(fix_csv(load_csv(filename)), "csv_files/7-02_thor6b_se.csv")
    return

main("csv_files/7-06_thor1_se.csv")
