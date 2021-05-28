library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance/capacitance_sensing/rscripts")

micrometer_stage_area1 <- read_csv("../csv_files/area1.csv", col_names = c("separation", "capacitance"))
micrometer_stage_area2 <- read_csv("../csv_files/area2.csv", col_names = c("separation", "capacitance"))
micrometer_stage_area3 <- read_csv("../csv_files/area3.csv", col_names = c("separation", "capacitance"))

micrometer_stage_area1 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  mutate(distance = distance - 2800+28000) %>% 
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Capacitance by Overlapping Width measured by Micrometer Stage",
       #subtitle = "Offset D128, Overlapping Area 5e-4 m^2",
       x = "Overlapping Width (micrometers)",
       y = "Capacitance (pF)")+
  # geom_point(aes(x= distance,
  #               y= 8.85*5*10^(-4)/(distance/(10^6))+8.7092,
  #               color = "red"), show.legend = FALSE)+
  geom_smooth(method = "lm")+
  theme_minimal()

micrometer_stage_area2 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  mutate(distance = distance - 2800+28000) %>% 
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Capacitance by Overlapping Width measured by Micrometer Stage",
       #subtitle = "Offset D128, Overlapping Area 5e-4 m^2",
       x = "Overlapping Width (micrometers)",
       y = "Capacitance (pF)")+
  # geom_point(aes(x= distance,
  #               y= 8.85*5*10^(-4)/(distance/(10^6))+8.7092,
  #               color = "red"), show.legend = FALSE)+
  theme_minimal()


micrometer_stage_area3 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance), count = n()) %>%
  mutate(error = (distance<2300)) %>% 
  mutate(distance = distance-error*(2300-distance)/50*500) %>% 
  mutate(distance = distance - 2800+28000) %>% 
  filter(count>1) %>% 
  ungroup() %>%
  ggplot(aes(distance, avg_cap/10^6))+
  geom_point()+
  labs(title = "Capacitance by Overlapping Width measured by Micrometer Stage",
       #subtitle = "Offset D128, Overlapping Area 5e-4 m^2",
       x = "Overlapping Width (micrometers)",
       y = "Capacitance (pF)")+
  # geom_point(aes(x= distance,
  #               y= 8.85*5*10^(-4)/(distance/(10^6))+8.7092,
  #               color = "red"), show.legend = FALSE)+
  geom_smooth(method = "lm")+
  theme_minimal()

trendline1 <- lm(avg_cap/10^6~distance, data = 
                   micrometer_stage_area1 %>% 
                   mutate(distance = separation) %>% 
                   group_by(distance) %>%
                   summarize(avg_cap = mean(capacitance), count = n()) %>%
                   mutate(error = (distance<2300)) %>% 
                   mutate(distance = distance-error*(2300-distance)/50*500) %>% 
                   mutate(distance = distance - 2800+28000) %>% 
                   filter(count>1) %>% 
                   ungroup())
trendline1

trendline2 <- lm(avg_cap/10^6~distance, data = 
                   micrometer_stage_area2 %>% 
                   mutate(distance = separation) %>% 
                   group_by(distance) %>%
                   summarize(avg_cap = mean(capacitance), count = n()) %>%
                   mutate(error = (distance<2300)) %>% 
                   mutate(distance = distance-error*(2300-distance)/50*500) %>% 
                   mutate(distance = distance - 2800+28000) %>% 
                   filter(count>1) %>% 
                   ungroup())
trendline2  

trendline3 <- lm(avg_cap/10^6~distance, data = 
                   micrometer_stage_area3 %>% 
                   mutate(distance = separation) %>% 
                   group_by(distance) %>%
                   summarize(avg_cap = mean(capacitance), count = n()) %>%
                   mutate(error = (distance<2300)) %>% 
                   mutate(distance = distance-error*(2300-distance)/50*500) %>% 
                   mutate(distance = distance - 2800+28000) %>% 
                   filter(count>1) %>% 
                   ungroup())
trendline3  

summary(trendline1)
summary(trendline2)
summary(trendline3)

trendline1
trendline2
trendline3

# error analysis
epsilon <- 8.85*10^(-6) # units of pF/micron
d <- 2829.56 # units of microns
h <- 27912 # units of microns
slope <- 8.73*10^(-5)# units of pF/micron
intercept <- 8.829 # units of pF

area1 <- micrometer_stage_area1 %>% 
  mutate(distance = separation) %>% 
  group_by(distance) %>%
  summarize(avg_cap = mean(capacitance)/10^6, count = n()) %>%
  filter(count>1) %>% 
  ungroup() %>%
  mutate(width = distance - 2800+28000) %>% 
# Note that at this point all units are microns and pF
  mutate(theoretical_width = (avg_cap-intercept)*d/epsilon/h) %>% 
  mutate(theoretical_width2 = (avg_cap-intercept)/slope) %>% 
  select(width, theoretical_width, theoretical_width2, avg_cap) %>% 
  mutate(error = abs(width - theoretical_width)) %>% 
  mutate(error2 = abs(width - theoretical_width))

area1 %>% 
  summarize(avg_error = mean(error), stdev = sd(error))

area1 %>% 
  summarize(avg_error2 = mean(error2), stdev2 = sd(error2))

area1 %>% 
  ggplot(aes(error)) +
  geom_histogram()+
  theme_minimal()

  
  

  