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

# data_array = ["batch", "voltage", "time", "raw", "capacitance"]
data_array = []

def collect_data(readings_per_batch, max_voltage, trials, wait_time, pause = False, offset = 255, voltages = False):
    """
    "readings_per_batch" is an int indicating how many distinct capacitance
        measurements are taken with each configuration
    "max_voltage" is an int from 0 to 175 indicating the largest voltage
        passed to induce the shearing
    "trials" is an int inidcating how many batches are to be taken. This
        variable is overridden (and therefore meaningless) if the "voltages"
        variable is not set to False.
    "wait_time" is a float that decides how long of a time gap between setting
        the voltage to max and when collection starts. This number can be quite
        small unless there's strong reason against it
    "pause" is an boolean variable deciding if the script proceeds
        automatically or whether it pauses. If moving the electrode positions
        between batches, set this to True to have time for that adjustment. If
        leaving the system as it is, leave as False (default) to just have the
        script simply run through
    "offset" is an int from 128 to 255. This sets the offset of the
        capacitance sensor. A larger offset allows a closer separation distance
    "voltages" controls whether you ramp a set of voltages or if you toggle
        between a min and a max voltage. If voltages is 'False' (default) then
        the voltage will toggle. If you pass a list, then the voltage will be
        set to each entry of the list in succession.
    """
    # overrides trials number if we're ramping voltages
    if voltages:
        trials = len(voltages)
    # we loop through the data collection process as many times as we require
    # for the given number of trials
    for trial in range(trials):
        # if we are toggling voltage, we set the voltage based on the parity
        # of the batch number
        if not voltages:
            if trial%2 == 0:
                print("zero volts")
                voltage = 0
                volt.write(b"V%d;"%voltage)
                if pause:
                    input("Press 'enter' when you're ready to proceed")
            else:
                print("max voltage")
                voltage = max_voltage
                volt.write(b"V%d;"%voltage)
        # if we're ramping a set of voltages, we set the voltage according to
        # the set passed
        else:
            voltage = voltages[trial]
            print(voltage)
            volt.write(b"V%d;"%voltage)

        # brief pause as the stack shears and comes to rest
        print("going to sleep")
        time.sleep(wait_time)
        print("waking up")

        # collects as many measurements as indicated. Cleans the raw reading
        # so that it is just the int and also converts it to a capacitance.
        # All the information is stored in a list of lists
        for interation in range(readings_per_batch):
            cap.write(b"c;")
            val = cap.readline()
            raw = clean_val(val)
            capacitance = convert_to_cap(raw, offset)
            data_array.append([trial, voltage, time.time() - absolute_timestamp, raw, capacitance])
    return data_array

def clean_val(val):
    """
    Parses readings from the capacitance sensor to isolate the actual
    capacitance information.
    """
    char_list = list(str(val))
    for character in list(str(val)):
        if not character.isdigit():
            char_list.remove(character)
    val = int("".join(char_list))
    return val

def convert_to_cap(datapoint, offset):
    """
    Takes raw reading from the AD7746 capacitance sensor and converts it to an
    actual capacitance. (WARNING: conversion is imperfect.) Datapoint and
    offset are each ints.
    """
    datapoint = (datapoint)*(4.8828125e-7) - 4.096 + (offset - 128)*(.148)
    return datapoint

def save_to_csv(data, filename):
    """
    Stores the collected data (the "data" argument which takes a list of lists)
    in a csv file whose name is given by the str argument "filename".
    """
    data_array = np.asarray(data)
    np.savetxt(filename, data_array, delimiter=",", fmt='%s')
    return

def create_absolute_timestamp():
    """
    Gets current timestamp to allow the time variable to be measured in
    seconds relative to this starting point
    """
    global absolute_timestamp
    absolute_timestamp = time.time()

def main(filename, readings_per_batch, max_voltage, trials, wait_time, pause, offset, voltages = False):
    # Safeguard to avoid accidentally overwriting files
    if path.exists(filename):
        proceed = input("file exist, are you sure you want to overwrite? (y/n): ")
        if proceed != "y":
            print("Exiting.")
            volt.write(b"V0;")
            volt.write(b"F;")
            exit()
        else:
            print("Proceeding.")
            print(proceed)
    # Sets capacitance offset, turns on voltage source, and creates timestamp
    cap.write(b"D%d;\n"%offset)
    cap.readline()
    volt.write(b"O;")
    create_absolute_timestamp()
    # Collects data and saves it to csv
    save_to_csv(collect_data(readings_per_batch, max_voltage, trials, wait_time, pause, offset, voltages), filename)
    # turns off voltage source
    volt.write(b"V0;")
    volt.write(b"F;")
    return


# Tunable constants
readings_per_batch = 100
max_voltage = 175
trials = 20
wait_time = 1
offset = 128
voltages = [0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25,
            0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25]
            # 0, 25, 50, 75, 100, 125, 150, 175,
            # 150, 125, 100, 75, 50, 25, 0]
filename = "csv_files/7-13_5m9.csv"

main(filename=filename, readings_per_batch=readings_per_batch,
        max_voltage=max_voltage, trials=trials, wait_time=wait_time,
        pause=True, offset=225, voltages=False)
