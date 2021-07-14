import serial
import math
import time
import csv
import numpy as np
import os.path
from os import path
import scipy.optimize as optimize
import matplotlib.pyplot as plt

from collect_data import Collect_Data
from find_sep_dist import Shear_Distance

# Tunable constants
readings_per_batch = 100
max_voltage = 175
trials = 6
wait_time = 1
offset = 128
voltages = [0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25,
            0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25]
            # 0, 25, 50, 75, 100, 125, 150, 175,
            # 150, 125, 100, 75, 50, 25, 0]
filename = "csv_files/7-14_test4.csv"

def main(filename, readings_per_batch, max_voltage, trials, wait_time,
            pause, offset, voltages=False, area = None, separation = None, plot = True):
        Collect_Data(filename, readings_per_batch, max_voltage, trials,
                wait_time, pause, offset, voltages)
        Shear_Distance(filename, area, separation, plot)

main(filename=filename, readings_per_batch=readings_per_batch,
        max_voltage=max_voltage, trials=trials, wait_time=wait_time,
        pause=True, offset=225, voltages=False, plot = False)
