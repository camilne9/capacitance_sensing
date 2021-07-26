library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/7-09_cal1_se.csv",
                       col_names = c("distance", "raw", "batch", "capacitance"))
temp_data <- read_csv("../csv_files/7-26_cal1.csv",
                       col_names = c("batch", "Voltage", "time", "raw", "capacitance"))
temp_data %>% 
  filter(raw > 1000) %>% 
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n(), 
            time = mean(time),
            Voltage = as.factor(mean(Voltage))) %>%
            # Voltage = mean(Voltage)) %>%
  filter(count>1) %>% 
  ungroup() %>%
# the following 3 lines apply if shearing and calibrating 
  # mutate(time = distance) %>%
  # mutate(distance = 10*floor(distance/40)) %>%
  # mutate(Voltage = as.factor(175*((batch-1)%%2))) %>%

  # mutate(voltage = as.factor(((batch-1)%%2)*175)) %>% 
  # ggplot(aes(distance, avg_cap/10^6, color = voltage))+
  ggplot(aes(5*batch, avg_cap, color = Voltage))+
  geom_point()+
  # geom_errorbar(aes(ymin=(avg_cap-2*stdev), ymax=(avg_cap+2*stdev)), width=.2)+
  labs(title = "Shearing and Calibrating on 5mm Stack",
       subtitle ="Single-Ended, D220",
       caption ="Data File: 7-23_cal5.csv",
       x = "Displacement from Initial Separation (micron)",
       y = "Capacitance (pF)")+
  # geom_smooth(method = "lm")+
  theme_minimal()

coef(lm(theory_sep~distance, temp))[["distance"]]




