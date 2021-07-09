import serial
import math
import time
import csv
import numpy as np
import os.path
from os import path

# create objects for the capacitance sensor and voltage source. The path
# name is generally device specific.
cap = serial.Serial("/dev/tty.usbserial-D30A2ZWX" , 9600)
volt = serial.Serial("/dev/tty.usbmodem14101" , 9600)

# Tunable constants
readings_per_batch = 100
max_voltage = 175
trials = 15
wait_time = 5
offset = 128
voltages = [0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25]
            # 0, 25, 50, 75, 100, 125, 150, 175,
            # 150, 125, 100, 75, 50, 25,
            # 0, 25, 50, 75, 100, 125, 150, 175,
            # 150, 125, 100, 75, 50, 25, 0]

# data_array = ["batch", "voltage", "time", "raw", "capacitance"]
data_array = []

def collect_data(readings_per_batch, max_voltage, trials, wait_time, offset, voltages = False):
    if voltages:
        trials = len(voltages)
    for trial in range(trials):
        if not voltages:
            print("no voltages")
            if trial%2 == 0:
                print("zero volts")
                voltage = 0
                volt.write(b"V%d;"%voltage)
            else:
                print("max voltage")
                voltage = max_voltage
                volt.write(b"V%d;"%voltage)
        else:
            voltage = voltages[trial]
            print(voltage)
            volt.write(b"V%d;"%voltage)

        print("going to sleep")
        time.sleep(1)
        print("waking up")

        for interation in range(readings_per_batch):
            cap.write(b"c;")
            val = cap.readline()
            raw = clean_val(val)
            capacitance = convert_to_cap(raw, offset)
            data_array.append([trial, voltage, (trial)*wait_time, raw, capacitance])
    return data_array

def clean_val(val):
    # print("cleaning values...")
    char_list = list(str(val))
    # print(char_list)
    for character in list(str(val)):
        if not character.isdigit():
            char_list.remove(character)
    # print(char_list)
    val = int("".join(char_list))
    # print(val)
    # print("clean")
    return val

def convert_to_cap(datapoint, offset):
    datapoint = (datapoint)*(4.8828125e-7) - 4.096 + (offset - 128)*(.148)
    # (.3013)
    # (.1328125)
    return datapoint

def save_to_csv(data, filename):
    data_array = np.asarray(data)
    np.savetxt(filename, data_array, delimiter=",", fmt='%s')
    return

def main(filename, readings_per_batch, max_voltage, trials, wait_time, offset, voltages = False):
    if path.exists(filename):
        proceed = input("file exist, are you sure you want to overwrite? (y/n): ")
        if proceed != "y":
            print("exit:")
            print(proceed)
            exit()
        else:
            print("Proceed:")
            print(proceed)
    cap.write(b"D%d;\n"%offset)
    cap.readline()
    volt.write(b"O;")
    save_to_csv(collect_data(readings_per_batch, max_voltage, trials, wait_time, offset, voltages), filename)
    volt.write(b"V0;")
    volt.write(b"F;")
    return

filename = "csv_files/7-09_thor8_se.csv"
main(filename, readings_per_batch, max_voltage, trials, wait_time, 255, voltages)
