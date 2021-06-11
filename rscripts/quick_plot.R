library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/drift_correction1_6-11.csv", 
                                   col_names = c("distance", "capacitance", "batch"))

quick_data %>% 
  group_by(distance, batch) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  # mutate(voltage = as.factor(ifelse(7>batch, "0V", 
  #                                   ifelse(batch>12, "0V", "175V")))) %>% 
  # mutate(voltage = as.factor(((batch-1)%%2)*175)) %>% 
  # ggplot(aes(distance, avg_cap/10^6, color = voltage))+
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Effect of Time on Capacitance",
       subtitle ="No Voltage",
       x = "Time (s)",
       y = "Capacitance (pF)")+
 # geom_smooth(method = "lm")+
  theme_minimal()

