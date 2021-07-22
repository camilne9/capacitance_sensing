library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
drift_data <- read_csv("../csv_files/7-13_5m3_se.csv",
                       col_names = c("distance", "raw", "batch", "capacitance"))
drift_data <- read_csv("../csv_files/7-21_ramp_3x.csv",
                      col_names = c("batch", "Voltage", "time", "raw", "capacitance"))
max_voltage_batch <- c(2,4,6,8,10,12,14,16,18,20,22)
# max_voltage_batch <- c(4:6, 10:12, 16:18, 22:24, 28:30, 34:36, 40:42, 46:48)
# max_voltage_batch <- c(4:6, 10:12, 16:21, 25:27)
# max_voltage_batch <- c(4:6, 13:18, 22:24, 28:30, 34:36)
# max_voltage_batch = c(13:18, 25:30, 37:42, 49:54)
# max_voltage_batch = c(7:9, 13:15, 19:21)
# max_voltage_batch = c(55:57, 61:63, 67:69)
# max_voltage_batch = c(7:12, 19:24, 31:36, 43:48)
# max_voltage_batch <- c(9:12, 17:20)
# max_voltage_batch <- c(7:9, 13:15, 19:21, 25:27, 31:33, 37:39)
max_voltage <- 175
time_interval <- 20

clean_drift_data <- drift_data %>% 
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), stdev =sd(capacitance), count = n()) %>%
  # summarize(avg_cap = mean(capacitance), count = n(), Voltage = mean(Voltage)) %>%
  filter(count>1) %>% 
  # filter(distance <=1000) %>% 
  # filter(batch < 25) %>% 
  ungroup() %>% 
  mutate(Voltage = as.factor(max_voltage*(batch %in% max_voltage_batch))) %>% 
  # mutate(Voltage = as.factor(Voltage)) %>% 
  mutate(time = time_interval*(batch-1)) %>% 
  select(batch, time, avg_cap, Voltage, stdev)

null_slope <- coef(lm(avg_cap~time, 
                      subset(clean_drift_data, Voltage == 0)))[["time"]]
max_slope <- coef(lm(avg_cap~time, 
                      subset(clean_drift_data, Voltage == max_voltage)))[["time"]]

(null_slope-max_slope)/null_slope*100

clean_drift_data %>% 
  mutate(drift_adjusted_capacitance = avg_cap-null_slope*time) %>% 
  ggplot(aes(time, drift_adjusted_capacitance, color = Voltage))+
  geom_point()+
  # geom_errorbar(aes(ymin=(avg_cap-2*stdev), ymax=(avg_cap+2*stdev)), width=.2)+
  labs(title = "Capacitance by Varying Voltage",
       subtitle ="Alternating 0V and 175V, Single-Ended, New Thorlabs Stack, D255",
       caption = "Data File: 7-08_thor4_se.csv \n
       175V: 4:6, 10:12, 16:18, 22:24, 28:30, 34:36, 40:42, 46:48",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  # geom_smooth(method = "lm")+
  theme_minimal()

