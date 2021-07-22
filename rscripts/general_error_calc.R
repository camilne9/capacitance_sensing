library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
general_error <- read_csv("../csv_files/7-16_cal9.csv",
                          col_names = c("batch", "Voltage", "time", "raw", "capacitance"))
                          
general_error <- general_error %>% 
  mutate(distance = 5*batch) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(reciprocal = 1/distance)

#For Reciprocal
slope <- coef(lm(avg_cap~reciprocal, general_error))[["reciprocal"]]
intercept <- coef(lm(avg_cap~reciprocal, general_error))[["(Intercept)"]]

general_error %>% 
  mutate(theory_value = (avg_cap-intercept)/slope) %>% 
  mutate(error = abs(1/reciprocal-1/theory_value)) %>% 
  summarize(avg_error = mean(error), stdev = sd(error))

#For linear
slope <- coef(lm(avg_cap~distance, general_error))[["distance"]]
intercept <- coef(lm(avg_cap~distance, general_error))[["(Intercept)"]]

general_error %>% 
  mutate(theory_value = (avg_cap-intercept)/slope) %>% 
  mutate(error = abs(distance-theory_value)) %>% 
  summarize(avg_error = mean(error), stdev = sd(error))

