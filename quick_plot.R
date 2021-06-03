library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

quick_data <- read_csv("../csv_files/differential_mode3.csv", 
                                   col_names = c("distance", "capacitance"))

quick_data %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Quick Plot",
       x = "Distance (Micrometers)",
       y = "Capacitance (pF)")+
 # geom_smooth(method = "lm")+
  theme_minimal()
