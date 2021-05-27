import numpy as np

def clean_readings(file):
    test_text = str(open(file, "r").read())
    test_text = test_text.replace("\n", "").replace("c", "").split("!")
    if test_text[-1] == '':
        test_text = test_text[:-1]
    test_text = list(map(int, test_text))
    # test_text = [int(n) for n in test_text]
    return test_text

def convert_to_csv(files, starting_sep, increment):
    data = []
    for file in files:
        steps = files.index(file)
        saved_data = clean_readings(file)
        for datapoint in saved_data:
            data.append([starting_sep-increment*steps, datapoint])
    data_array = np.asarray(data)
    np.savetxt("paper_sep_data.csv", data_array, delimiter=",")
    return data_array


files_micro = ["micrometer_data1/better1.0", "micrometer_data1/better2.0",
    "micrometer_data1/better3.0", "micrometer_data1/better4.0",
    "micrometer_data1/better5.0", "micrometer_data1/better6.0",
    "micrometer_data1/better7.0", "micrometer_data1/better8.0",
    "micrometer_data1/better9.0", "micrometer_data1/better10.0",
    "micrometer_data1/better11.0", "micrometer_data1/better12.0",
    "micrometer_data1/better13.0", "micrometer_data1/better14.0",
    "micrometer_data1/better15.0"]

files_paper = ["paper_separation_data/paper10.0",
    "paper_separation_data/paper11.0", "paper_separation_data/paper12.0",
    "paper_separation_data/paper13.0", "paper_separation_data/paper14.0",
    "paper_separation_data/paper15.0", "paper_separation_data/paper16.0",
    "paper_separation_data/paper17.0", "paper_separation_data/paper18.0",
    "paper_separation_data/paper19.0", "paper_separation_data/paper20.0"]

print(convert_to_csv(files_paper, 10, -1))
