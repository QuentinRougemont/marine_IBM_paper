

## Author : Q. Rougemont
## Date: August 2021
##script to plot the fake 54 points on the two raster (present and future climate change)
##and extract the future temperature for each point


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

## load data
pop <- read.table("00-DATA/all_fake_54_pop.txt",T)
coord <- pop[,c(1:3)] %>% set_colnames(.,c("pop","lon","lat")
				       )
coord$pop <- seq(1:nrow(coord))

#load raster:
r = raster("00-DATA/2100AOGCM.RCP85.Surface.Temperature.Mean.asc.BOv2_1.asc")
r2 = raster("00-DATA/Present.Surface.Temperature.Mean.asc" )

#modify raster to fit in ggplot:
spdf <- as(r, "SpatialPixelsDataFrame")
df <- as.data.frame(spdf)
colnames(df) <- c("value", "x", "y")
#present temp:
spdf <- as(r2, "SpatialPixelsDataFrame")
dfpresent<- as.data.frame(spdf)
colnames(dfpresent) <- c("value", "x", "y")

p2 <-ggplot() +  
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  lims(x = c(-99,-40), y = c(30,75)) +
  scale_fill_viridis() +
  coord_equal() +  theme_map() +
  #theme(legend.position="bottom") +
  geom_point(data = coord, mapping = aes(x=lon, y=lat, size = 4)) +
  geom_label(data = coord, mapping = aes(x=lon, y=lat), label = coord$pop, 
	     nudge_x = 0.98, nudge_y = 0.98) +
  labs(x = "Longitude", y = "Latitude" ) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold")) +
      guides(size = "none" ) + 
      labs(colour = c("phenoFitness", "value" ), fill=c("RCP85"))
p2

#### extracting coord
long = as.numeric(coord$lon)
lat = as.numeric(coord$lat)
nbpoint = nrow(coord)
#extract the mean value for the last period:
temp1 <- NULL
final_temp <- NULL
present_temp <- NULL
temp2 <- NULL
for (z in 1:nbpoint)
{
   w1<- which(abs(df$x-long[z])==min(abs(df$x-long[z])))
   x1<- which(abs(df$y -lat[z])==min(abs(df$y-lat[z])))

   temp1 <- df[intersect(w1,x1),]
   final_temp <- rbind(final_temp, temp1)

   w2<- which(abs(dfpresent$x-long[z])==min(abs(dfpresent$x-long[z])))
   x2<- which(abs(dfpresent$y -lat[z])==min(abs(dfpresent$y-lat[z])))

   temp2 <- dfpresent[intersect(w2,x2),]
   present_temp <- rbind(present_temp, temp2)
}

RCP8.5_temp <- final_temp
all <- cbind(coord,present_temp$value,RCP8.5_temp) %>% 
	set_colnames(.,c("pop","Lon","Lat","presentT","RCP8.5","closestLon","closestLat"))

all <- all[order(all$RCP8.5),]
all

### on refait le grapĥ avec les nouveaux points:
all$pop <- seq(1:nrow(coord))
coord = all[,c(1:3)]
colnames(coord) <- c("pop","lon","lat")

p2 <-ggplot() +  
  geom_tile(data=df, aes(x=x, y=y, fill=value), alpha=0.8) + 
  lims(x = c(-99,-40), y = c(30,75)) +
  scale_fill_viridis() +
  coord_equal() +  theme_map() +
  #theme(legend.position="bottom") +
  geom_point(data = coord, mapping = aes(x=lon, y=lat ), size = 2) +
  geom_label(data = coord, mapping = aes(x=lon, y=lat ), size = 3.5, label = coord$pop, 
	     nudge_x = 0.6, nudge_y = 0.6) +
  labs(x = "Longitude", y = "Latitude" ) + 
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold")) +
      guides(size = "none" ) + 
      labs(colour = c("phenoFitness", "value" ), fill=c("RCP85"))
p2

write.table(all, "00-DATA/54pop_balanced_designed_present_and_future_climate_manual_extraction.txt", quote=F,row.names=F)

### now write data for the whole time period considered :
nsites= nrow(all) # change this to smaller number if you want to run a smaller model

pops=seq(1,nsites) # population names
e.local=all$presentT-mean(all$presentT) # local environmental settting

## use the approach of Matz et al. 
sin.p=5 # period of sinusoidal climate fluctuations, in reproduction cycles
# ---- rand /  sin settings:
# e.sd= 0.2 # SD of random environmentsl fluctuations (different in each pop)
sin.amp=0.5 # amplitude of sinusoidal climate fluctuations, common to all pops
# sin.rand=0.2 # amplitude of random climate fluctuations, common to all pops
e.sd= 0.0 # SD of random environmentsl fluctuations (different in each pop)
sin.rand=0.0 # amplitude of random climate fluctuations, common to all pops
burnin=5500 # length of burnin period
gmax=6000 # maximum number of generations

e.increment=all$RCP8.5/90 # increment in environmental setting per reproduction cycle (year) past burn-in period

# for no-fluctuation and sinusoidal model, there is only one environmental profile ("a") for all SLiM replicates; for random model there are four different profiles.
for (index in c("a")) # #"b","c","d")) {
	{
	message(index)
	dd=lapply(seq_len(gmax),function(i) {
		newgen=e.local+sin(i*2*pi/sin.p)*0.5*(sin.amp+rnorm(1,0,sin.rand))
		newgen=newgen+rnorm(length(newgen),0,e.sd)
		if (i>burnin){
			newgen=newgen+(i-burnin)*e.increment
		}
		return(round(newgen,3))
		}
	)
	envs=data.frame(do.call(cbind,dd))
	write.table(envs,row.names=F,quote=F,sep="\t",
		    file=paste("00-DATA/balanced_env54pop_sin_",index,"_environment.txt",sep=""))

}


