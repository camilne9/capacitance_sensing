library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

ramp1 <- read_csv("../csv_files/7-21_ramp1.csv",
                      col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
    mutate(ramp = "Iteration #1")
ramp2 <- read_csv("../csv_files/7-21_ramp2.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #2")
ramp3 <- read_csv("../csv_files/7-21_ramp3.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #3")
ramp4 <- read_csv("../csv_files/7-21_ramp4.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #4")
ramp5 <- read_csv("../csv_files/7-21_ramp5.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #5")
ramp6 <- read_csv("../csv_files/7-21_ramp6.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #6")
ramp7 <- read_csv("../csv_files/7-21_ramp7.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #7")
ramp8 <- read_csv("../csv_files/7-21_ramp8.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #8")
ramp9 <- read_csv("../csv_files/7-21_ramp9.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance")) %>% 
  mutate(ramp = "Iteration #9")

data <- bind_rows(ramp1, ramp2, ramp3, ramp4, ramp5, ramp6, ramp7, ramp8, ramp9)

data %>% 
  filter(raw > 1000) %>% 
  group_by(batch, ramp) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n(), 
            time = mean(time),
            # Voltage = as.factor(mean(Voltage))) %>%
            Voltage = mean(Voltage)) %>%
  filter(count>1) %>% 
  ggplot(aes(time, avg_cap, color = Voltage))+
  geom_point()+
  labs(title = "Ramping by 0.1 Voltage, Measuring every 5V",
       subtitle ="Single-Ended, D200",
       caption ="Data File: 7-21_ramp[].csv",
       x = "Time (s)",
       y = "Capacitance (pF)")+
  theme_minimal()+
  facet_wrap(~ramp, scales = "free_y")
