library(tidyverse)
library(ggthemes)

setwd("C:/Users/SphoPM/Documents/GitHub/capacitance_sensing/rscripts/")

ep <- 8.85
area <- 547.8436324501871
initial_dist <- 282.4656337947194
ramp_drift <- read_csv("../csv_files/7-30_3mmshear2.csv",
                  col_names = c("batch", "Voltage", "time", "raw", "capacitance"))

clean_ramp_drift <- ramp_drift %>% 
  # filter(batch < 140, batch > 70) %>%
  group_by(batch) %>%
  summarize(avg_cap = mean(capacitance), 
            avg_raw = mean(raw),stdev =sd(capacitance), count = n(), 
            time = mean(time),
            # Voltage = as.factor(mean(Voltage))) %>%
            Voltage = mean(Voltage)) %>%
  filter(count>1) %>% 
  ungroup() 

reference_cap <- clean_ramp_drift %>% 
  filter(batch == 0) %>% 
  pull(avg_cap)

null_slope <- coef(lm(avg_cap~time, 
                      subset(clean_ramp_drift, Voltage == 0)))[["time"]]
max_slope <- coef(lm(avg_cap~time, 
                     subset(clean_ramp_drift, Voltage == 175)))[["time"]]

clean_ramp_drift <- clean_ramp_drift %>% 
  mutate(drift_adjusted_capacitance = avg_cap-null_slope*time) %>% 
  mutate(cap_change = avg_cap-reference_cap) %>% 
  mutate(drift_cap_change = drift_adjusted_capacitance-reference_cap) %>% 
  mutate(distance = initial_dist/(1+ cap_change*initial_dist/(ep*area))) %>% 
  mutate(drift_adjusted_distance = initial_dist/(1+ drift_cap_change*initial_dist/(ep*area)))
# %>% 
#   filter(Voltage %in% c(0, 175))

clean_ramp_drift %>% 
  mutate(drift_adjusted_capacitance = avg_cap-null_slope*time) %>% 
  ggplot(aes(time, distance, color = Voltage))+
  geom_point()+
  labs(title = "Repeated Ramping on Homemade 5mm Stack",
       subtitle ="Single-Ended, D255",
       caption ="Data File: 7-26_5mm_ramp2.csv",
       x = "Time (s)",
       y = "Capacitance (pF)")+
       # y = "Separation Distance (microns)")+
  theme_minimal()

