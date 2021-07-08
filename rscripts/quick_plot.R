library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/7-08_thor1_se.csv",
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
  ggplot(aes(10*(batch-1), avg_cap))+
  geom_point()+
  # geom_errorbar(aes(ymin=(avg_cap-2*stdev), ymax=(avg_cap+2*stdev)), width=.2)+
  labs(title = "Shearing and Calibration of New Thorlabs Stack",
       subtitle ="New Thorlabs Stack, Single-Ended, D255",
       caption ="Data File: 7-08_thor1_se.csv",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  # geom_smooth(method = "lm")+
  theme_minimal()

coef(lm(theory_sep~distance, temp))[["distance"]]




