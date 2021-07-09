library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/7-09_thor1_se.csv",
                       col_names = c("distance", "raw", "batch", "capacitance"))
temp_data <- read_csv("../csv_files/7-09_thor1_se.csv",
                       col_names = c("batch", "Voltage", "time", "raw", "capacitance"))
temp_data %>% 
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n(), 
            Voltage = as.factor(mean(Voltage))) %>%
  filter(count>1) %>% 
  ungroup() %>%
# the following 3 lines apply if shearing and calibrating 
  # mutate(time = distance) %>%
  # mutate(distance = 10*floor(distance/40)) %>%
  # mutate(Voltage = as.factor(175*((batch-1)%%2))) %>%

  # mutate(voltage = as.factor(((batch-1)%%2)*175)) %>% 
  # ggplot(aes(distance, avg_cap/10^6, color = voltage))+
  ggplot(aes(batch, avg_cap, color = Voltage))+
  geom_point()+
  # geom_errorbar(aes(ymin=(avg_cap-2*stdev), ymax=(avg_cap+2*stdev)), width=.2)+
  labs(title = "Shearing and Calibration of Thorlabs Stack",
       subtitle ="Shearing Closer, Single-Ended, D128",
       caption ="Data File: 7-08_thor6_se.csv",
       x = "Displacement (microns)",
       y = "Capacitance (pF)")+
  # geom_smooth(method = "lm")+
  theme_minimal()

coef(lm(theory_sep~distance, temp))[["distance"]]




