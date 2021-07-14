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
    """
    Accesses the named csv file and puts the data in a list of lists. Converts
    the str variable entries to ints and floats. The required argument is the
    filepath for the csv file being accessed.
    """
    with open(filename) as csvfile:
        data_array = list(csv.reader(csvfile))
    float_array = []
    for row in data_array:
        float_array.append(list(map(float, row)))
    return float_array

def avg_data(data_array):
    """"
    Groups the data by batch and averages the capacitance readings. Takes one
    argument which is a list of lists containing all of the data in the format
    its in as it is loaded in "load_csv()".
    """"
    max_batch = int(int(10*float(data_array[-1][0]))/10)
    max_batch += 1
    avg_data = []
    for batch in range(max_batch):
        temp_filtered_array = []
        for row in data_array:
            if int(int(10*float(row[0]))/10) == batch:
                temp_filtered_array.append(row)
        avg_data.append(np.mean(np.array(temp_filtered_array), axis = 0).tolist())
    return avg_data


def cap_formula(params):
    """
    Finds the sum of the squared errors between the experimental and
    theoretical capacitance values. Takes one required argument that is a
    list of parameters [area, separation] which are the overlapping area and
    initial separation distance.
    """
    # filters the data for only cases were the stack was NOT sheared
    zero_voltage = []
    for row in data:
        if row[1] == 0:
            zero_voltage.append(row)

    area, separation = params
    # sums the squared error for each of the sheared cases
    error = 0
    for row in zero_voltage:
        error += (row[-1]-ep*area/(separation+5*row[0]))**2
    return error

def shear(x):
    """
    Finds the sum of the squared errors between the experimental and
    theoretical capacitance values. Takes one required argument that is
    the shear distance of the stack.
    """
    # filters the data for only cases were the stack was sheared
    shear_voltage = []
    for row in data:
        if row[1] != 0:
            shear_voltage.append(row)
    # sums the squared error for each of the sheared cases
    error = 0
    for row in shear_voltage:
        error += (row[-1]-ep*area/(separation+x+5*(row[0]-1)))**2
    return error

def find_area_and_sep():
    """
    Finds the overlapping area and initial separation distance that minimizes
    the error in experimental and theoretical capaticance values
    """
    # repeatedly runs "cap_formula" with different trial area and separation
    # to determine the minimizing case
    initial_guess = [500, 300]
    result = optimize.minimize(cap_formula, initial_guess)
    # once the minimum is found, the results are returned. Otherwise, there is
    # an error message
    if result.success:
        fitted_params = result.x
        return fitted_params
    else:
        raise ValueError(result.message)

def find_shear_distance():
    """
    Finds the shear distance that minimizes the error in experimental and
    theoretical capaticance values after taking the area and separation
    distance as given by the global variables.
    """
    # repeatedly runs "cap_formula" with different trial area and separation
    # to determine the minimizing case
    initial_guess = [1]
    result = optimize.minimize(shear, initial_guess)
    # once the minimum is found, the results are returned. Otherwise, there is
    # an error message
    if result.success:
        fitted_params = result.x
        return fitted_params[0]
    else:
        raise ValueError(result.message)

def print_results():
    """
    Prints the calculated global variables of the electrodes' overlapping area,
    the intial separation distance, and the shear distance of the stack.
    """
    print(f"Area: {area}")
    print(f"Intitial Separation: {separation}")
    print(f"Shear Distance: {shear_distance}")

def main(filename):
    """
    Executes appropriate methods in the correct order. Takes one required
    argument which must be the name of the csv file containing the relevant
    data and one optional argument to indicate if you want the data plotted.
    """
    # creates global variable "data" that is a list of lists containing
    # all of the information from the named csv file
    global data
    data = avg_data(load_csv(filename))
    # creates global variables "area" and "separation" which indicate the error
    # minimizing overlapping area and initial electrode separation distance
    # respectively
    global area, separation
    area, separation = find_area_and_sep()
    # creates global variable for the error minimizing shear distance by taking
    # the global area and separation distance as given
    global shear_distance
    shear_distance = find_shear_distance()
    # prints the findins and plots the data
    print_results()
    plot_data(data)

def plot_data(data_array):
    """
    Plots the data as batch (x axis) vs capacitance (y axis). Required argument
    is a list of lists with batch number as the first column and capacitance as
    the last (which is the format done by collect_data.py)
    """
    print("plotting...")
    plt.scatter(np.array(data_array)[:, 0].tolist(), np.array(data_array)[:, -1].tolist())
    plt.show()

main("csv_files/7-13_5m9.csv")
