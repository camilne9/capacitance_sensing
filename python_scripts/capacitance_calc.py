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

def theoretical_slope(height, separation, width = None, height_units="mm", separation_units = "microns", width_units = "mm"):
    epsilon = 8.85 # with units of pF/m
    if width is None:
        slope = epsilon*height/separation
        scale_factor = convert_to_meters(height_units)/convert_to_microns(separation_units)
        slope = slope*scale_factor
        #if there's no width, then the width is the changing parameter
    else:
        slope = epsilon*height*width/(separation**2)
        scale_factor = convert_to_meters(height_units)*convert_to_meters(width_units)/ \
            (convert_to_microns(separation_units)*convert_to_meters(separation_units))
        slope = slope*scale_factor
        # if there is a width, then we're changing the separation distance
    return slope
    # the returned value is the slope in pF/micron

def convert_to_meters(input_unit):
    unit = ["mm", "microns", "m", "in"]
    meter_factors = [10**(-3), 10**(-6), 1, 0.0254] #these conversion factors convert to m
    return meter_factors[unit.index(input_unit)]

def convert_to_microns(input_unit):
    unit = ["mm", "microns", "m", "in"]
    micron_factors = [10**(3), 1, 10**(6), 0.0254*10**(6)] #these conversion factors convert to m
    return micron_factors[unit.index(input_unit)]

# print(avg_cap(clean_readings()))
# print(statistics.pstdev(clean_readings()))
print(f"diff, area: {theoretical_slope(15, 100)}")
print(f"sing, area: {theoretical_slope(15, 200)}")
print(f"diff, sep: {theoretical_slope(15, 150, 15)}")
print(f"sing, sep: {theoretical_slope(15, 150, 10)}")
