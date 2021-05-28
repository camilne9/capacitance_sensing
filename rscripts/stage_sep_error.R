library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
micrometer_stage_sep1 <- read_csv("../csv_files/micrometerstage1.csv")
micrometer_stage_sep2 <- read_csv("../csv_files/micrometerstage2.csv")
micrometer_stage_sep3 <- read_csv("../csv_files/micrometerstage3.csv")
micrometer_stage_sep4 <- read_csv("../csv_files/micrometerstage4.csv")

# I store the data for each segment into a cleaned tibble
sep1 <- micrometer_stage_sep1 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(reciprocal = 1/distance)

sep2 <- micrometer_stage_sep2 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(reciprocal = 1/distance)

sep3 <- micrometer_stage_sep3 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(reciprocal = 1/distance)

sep4 <- micrometer_stage_sep4 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(reciprocal = 1/distance)

# I plot the reciprocals to see if they indeed appear linear 
ggplot(sep1, aes(reciprocal, avg_cap))+geom_point()
ggplot(sep2, aes(reciprocal, avg_cap))+geom_point()
ggplot(sep3, aes(reciprocal, avg_cap))+geom_point()
ggplot(sep4, aes(reciprocal, avg_cap))+geom_point()

#I find the slope and intercept of a trend line for capacitance vs 1/distance
slope1 <- coef(lm(avg_cap~reciprocal, sep1))[["reciprocal"]]
intercept1 <- coef(lm(avg_cap~reciprocal, sep1))[["(Intercept)"]]

slope2 <- coef(lm(avg_cap~reciprocal, sep2))[["reciprocal"]]
intercept2 <- coef(lm(avg_cap~reciprocal, sep2))[["(Intercept)"]]

slope3 <- coef(lm(avg_cap~reciprocal, sep3))[["reciprocal"]]
intercept3 <- coef(lm(avg_cap~reciprocal, sep3))[["(Intercept)"]]

slope4 <- coef(lm(avg_cap~reciprocal, sep4))[["reciprocal"]]
intercept4 <- coef(lm(avg_cap~reciprocal, sep4))[["(Intercept)"]]

# I over-write the data tibble with another tibble that also has the 
# value from the regression line and the error in microns
sep1 <- sep1 %>% 
  mutate(theory_value = (avg_cap-intercept1)/slope1) %>% 
  mutate(error = abs(1/reciprocal-1/theory_value))

sep2 <- sep2 %>% 
  mutate(theory_value = (avg_cap-intercept2)/slope2) %>% 
  mutate(error = abs(1/reciprocal-1/theory_value))

sep3 <- sep3 %>% 
  mutate(theory_value = (avg_cap-intercept3)/slope3) %>% 
  mutate(error = abs(1/reciprocal-1/theory_value))

sep4 <- sep4 %>% 
  mutate(theory_value = (avg_cap-intercept4)/slope4) %>% 
  mutate(error = 1/reciprocal-1/theory_value)
  mutate(error = abs(1/reciprocal-1/theory_value))

# I output the average error in each of the cases:
sep1 %>%  summarize(avg_error = mean(error), stdev = sd(error))
sep2 %>%  summarize(avg_error = mean(error), stdev = sd(error))
sep3 %>%  summarize(avg_error = mean(error), stdev = sd(error))
sep4 %>%  summarize(avg_error = mean(error), stdev = sd(error))
  