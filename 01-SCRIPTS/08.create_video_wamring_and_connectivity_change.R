
library(magrittr)
library(ggplot2)
library(dplyr)
library(cowplot)
library(raster)
library(viridis)
library(gganimate)

slim <- read.table("03.reshaped/run_2mig_mig5460.QTL0.02.txt") %>% 
	set_colnames(.,c("generation","pop","Fitness","phenotypes","env","nmuts","sdm2","meanAge","sizeAdults","adultCountMinusSize_over_adultsCount"))

#create vector of coordinates    
dat <- read.table("54pop_balanced_designed_present_and_future_climate_manual_extraction.txt",T)
dat$pop <- seq(0:(nrow(dat)-1))

coord <-  dat[,c(1:3)]

slim <- merge(slim, coord)

r = raster("01.data/2100AOGCM.RCP85.Surface.Temperature.Mean.asc.BOv2_1.asc")
#modify raster to fit in ggplot:
spdf <- as(r, "SpatialPixelsDataFrame")
df <- as.data.frame(spdf)
colnames(df) <- c("value", "x", "y")
r2 = raster("01.data/Present.Surface.Temperature.Mean.asc")
spdf2 <- as(r2, "SpatialPixelsDataFrame")
df2 <- as.data.frame(spdf2)
colnames(df2) <- c("value", "x", "y")

slim$status <- ifelse(slim$Fitness>0, "alive","dead")
slim[c("status")][is.na(slim[c("status")])] <- "extinct"
slim[c("Fitness")][is.na(slim[c("Fitness")])] <- -9

slim_before <- filter(slim, generation < 5460 & generation > 5000)
slim_crash <- filter(slim, generation < 5500 & generation > 5460)
slim_after <-  filter(slim, generation >= 5500)

folder1 = "png_warming_and_connectivity_54_pop/before"
folder2 = "png_warming_and_connectivity_54_pop/connectivity_change"
folder2 = "png_warming_and_connectivity_54_pop/warming"

system(paste0("mkdir -p ", folder1))
system(paste0("mkdir -p ", folder2))
system(paste0("mkdir -p ", folder3))

temps <- unique(sort(slim_before$generation))
df3 = filter(df2, x > -99.5 & x < -39.5 & y >29.5 & y < 75.5 )
for(gen in temps)
{
	p1 <- filter(slim_before, generation == gen) #%>%
  	p2 <- ggplot() +  
  	geom_tile(data=df3, aes(x=x, y=y, fill=value), alpha=0.8) + 
  		lims(x = c(-99,-40), y = c(30,75)) +
  		scale_fill_viridis() +
  		coord_equal() +
  		theme_map() + #theme_bw()
  	geom_point(data = p1, mapping = aes(x=Lon, y=Lat, color=Fitness, shape=status), size = 2) +
	    scale_color_continuous(breaks =c(min(p1$Fitness),max(p1$Fitness)), 
				   labels = c("min", "max")) +
	    #scale_color_continuous(breaks =c(0.8,0.95,1), labels = c("low", "med", "high")) +
  	labs(title = "fitness before climate warming",
	       subtitle=paste0("generation: ", gen)) + 
  	theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
	      plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
      	#guides(size = "none", colour = guide_colourbar(order = 1) )  + 
      	guides( colour = guide_colourbar(order = 1),
		 shape = guide_legend(order = 2),
	         size = guide_legend(order = 3) ) + 

      	labs(colour = c("Fitness", "value", "size" ), 
		   fill=c("Temperature","Fitness","extinction"))
	png(paste0(folder1, "/input",gen,".png"),width = 2480, height=1500, res = 300)
	print(p2)
	dev.off()
}

### during crash:
temps <- unique(sort(slim_crash$generation))
df3 = filter(df2, x > -99.5 & x < -39.5 & y >29.5 & y < 75.5 )
for(gen in temps)
{
	p1 <- filter(slim_crash, generation == gen) #%>%
  	p2 <- ggplot() +  
  	geom_tile(data=df3, aes(x=x, y=y, fill=value), alpha=0.8) + 
  		lims(x = c(-99,-40), y = c(30,75)) +
  		scale_fill_viridis() + 	coord_equal() + theme_map() + #theme_bw()
  	geom_point(data = p1, mapping = aes(x=Lon, y=Lat, color=Fitness, shape=status), size = 2) +
	    scale_color_continuous(breaks =c(min(p1$Fitness),max(p1$Fitness)), 
				    labels = c("min", "max")) +
  	labs(title = "fitness when chaning connectivity", subtitle=paste0("generation: ", gen)) + 
  	theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
	      plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
      	#guides(size = "none", colour = guide_colourbar(order = 1) )  + 
      	guides( colour = guide_colourbar(order = 1), shape = guide_legend(order = 2),
	         size = guide_legend(order = 3) ) + 
      	labs(colour = c("Fitness", "value", "size" ),  fill=c("Temperature","Fitness","extinction"))
	png(paste0(folder2,"/input",gen,".png"),width = 2480, height=1500, res = 300)
	print(p2)
	dev.off()
}

temps <- unique(sort(slim_after$generation))
df1 = filter(df, x > -99.5 & x < -39.5 & y >29.5 & y < 75.5 )
for(gen in temps)
{
	p1 <- filter(slim_after, generation == gen) #%>%
  	p2 <- ggplot() +  
  	geom_tile(data=df1, aes(x=x, y=y, fill=value), alpha=0.8) + 
  	lims(x = c(-99,-40), y = c(30,75)) +
  	scale_fill_viridis() + coord_equal() +	theme_map() + #theme_bw() +
  	geom_point(data = p1, mapping = aes(x=Lon, y=Lat, color=Fitness,shape=status), size = 2) +
	    scale_color_continuous(breaks =c(min(p1$Fitness),max(p1$Fitness)), 
				   labels = c("min", "max")) +
  	labs(title = "fitness during climate warming", subtitle=paste0("generation: ", gen)) + 
  	theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
	      plot.subtitle = element_text(hjust = 0.5, size = 12, face = "bold")) +
	guides( colour = guide_colourbar(order = 1), shape = guide_legend(order = 2),
	         size = guide_legend(order = 3) ) + 
      	labs(colour = c("Fitness", "value","shape" ), fill=c("Temperature","Fitness","status"))
	png(paste0(folder3,"input",gen,".png"),width = 2480, height=1500, res = 300)
	print(p2)
	dev.off()
}

### then create video:
productPath=getwd() 
library(av)
                    
p <- getwd()
p1 <-paste0(p, "/", folder1)
p2 <-paste0(p, "/", folder2)
p3 <-paste0(p, "/", folder3)

nom1 <- '54pop_before_warming.mp4'
nom2 <- '54pop_during_connectivity_change.mp4'
nom3 <- '54pop_during_warming.mp4'

setwd(p1)
av::av_encode_video(list.files(p1, '*.png'), framerate = 18,
    output = paste0(nom1))
                 
#before warming:
setwd(p2)
av::av_encode_video(list.files(p2, '*.png'), framerate = 05,
    output = paste0(nom2))
                    
setwd(p)
#create a file for the video:
z1 <- paste0("file '", p1,"/",nom1,"'" )
z2 <- paste0("file '", p2,"/",nom2,"'" )
z3 <- paste0("file '", p3,"/",nom3,"'" )

write.table(c(z1,z2,z3),
	    "inputs.txt",
	    quote=F,row.names=F,col.names=F)
#2. merge with ffmpeg:
system("ffmpeg -f concat -i inputs.txt -c copy output.mp4")


