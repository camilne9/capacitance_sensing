# This is a place to store old version of the fix_csv function
# of the fix_csv.py script. The purpose of this file is to allow for the
# modularity of that function without losing a record of the changes that
# were made in case these changes must be reconsidered or reverted

# The following function was used to correct offset_test1_6-17.csv
# During data collection I accidentally took two batches of data at the same
# offset which were wrongly interpretted as being different offsets. This
# functions corrects the dataset to accurately assign the batch number
def fix_csv(data_array):
    print("fix")
    for index in range(len(data_array)):
        if float(data_array[index][2]) >= 17:
             data_array[index][2] = float(data_array[index][2])-1
    return data_array

# Converting raw data into capacitance values
def fix_csv(data_array):
    print("fix")
    for index in range(len(data_array)):
        data_array[index][1] = raw_to_cap(float(data_array[index][1]), 128)
    return data_array
