library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

ramp_drift <- read_csv("../csv_files/7-22_ramp1_3x.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance"))

clean_ramp_drift <- ramp_drift %>% 
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n(), 
            time = mean(time),
            # Voltage = as.factor(mean(Voltage))) %>%
            Voltage = mean(Voltage)) %>%
  filter(count>1) %>% 
  ungroup() 

null_slope <- coef(lm(avg_cap~time, 
                      subset(clean_ramp_drift, Voltage == 0)))[["time"]]
max_slope <- coef(lm(avg_cap~time, 
                     subset(clean_ramp_drift, Voltage == 175)))[["time"]]

clean_ramp_drift %>% 
  mutate(drift_adjusted_capacitance = avg_cap-null_slope*time) %>% 
  ggplot(aes(time, drift_adjusted_capacitance, color = Voltage))+
  geom_point()+
  labs(title = "Drift Adjusted Repeated Ramping on new Thorlabs Stack",
       subtitle ="Single-Ended, D200",
       caption ="Data File: 7-21_ramp_3x.csv",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  theme_minimal()
