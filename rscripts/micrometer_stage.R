library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

micrometer_stage_sep1 <- read_csv("../csv_files/micrometerstage1.csv")
micrometer_stage_sep2 <- read_csv("../csv_files/micrometerstage2.csv")

micrometer_stage_sep1 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Capacitance by Separation measured by Micrometer Stage",
       #subtitle = "Offset D128, Overlapping Area 5e-4 m^2",
       x = "Separation Distance (micrometers)",
       y = "Capacitance (pF)")+
   # geom_point(aes(x= distance,
   #               y= 8.85*5*10^(-4)/(distance/(10^6))+8.7092,
   #               color = "red"), show.legend = FALSE)+
  geom_smooth(method = "lm")+
  theme_minimal()

trendline_sep1 <- lm(avg_cap/10^6~distance, data =
                       micrometer_stage_sep1 %>% 
                       mutate(distance = separation) %>% 
                       group_by(distance) %>%
                       summarize(avg_cap = mean(capacitance), count = n()) %>%
                       filter(count>1) %>% 
                       ungroup())
summary(trendline_sep1)
trendline_sep1

slope_sep <- -0.0009401  
intercept_sep <- 13.9367222

sep1 <- micrometer_stage_sep1 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/(10^6), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>% 
  mutate(theoretical_sep = (avg_cap-intercept_sep)/slope_sep) %>% 
  select(distance, theoretical_sep, avg_cap) %>% 
  mutate(error = abs(distance - theoretical_sep))

sep1 %>% 
  summarize(avg_error = mean(error), stdev = sd(error))
