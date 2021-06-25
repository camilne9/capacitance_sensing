library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/6-22_drift7_se.csv",
                       col_names = c("distance", "raw", "batch", "capacitance"))

quick_data %>% 
  group_by(distance, batch) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  # mutate(voltage = as.factor(ifelse(7>batch, "0V", 
  #                                   ifelse(batch>12, "0V", "175V")))) %>% 
  # mutate(voltage = as.factor(((batch-1)%%2)*175)) %>% 
  # ggplot(aes(distance, avg_cap/10^6, color = voltage))+
  ggplot(aes(distance, avg_raw))+
  geom_point()+
  # geom_errorbar(aes(ymin=(avg_cap-2*stdev), ymax=(avg_cap+2*stdev)), width=.2)+
  labs(title = "Drift over Time",
       subtitle ="No Voltage, Wires Disconnected, No Piezo, D165",
       caption ="Data File: 6-22_drift7_se.csv",
       x = "Time (s)",
       y = "Raw Sensor Reading")+
 # geom_smooth(method = "lm")+
  theme_minimal()

