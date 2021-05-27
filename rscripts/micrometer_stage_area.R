library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance")

micrometer_stage_area1 <- read_csv("area1.csv", col_names = c("separation", "capacitance"))
micrometer_stage_area2 <- read_csv("area2.csv", col_names = c("separation", "capacitance"))
micrometer_stage_area3 <- read_csv("area3.csv", col_names = c("separation", "capacitance"))

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
  theme_minimal()

  