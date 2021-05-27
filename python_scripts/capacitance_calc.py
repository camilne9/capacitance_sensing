import string
import statistics

def capacitance_calc(area, distance):
    epsilon = 8.85*10^(-12)
    return epsilon*area/distance

def clean_readings():
    test_text = str(open("screenlog.0", "r").read())
    test_text = test_text.replace("\n", "").replace("c", "").split("!")
    if test_text[-1] == '':
        test_text = test_text[:-1]
    test_text = list(map(int, test_text))
    # test_text = [int(n) for n in test_text]
    return test_text

def avg_cap(caps):
    return sum(caps)/len(caps)


print(avg_cap(clean_readings()))
print(statistics.pstdev(clean_readings()))
