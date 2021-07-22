import serial
import math
import time
import csv
import numpy as np
import os.path
from os import path

class Collect_Data():
    """
    A class for data collection
    """

    def __init__(self, filename, readings_per_batch, max_voltage, trials, wait_time, pause, offset, voltages = False, ramp = None):
        print("init collect")
        # create objects for the capacitance sensor and voltage source. The path
        # name is generally device specific.
        self.cap = serial.Serial("/dev/tty.usbserial-D30A2ZWX" , 9600)
        self.volt = serial.Serial("/dev/tty.usbmodem14101" , 9600)

        # self.data_array = ["batch", "voltage", "time", "raw", "capacitance"]
        self.data_array = []

        # Safeguard to avoid accidentally overwriting files
        if path.exists(filename):
            proceed = input("file exist, are you sure you want to overwrite? (y/n): ")
            if proceed != "y":
                print("Exiting.")
                self.volt.write(b"V0;")
                self.volt.write(b"F;")
                exit()
            else:
                print("Proceeding.")
        # Sets capacitance offset, turns on voltage source, and creates timestamp
        self.cap.write(b"D%d;\n"%offset)
        self.cap.readline()
        self.volt.write(b"O;")
        self.create_absolute_timestamp()
        # Collects data and saves it to csv
        self.save_to_csv(self.collect_data(readings_per_batch, max_voltage, trials, wait_time, pause, offset, voltages, ramp), filename)
        # turns off voltage source
        self.volt.write(b"V0;")
        self.volt.write(b"F;")
        return

    def collect_data(self, readings_per_batch, max_voltage, trials, wait_time, pause = False, offset = 255, voltages = False, ramp = None):
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
            print(trial)
            # if we are toggling voltage, we set the voltage based on the parity
            # of the batch number
            if not voltages:
                if trial%2 == 0:
                    print("zero volts")
                    voltage = 0
                    self.volt.write(b"V%d;"%voltage)
                    if pause:
                        input("Press 'enter' when you're ready to proceed")
                else:
                    print("max voltage")
                    voltage = max_voltage
                    if max_voltage is not None:
                        self.volt.write(b"V%d;"%voltage)
            # if we're ramping a set of voltages, we set the voltage according to
            # the set passed
            else:
                final_voltage = voltages[trial]
                if ramp is not None:
                    if trial == 0:
                        current_voltage = 0
                    else:
                        current_voltage = voltages[trial-1]
                    print("about to enter while loop")
                    if trial > trials/2:
                        while current_voltage > final_voltage:
                            current_voltage += -1*ramp
                            print(current_voltage)
                            time.sleep(.01)
                            self.volt.write(b"V%d;"%current_voltage)
                    else:
                        while current_voltage < final_voltage:
                            current_voltage += ramp
                            print(current_voltage)
                            time.sleep(.01)
                            self.volt.write(b"V%d;"%current_voltage)
                voltage = final_voltage
                self.volt.write(b"V%d;"%voltage)

            # brief pause as the stack shears and comes to rest
            print("going to sleep")
            time.sleep(wait_time)
            print("waking up")

            # collects as many measurements as indicated. Cleans the raw reading
            # so that it is just the int and also converts it to a capacitance.
            # All the information is stored in a list of lists
            if voltage is not None:
                for interation in range(readings_per_batch):
                    self.cap.write(b"c;")
                    val = self.cap.readline()
                    raw = self.clean_val(val)
                    capacitance = self.convert_to_cap(raw, offset)
                    self.data_array.append([trial, voltage, time.time() - self.absolute_timestamp, raw, capacitance])
        return self.data_array

    def clean_val(self, val):
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

    def convert_to_cap(self, datapoint, offset):
        """
        Takes raw reading from the AD7746 capacitance sensor and converts it to an
        actual capacitance. (WARNING: conversion is imperfect.) Datapoint and
        offset are each ints.
        """
        datapoint = (datapoint)*(4.8828125e-7) - 4.096 + (offset - 128)*(.148)
        return datapoint

    def save_to_csv(self, data, filename):
        """
        Stores the collected data (the "data" argument which takes a list of lists)
        in a csv file whose name is given by the str argument "filename".
        """
        self.data_array = np.asarray(data)
        np.savetxt(filename, self.data_array, delimiter=",", fmt='%s')
        return

    def create_absolute_timestamp(self):
        """
        Gets current timestamp to allow the time variable to be measured in
        seconds relative to this starting point
        """
        self.absolute_timestamp = time.time()


# Tunable constants
readings_per_batch = 100
max_voltage = None
trials = 20
wait_time = .5
offset = 128
voltages = [0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25,
            0, 25, 50, 75, 100, 125, 150, 175,
            150, 125, 100, 75, 50, 25]
            # 0, 25, 50, 75, 100, 125, 150, 175,
            # 150, 125, 100, 75, 50, 25, 0]
# n = 5
# m = 35
# voltages = list([0]).append(list(range(0, (m+1)*n, n)[1:]))
voltages1 = [n for n in range(0, 176) if n % 5 == 0]
voltages1b = [n for n in range(1, 176) if n % 5 == 0]
voltages2 = [175-n for n in range(1, 176) if n % 5 == 0]
voltages = voltages1 + voltages2 + voltages1b + voltages2 + voltages1b + voltages2
# + voltages1b + voltages2 + voltages1b + voltages2
ramp = .1
filename = "csv_files/7-22_ramp1_3x.csv"

# def main(filename, readings_per_batch, max_voltage, trials, wait_time,
#             pause, offset, voltages=False):
#         print("here1")
#         Collect_Data(filename, readings_per_batch, max_voltage, trials,
#                 wait_time, pause, offset, voltages)
#
# main(filename=filename, readings_per_batch=readings_per_batch,
#         max_voltage=max_voltage, trials=trials, wait_time=wait_time,
#         pause=False, offset=225, voltages=False)

if __name__ == "__main__":
    print("inside if (collect)")
    Collect_Data(filename, readings_per_batch, max_voltage, trials,
                   wait_time, pause = False, offset=200, voltages = voltages, ramp = ramp)
