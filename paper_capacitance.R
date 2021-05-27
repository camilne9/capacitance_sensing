library(tidyverse)
library(ggthemes)

setwd("~/hoffman/capacitance")

paper_cap <- read_csv("capacitance.csv")
micrometer_cap <- read_csv("capacitance - micrometer.csv")
micrometer_cloud <- read.csv("micrometer_data.csv")
paper_cloud <- read.csv("paper_sep_data.csv")

paper_cap %>% 
  ggplot(aes(paper*66, mean/10^6))+
  geom_point()+
  #geom_errorbar(aes(ymin=(mean-2*stdev)/10^6, ymax=(mean+2*stdev)/10^6), width=.2)+
  labs(title = "Capacitance by Sheets of Paper Separation",
       subtitle = "Overlapping Area 3.47e-4 m^2",
       x = "Spearation Distance (micrometers)",
       y = "Capacitance (pF)")+
  geom_point(aes(x= paper*66, 
                 y= 8.85*3.74*10^(-4)/(paper*66*10^(-6))+10.8462, 
                 color = "red"), show.legend = FALSE)+
  #geom_smooth(method = "lm")+
  theme_minimal()

ggsave("plots/paper_cap.png", height = 6, width = 8)

paper_cloud %>% 
  ggplot(aes(paper*66, capacitance/10^6))+
  geom_point()+
  labs(title = "Capacitance by Sheets of Paper Separation",
       subtitle = "Overlapping Area 3.47e-4 m^2",
       x = "Spearation Distance (micrometers)",
       y = "Capacitance (pF)")+
  geom_point(aes(x= paper*66, 
                 y= 8.85*3.74*10^(-4)/(paper*66*10^(-6))+10.8462, 
                 color = "red"), show.legend = FALSE)+
  theme_minimal()

ggsave("plots/paper_cloud.png", height = 6, width = 8)

micrometer_cap %>% 
  mutate(separation = (distance -reference_dist)*units_factor) %>% 
  filter(distance != 0.6107) %>% 
ggplot(aes(separation*(10^6), mean/10^6))+
  geom_point()+
  #geom_errorbar(aes(ymin=(mean-2*stdev)/10^6, ymax=(mean+2*stdev)/10^6), width=.2)+
  labs(title = "Capacitance by Separation Measured by Micrometer",
       subtitle = "Offset D145 and Overlapping Area 2.8e-4 m^2",
       x = "Spearation Distance (Micrometers)",
       y = "Capacitance (pF)")+
  geom_point(aes(x= separation*(10^6), y= 8.85*2.8*10^(-4)/separation+3.8462, color = "red"), show.legend = FALSE)+
  #geom_smooth(method = "lm")+
  theme_minimal()

ggsave("plots/micro_cap.png", height = 6, width = 8)

micrometer_cloud %>% 
  mutate(separation = (separation_distance -0.3291)*0.0254) %>% 
  filter(separation_distance != 0.6107) %>% 
  ggplot(aes(x = separation*(10^6), y = capacitance/10^6))+
  geom_point()+
  labs(title = "Capacitance by Separation Measured by Micrometer",
       subtitle = "Offset D145 and Overlapping Area 2.8e-4 m^2",
       x = "Spearation Distance (Micrometers)",
       y = "Capacitance (pF)")+
  geom_point(aes(x= separation*10^6,
  y= 8.85*2.8*10^(-4)/separation+3.8462,
  color = "red"), show.legend = FALSE)+
  theme_minimal()

ggsave("plots/micro_cloud.png", height = 6, width = 8)

