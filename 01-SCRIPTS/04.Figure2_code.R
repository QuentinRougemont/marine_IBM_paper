## Code for plotting SLiM results (Figure 2)
## Authors: Quentin Rougemont & Amanda Xuereb
## edited Sept. 2021
## work from the cloned github repository so that there's no need to change path


## check if packages are installed
if("dplyr" %in% rownames(installed.packages()) == FALSE)
    {install.packages("dplyr", repos="https://cloud.r-project.org") }
if("magrittr" %in% rownames(installed.packages()) == FALSE)
    {install.packages("magrittr", repos="https://cloud.r-project.org") }
if("ggplot2" %in% rownames(installed.packages()) == FALSE)
    {install.packages("ggplot2", repos="https://cloud.r-project.org") }
if("cowplot" %in% rownames(installed.packages()) == FALSE)
    {install.packages("cowplot", repos="https://cloud.r-project.org") }
if("raster" %in% rownames(installed.packages()) == FALSE)
    {install.packages("rater", repos="https://cloud.r-project.org") }
if("viridis" %in% rownames(installed.packages()) == FALSE)
    {install.packages("viridis", repos="https://cloud.r-project.org") }

## load libs
library(magrittr)
library(ggplot2)
library(dplyr)
library(cowplot)
library(raster)
library(viridis)

#Fig1A - Scenario 1
slim1 <- read.table("02-RESULTS/scenario1_1migration_warming.txt") %>%
  set_colnames(.,c("generation","pop","Fitness","phenotypes","env","nmuts","sdm2","meanAge","sizeAdults","adultCountMinusSize_over_adultsCount"))

# Fig1B - Scenario 2
slim2 <-  read.table("02-RESULTS/scenario1_1migration_warming.txt") %>%
  set_colnames(.,c("generation","pop","Fitness","phenotypes","env","nmuts","sdm2","meanAge","sizeAdults","adultCountMinusSize_over_adultsCount"))

# Fig1C - Scenario 3
slim3 <-  read.table("02-RESULTS/scenario3_2migration_bottleneckNorth_warming.txt") %>%
  set_colnames(.,c("generation","pop","Fitness","phenotypes","env","nmuts","sdm2","meanAge","sizeAdults","adultCountMinusSize_over_adultsCount"))

#create vector of coordinates    
dat <- read.table("00-DATA/54pop_balanced_designed_present_and_future_climate_manual_extraction.txt",T)
dat$pop <- seq(0:(nrow(dat)-1))
coord <-  dat[,c(1:3)]

#combine:
slim <- merge(slim1, coord)
slim2 <-merge(slim2, coord)
slim3 <-merge(slim3, coord)


#load raster and reshape them for ggplot2
r = raster("00-DATA/2100AOGCM.RCP85.Surface.Temperature.Mean.asc.BOv2_1.asc")
#modify raster to fit in ggplot:
spdf <- as(r, "SpatialPixelsDataFrame")
df <- as.data.frame(spdf)
colnames(df) <- c("value", "x", "y")

#present temperature:
r2 = raster("00-DATA/Present.Surface.Temperature.Mean.asc")
spdf2 <- as(r2, "SpatialPixelsDataFrame")
df2 <- as.data.frame(spdf2)
colnames(df2) <- c("value", "x", "y")

## set status:
slim$status <- ifelse(slim$Fitness>0, "alive","dead")
slim[c("status")][is.na(slim[c("status")])] <- "extinct"
slim[c("Fitness")][is.na(slim[c("Fitness")])] <- -9

slim2$status <-   ifelse(slim2$Fitness>0, "alive","dead")
slim2[c("status")][is.na(slim2[c("status")])] <- "extinct"
slim2[c("Fitness")][is.na(slim2[c("Fitness")])] <- -9

slim3$status <-   ifelse(slim3$Fitness>0, "alive","dead")
slim3[c("status")][is.na(slim3[c("status")])] <- "extinct"
slim3[c("Fitness")][is.na(slim3[c("Fitness")])] <- -9


#extract wanted generations for plotting
p.all1 <- filter(slim, generation %in% c(5000, 5510, 5520, 5550))
p.all2 <- filter(slim2, generation %in% c(5000,5510, 5520, 5550))
p.all3 <- filter(slim3, generation %in% c(5000,5510, 5520, 5550))

head(p.all1)
p.all1$scenario <- "slim1"
p.all2$scenario <- "slim2"
p.all3$scenario <- "slim3"
p.all <- rbind(p.all1, p.all2, p.all3)

#create folder architecture:
folder1 = "output/location/FIGURE2/"
system(paste0("mkdir -p ", folder1))


# to plot triangles (extinct) separately from dots (alive):
p.all.pos <- filter(p.all, Fitness > 0)
p.all.neg <- filter(p.all, Fitness < 0)

