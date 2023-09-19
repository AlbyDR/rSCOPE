# LAI_daily
# function 2 - daily LAI for a city/location

LAI_daily <- function(
    star_data = NA,
    end_data = NA,
    LAI_rast = NA,
    crop_area = NA

){

  #### Create a timestamp ####
  # Generate Regular Sequences of Dates
  tsLAI = seq.Date(star_data, end_data, by = "day")

  #### Timestamp names ####
  # create the timestamp name to be the same of the LAI images

  tsLAI_names <- sapply(1:length(tsLAI), FUN=function(i)
    paste0("",
           substring(tsLAI[i], 1, 4),"",
           substring(tsLAI[i], 6, 7),"",
           substring(tsLAI[i], 9, 10)
    ))

  LAI_crop <- terra::crop(LAI_rast, crop_area)

  LAI_crop_interpolated <- terra::approximate(LAI_crop, rule = 2)

  # I created a NULL raster
  raster_null <- LAI_crop_interpolated[[2]]
  values(raster_null) <- NA

  #### Create a raster with all days ####
  # create a raster stack with the 365 days
  # 365 days of NA
  LAI_daily <- replicate(length(tsLAI_names), raster_null)

  names(LAI_daily) <- tsLAI_names

  for (i in 1:length(LAI_daily)) {
    names(LAI_daily[[i]]) <- tsLAI_names[i]
  }

  for (i in 1:length(LAI_daily)) {
    time(LAI_daily[[i]]) <- lubridate::ymd(tsLAI_names[i])
  }

  #### Replace real LAI images in the NA rasters ####
  for (i in 1:nlyr(LAI_rast)) {
    LAI_daily[[names(LAI_crop_interpolated)[i]]] <- LAI_crop_interpolated[[i]]
  }

  ### stack all list rasters
  LAI_daily_s <- terra::rast(LAI_daily)

  LAI_daily <- terra::approximate(LAI_daily_s, rule = 2)

  return(LAI_daily)

}
##################################################################################
##################################################################################
