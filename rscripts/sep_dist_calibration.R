library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

ep <- 8.85 #pF/m
area <- 600 #microns*m
step_size <- 10 #microns
# I read in the data
cal_data <- read_csv("../csv_files/7-09_cal1_se.csv",
                       col_names = c("distance", "raw", "batch", "capacitance"))
cal_data <- read_csv("../csv_files/7-09_cal1_se.csv",
                      col_names = c("batch", "Voltage", "time", "raw", "capacitance"))
clean_cal_data <- cal_data %>% 
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), stdev =sd(capacitance), count = n()) %>%
  filter(count>1) %>% 
  # filter(batch < 6) %>%
  ungroup() %>% 
  mutate(sep = step_size*(batch-1)) %>% 
  select(batch, sep, avg_cap, stdev) %>% 
  mutate(theory_sep_per_area = ep/avg_cap) %>% 
  mutate(sep = 10*floor(sep/20)) %>% 
  mutate(Voltage = as.factor(175*((batch-1)%%2))) %>% 
  filter(Voltage == 175)

theory_area <- 1/coef(lm(theory_sep_per_area~sep, clean_cal_data))[["sep"]]
theory_area
separation_dist <- coef(lm(theory_area*theory_sep_per_area~sep, 
                           clean_cal_data))[["(Intercept)"]]
separation_dist

expected_shear <- 3 #positive moves the plates closer
expected_jump <- ep*theory_area*(1/(separation_dist-expected_shear) - 
                                   1/separation_dist)
expected_jump

  
# the below code is obsolete
slope <- coef(lm(avg_cap~sep, clean_cal_data))[["sep"]]

separation_dist <- sqrt(abs(-ep*theory_area/slope)) #sqrt((pF/m)*(microns*m)/(pF/micron)) = microns
separation_dist


# The code below is only relevant if taking data that changes 
# the overlapping area

# height <- .031 #meters
# area_slope <- coef(lm(avg_cap~sep, clean_cal_data))[["sep"]]
# area_separation_dist <- ep*height/area_slope
# area_separation_dist








