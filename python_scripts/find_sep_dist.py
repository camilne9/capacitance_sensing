import serial
import math
import time
import csv
import numpy as np
import os.path
from os import path
import scipy.optimize as optimize
import matplotlib.pyplot as plt

ep = 8.85

def load_csv(filename):
    print("load")
    with open(filename) as csvfile:
        data_array = list(csv.reader(csvfile))
    float_array = []
    for row in data_array:
        float_array.append(list(map(float, row)))
    return float_array

def avg_data(data_array):
    max_batch = int(int(10*float(data_array[-1][0]))/10)
    max_batch += 1
    print(f"max batch: {max_batch}")
    avg_data = []
    for batch in range(max_batch):
        temp_filtered_array = []
        for row in data_array:
            if int(int(10*float(row[0]))/10) == batch:
                temp_filtered_array.append(row)
        avg_data.append(np.mean(np.array(temp_filtered_array), axis = 0).tolist())
    return avg_data


def cap_formula(params):
    print(params)
    zero_voltage = []
    for row in data:
        if row[1] == 0:
            zero_voltage.append(row)
    area, separation = params # <-- for readability you may wish to assign names to the component variables
    error = 0
    for row in zero_voltage:
        error += (row[-1]-ep*area/(separation+5*row[0]))**2
    # print(error)
    return error

def shear(x):
    shear_voltage = []
    for row in data:
        if row[1] != 0:
            shear_voltage.append(row)
    error = 0
    for row in shear_voltage:
        error += (row[-1]-ep*area/(separation+x+5*(row[0]-1)))**2
    return error

def find_area_and_sep():
    initial_guess = [500, 300]
    result = optimize.minimize(cap_formula, initial_guess)
    if result.success:
        fitted_params = result.x
        return fitted_params
    else:
        raise ValueError(result.message)

def find_shear_distance():
    initial_guess = [1]
    result = optimize.minimize(shear, initial_guess)
    if result.success:
        fitted_params = result.x
        return fitted_params[0]
    else:
        raise ValueError(result.message)



def main(filename):
    global data
    data = avg_data(load_csv(filename))
    global area, separation
    area, separation = find_area_and_sep()
    global shear_distance
    shear_distance = find_shear_distance()
    print(f"Area: {area}")
    print(f"Intitial Separation: {separation}")
    print(f"Shear Distance: {shear_distance}")
    plot_data(data)

def plot_data(data_array):
    print("plotting...")
    plt.scatter(np.array(data_array)[:, 0].tolist(), np.array(data_array)[:, -1].tolist())
    plt.show()

main("csv_files/7-12_5m9.csv")
