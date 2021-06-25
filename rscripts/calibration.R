library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

five_pf <- read_csv("../csv_files/6-22_calibration1_5pf.csv",
                       col_names = c("distance", "raw", 
                                     "batch", "capacitance"))
three_pf <- read_csv("../csv_files/6-22_calibration1_3pf.csv",
                    col_names = c("distance", "raw", 
                                  "batch", "capacitance"))
two_pf <- read_csv("../csv_files/6-22_calibration2_2pf.csv",
                    col_names = c("distance", "raw", 
                                  "batch", "capacitance"))

temp <- left_join(five_pf, three_pf, by = "distance", suffix = c("_5pf", "_3pf")) %>% 
  left_join(two_pf, by = "distance") %>% 
  mutate(offset = distance, raw_2pf = raw, capacitance_2pf = capacitance) %>% 
  select(offset, raw_5pf, raw_3pf, raw_2pf, capacitance_2pf, 
         capacitance_3pf, capacitance_5pf) %>% 
  group_by(offset) %>% 
  summarize(raw5 = mean(raw_5pf), raw3 = mean(raw_3pf), raw2 = mean(raw_2pf),
         cap5 = mean(capacitance_5pf), cap3 = mean(capacitance_3pf),
         cap2 = mean(capacitance_2pf), count = n()) %>% 
  ungroup() %>% 
  gather(rawpf, raw, c("raw5", "raw3", "raw2")) %>% 
  gather(cappf, cap, c("cap5", "cap3", "cap2")) %>% 
  mutate(pf = str_replace(rawpf, "raw5", "5"), 
         pf = str_replace(pf, "raw3", "3"),
         pf = str_replace(pf, "raw2", "2")) %>%
  mutate(pf2 = str_replace(cappf, "cap5", "5"), 
         pf2 = str_replace(pf2, "cap3", "3"),
         pf2 = str_replace(pf2, "cap2", "2")) %>%
  select(-rawpf ,-cappf, -count) %>% 
  filter(pf2 == pf)

temp <- ggplot(aes(offset, cap, color = pf))+geom_point()

slope5 <- coef(lm(raw~offset, 
                  temp %>% filter(pf == 5, offset > 138)))[["offset"]]
slope3 <- coef(lm(raw~offset, temp %>% filter(pf == 3)))[["offset"]]
slope2 <- coef(lm(raw~offset, temp %>% filter(pf == 2)))[["offset"]]

