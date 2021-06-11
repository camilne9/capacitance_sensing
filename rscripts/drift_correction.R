library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

# I read in the data
drift_data <- read_csv("../csv_files/drift_correction1_6-11.csv", 
                          col_names = c("distance", "capacitance", "batch"))
max_voltage_batch <- c(19:27, 37:45)
max_voltage <- 175
time_interval <- 20

clean_drift_data <- drift_data %>% 
  group_by(distance, batch) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
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
  labs(title = "Effect of Voltage on Capacitance",
       subtitle ="Correcting for Drift, Alternating 0V and 175V",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  geom_smooth(method = "lm")+
  theme_minimal()
