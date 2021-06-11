library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
general_error <- read_csv("../csv_files/drift_test1_6-11.csv", 
                          col_names = c("distance", "capacitance", "batch"))
                          
general_error <- general_error %>% 
  mutate(distance = distance) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
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

