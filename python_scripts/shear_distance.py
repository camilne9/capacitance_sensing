import serial
import math
import time
import csv
import numpy as np
import os.path
from os import path
import scipy.optimize as optimize
import matplotlib.pyplot as plt
import seaborn
import pandas

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
    """
    Groups the data by batch and averages the capacitance readings. Takes one
    argument which is a list of lists containing all of the data in the format
    its in as it is loaded in "load_csv()".
    """
    max_batch = int(int(10*float(data_array[-1][0]))/10)
    max_batch += 1
    avg_data = []
    for batch in range(max_batch):
        temp_filtered_array = []
        for row in data_array:
            if int(int(10*float(row[0]))/10) == batch:
                temp_filtered_array.append(row)
        if temp_filtered_array != []:
            avg_data.append(np.mean(np.array(temp_filtered_array), axis = 0).tolist())
    return avg_data

ep = 8.85
initial_dist = 404.13159950276594
area = 582.3487110122857

data = avg_data(load_csv("csv_files/7-23_ramp4_5x.csv"))
min_max = []
for row in data:
    if row[1] == 0 or row[1] == 175:
        min_max.append(row[4])

distances = []
for cap in min_max:
    cap_change = cap - min_max[0]
    distance = initial_dist/(1+ cap_change*initial_dist/(ep*area))
    distances.append(distance)

shear = []
for index in range(len(distances)-1):
    shear.append(abs(distances[index]-distances[index+1]))

print(sum(shear)/len(shear))