Fig2A.1 <- ggplot() +
  geom_tile(data=df2, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.pos, generation == 5000 & scenario == "slim1"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness before climate warming",
       subtitle=paste0("generation: ", gen)) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "right", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/01_5000_before_warming.png", plot = Fig1A.1, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2A.2 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.pos, generation == 5510 & scenario == "slim1"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness after 10 generations of warming",
       subtitle=paste0("generation: 5510")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/01_5510_after_warming.png", plot = Fig2A.2, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2A.3 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5520 & scenario == "slim1"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5520 & scenario == "slim1"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness after 20 generations of warming",
       subtitle=paste0("generation: 5520")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 

ggsave(filename = "FIGURE2/01_5520_after_warming.png", plot = Fig2A.3, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2A.4 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5550 & scenario == "slim1"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5550 & scenario == "slim1"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness after 50 generations of warming",
       subtitle=paste0("generation: 5550")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/01_5550_after_warming.png", plot = Fig2A.4, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2B.1 <- ggplot() +
  geom_tile(data=df2, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.pos, generation == 5000 & scenario == "slim2"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness before warming",
       subtitle=paste0("generation: 5000")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/02_5000_before_warming.png", plot = Fig2B.1, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2B.2 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5510 & scenario == "slim2"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5510 & scenario == "slim2"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 10 generations after warming + bottleneck (north)",
       subtitle=paste0("generation: 5510")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/02_5510_after_warming_bottleneckN.png", plot = Fig2B.2, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2B.3 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5520 & scenario == "slim2"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5520 & scenario == "slim2"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 20 generations after warming + bottleneck (north)",
       subtitle=paste0("generation: 5520")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/02_5520_after_warming_bottleneckN.png", plot = Fig2B.3, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2B.4 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5550 & scenario == "slim2"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5550 & scenario == "slim2"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 50 generations after warming + bottleneck (north)",
       subtitle=paste0("generation: 5550")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/02_5550_after_warming_bottleneckN.png", plot = Fig2B.4, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2C.1 <- ggplot() +
  geom_tile(data=df2, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5000 & scenario == "slim3"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5000 & scenario == "slim3"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness before warming + connectivity break",
       subtitle=paste0("generation: 5000")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/03_5000_before_warming_conn_break.png", plot = Fig2C.1, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2C.2 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5510 & scenario == "slim3"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5510 & scenario == "slim3"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 10 generations after warming \n + connectivity break + bottleneck (north)",
       subtitle=paste0("generation: 5510")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/03_5510_after_warming_conn_break_bottlneckN.png", plot = Fig2C.2, device = "png", width = 7, height = 5, units = "in", dpi = 600)



Fig2C.3 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5520 & scenario == "slim3"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5520 & scenario == "slim3"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 20 generations after warming \n + connectivity break + bottleneck (north)",
       subtitle=paste0("generation: 5520")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/03_5520_after_warming_conn_break_bottleneckN.png", plot = Fig2C.3, device = "png", width = 7, height = 5, units = "in", dpi = 600)


Fig2C.4 <- ggplot() +
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  scale_x_continuous(name = "Longitude", breaks = seq(-80, -40, 10), limits = c(-80,-40), expand = c(0,0)) +
  scale_y_continuous(name = "Latitude", breaks = seq(35, 60, 5), limits = c(35,60), expand = c(0,0)) +
  scale_fill_gradientn(name = "Temperature", colors = rev(brewer.pal(n = 10, name = "RdBu")), limits = c(0,35), breaks = seq(0,35,10)) + coord_equal() + theme_map() +
  geom_point(data = filter(p.all.neg, generation == 5550 & scenario == "slim3"), mapping = aes(x = Lon, y = Lat), shape = 17, col = "black", size = 3) +
  geom_point(data = filter(p.all.pos, generation == 5550 & scenario == "slim3"), mapping = aes(x=Lon, y=Lat, colour=Fitness), shape = 16, size=3)+
  scale_color_gradientn(colors = brewer.pal(n = 9, name = "Purples"), limits = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), breaks = c(min(p.all.pos$Fitness), max(p.all.pos$Fitness)), labels = c(0,1)) +
  labs(title = "fitness 50 generations after warming \n + connectivity break + bottleneck (north)",
       subtitle=paste0("generation: 5550")) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
  theme(panel.border = element_rect(fill = NA, size = 1)) +
  theme(legend.position = "bottom", legend.text = element_text(size = 8), legend.title = element_text(size = 10)) 


ggsave(filename = "FIGURE2/03_5550_after_warming_conn_break_bottleneckN.png", plot = Fig2C.4, device = "png", width = 7, height = 5, units = "in", dpi = 600)

