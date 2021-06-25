library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
drift_data <- read_csv("../csv_files/drift_test1_6-21.csv", 
                          col_names = c("distance", "capacitance", "batch"))
# max_voltage_batch <- c(2,4,6,8,10,12,14)
max_voltage_batch <- c(4:6, 10:12, 16:18, 22:24, 28:30)
# max_voltage_batch = c(13:18, 25:30, 37:42, 49:54)
# max_voltage_batch = c(7:9, 13:15, 19:21)
# max_voltage_batch = c(55:57, 61:63, 67:69)
# max_voltage_batch = c(7:12, 19:24, 31:36, 43:48)
# max_voltage_batch <- c(9:12, 17:20)
# max_voltage_batch <- c(7:9, 13:15, 19:21, 25:27, 31:33, 37:39)
max_voltage <- 175
time_interval <- 30

clean_drift_data <- drift_data %>% 
  group_by(distance, batch) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  # filter(batch < 25) %>% 
  ungroup() %>% 
  mutate(Voltage = as.factor(max_voltage*(batch %in% max_voltage_batch))) %>% 
  mutate(time = time_interval*(batch-1)) %>% 
  select(batch, time, avg_cap, Voltage)

null_slope <- coef(lm(avg_cap~time, 
                      subset(clean_drift_data, Voltage == 0)))[["time"]]
max_slope <- coef(lm(avg_cap~time, 
                      subset(clean_drift_data, Voltage == max_voltage)))[["time"]]

(null_slope-max_slope)/null_slope*100

clean_drift_data %>% 
  mutate(drift_adjusted_capacitance = avg_cap-null_slope*time) %>% 
  ggplot(aes(time, avg_cap, color = Voltage))+
  geom_point()+
  labs(title = "Testing Stray Capacitance by Varying Voltage with Piezo Removed",
       subtitle ="Alternating 0V and 175V, Single-Ended Measurements, Unmoving Electrodes",
       caption = "Data File: drift_test1_6-21.csv \n
       175V: 4:6, 10:12, 16:18, 22:24, 28:30",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  # geom_smooth(method = "lm")+
  theme_minimal()

