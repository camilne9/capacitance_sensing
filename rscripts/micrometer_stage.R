library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance")

micrometer_stage3 <- read_csv("micrometerstage4.csv")

micrometer_stage3 %>% 
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
  theme_minimal()
