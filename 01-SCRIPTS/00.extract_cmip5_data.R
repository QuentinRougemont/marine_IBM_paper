

#Author QR
#Date : August 2021
#Purpose: extract temperature data on CMIP5 

## check if packages are installed
if("dplyr" %in% rownames(installed.packages()) == FALSE)
    {install.packages("dplyr", repos="https://cloud.r-project.org") }
if("ncdf4" %in% rownames(installed.packages()) == FALSE)
    {install.packages("ncdf4", repos="https://cloud.r-project.org") }

## load libs
library(ncdf4)
library(dplyr)

argv <- commandArgs(T)
file <- argv[1]
ncin <- nc_open(file)

filename = strsplit(file,"/")[[1]][2]

#get longitude and latitude
lon <- ncvar_get(ncin,"lon")
lat <- ncvar_get(ncin,"lat")
time <- ncvar_get(ncin,"time")
#time
library(ncdf4.helpers)
tas_time <- nc.get.time.series(ncin, v = "tos",time.dim.name = "time")
#tunits <- ncatt_get(ncin,"time","units")
nt <- dim(time)
# get temperature
dname = "tas"
tmp_array <- ncvar_get(ncin,dname)
#all along tmp means temperature "tas" could also be used
dim(tmp_array)

## replace netCDF fill values with NA's
fillvalue <- ncatt_get(ncin,dname,"_FillValue")
tmp_array[tmp_array==fillvalue$value] <- NA
#length(na.omit(as.vector(tmp_array[,,1])))

######### create data frame ###################
# reshape the array into vector
tmp_vec_long <- as.vector(tmp_array)
length(tmp_vec_long)

nlon = length(lon) #360
nlat = length(lat) #210

# reshape the vector into a matrix
tmp_mat <- matrix(tmp_vec_long, nrow=nlon*nlat, ncol=nt)
dim(tmp_mat)

tmp_mat <- tmp_mat - 273.15 #convert K to °C

#convert longitude to correct format:
lon = ifelse(lon > 180, -(360 - lon), lon)

lonlat <- as.matrix(expand.grid(lon,lat))
colnames(lonlat) <- c("long","lat")
#colnames(tmp_mat) <- format(tas_time, "%Y-%m-%d")
#colnames(tmp_mat) <- format(tas_time, "%Y")


tmp_df <- data.frame(cbind(lonlat,tmp_mat))
colnames(tmp_df)[3:62] <- format(tas_time, "%Y")
colnames(tmp_df)[3:62] <- format(tas_time, "%Y-%m-%d")

#write.table(tmp_df02, paste0("RCP85_lat_lon.",flist[12]), quote=F,row.names=F,col.names=T)

## read in a matrix of coordinate ###
sample <- read.table("sampling_site.csv", sep=",",T )
long = sample$Longitude
lat = sample$Latitude
nbpoint = nrow(sample)

#compute mean over year and month (5 years 12 months)
tmp_df$mRCP85_2096_2100 <- apply(tmp_df[3:60],1,mean)
mean_temp <- dplyr::select(tmp_df, long,lat,mRCP85_2096_2100)
tmp_df <- dplyr::select(tmp_df, -mRCP85_2096_2100)
#extract the mean value for the last period:
temp1 <- NULL
final_temp <- NULL
for (z in 1:nbpoint)
{
   #w <- which(abs(mean_temp$long-long[z])==min(abs(mean_temp$long-long[z])))
   #x <- which(abs(mean_temp$lat -lat[z])==min(abs(mean_temp$lat-lat[z])))
   w1<- which(abs(tmp_df$long-long[z])==min(abs(tmp_df$long-long[z])))
   x1<- which(abs(tmp_df$lat -lat[z])==min(abs(tmp_df$lat-lat[z])))


   #temp1 <- mean_temp[intersect(w,x),]
   temp1 <- tmp_df[intersect(w1,x1),]
   final_temp <- rbind(final_temp, temp1)
}

#all <- cbind(sample,final_temp)
#write.table(all,"temperature_coho_RCP8.5_2096_2100_mean.txt",quote=F,row.names=F)
all <- select(final_temp, -long, -lat)
write.table(all,
	    paste0("fake_RCP8.5_year_month_day_",filename, ".txt"), 
	    quote = F, 
	    row.names=F)


##################################################################################
##getting yearly estimates: #####################################################
#colnames(tmp_mat) <- format(tas_time, "%Y")

mat <-t(tmp_mat)
mat <- aggregate(as.matrix(mat), list(format(tas_time, "%Y")), mean)
#retranspose to get year in columns
matYear <- t(as.matrix(mat[-1])) #remove also the grouping factor (years) to get a mattrix
colnames(matYear) <- mat[,1] #get years

tmp_df <- data.frame(cbind(lonlat,matYear))
temp1 <- NULL
final_temp <- NULL
for (z in 1:nbpoint)
{
   w1<- which(abs(tmp_df$long-long[z])==min(abs(tmp_df$long-long[z])))
   x1<- which(abs(tmp_df$lat -lat[z])==min(abs(tmp_df$lat-lat[z])))

   temp1 <- tmp_df[intersect(w1,x1),]
   final_temp <- rbind(final_temp, temp1)
}

all <- select(final_temp, -long, -lat)

write.table(all,
	    paste0("fake_RCP8.5_year_",filename, ".txt"), 
	    quote = F, 
	    row.names=F)


