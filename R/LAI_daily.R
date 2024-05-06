#' LAI_daily
#'
#' This is a function convert in daily values the downloaded LAI images for a location from the Copernicus Vito portal.
#' @param start_date start date of the images , e.g. "2017-12-01"
#' @param end_date end date of the images
#' @param LAI_rast raster with 10 day LAI layers, plus gaps
#' @param crop_area, a sf polygon with desirable the extent
#' @return a raster with daily values of LAI
#' @examples
#'
#' # file list downloaded from get_LAI
#' file_names <- list.files(path=paste0("D:/Data-Modelling/","LAI/"), pattern="*.nc", recursive=TRUE)
#'
#' file_names <- file_names[1:173]
#'
#' file_names_patch <- sapply(1:length(file_names), FUN = function(i) paste0("D:/Data-Modelling/", "LAI/", file_names[i]))
#'
#  # check var name
#' names(nc_open("D:/Data-Modelling//LAI/2020/LAI_20201231.nc")$var)
#'
#  # open global images
#' LAI_copernicus_globe <- terra::rast(file_names_patch, "LAI")
#' # crop to EU to reduce size
#' LAI_EU <- terra::crop(LAI_copernicus_globe, terra::ext(-10.125, 30.125, 29.875, 65.125))
#' plot(LAI_EU[[121]])
#'
#' rm(LAI_copernicus_globe)
#'
#' # layers name and time
#' names(LAI_EU) <- rev(LAI_links[[2]])
#' terra::time(LAI_EU) <- lubridate::ymd(rev(LAI_links[[2]]))
#'
#' # save
#' terra::writeRaster(LAI_EU, "LAI_EU.tif", overwrite = TRUE)
#'
#' LAI_Berlin <-  LAI_daily(star_data = as.Date("2018-01-10", tz="UTC"),
#'                          end_data = as.Date("2022-09-10", tz="UTC"),
#'                          LAI_rast = LAI_EU,
#'                          crop_area = obj_locations_cities$DE_Berlin_TUCC$latlon$buffer_dist)
#'
#' plot(LAI_Berlin[[c(2,10,30,120)]])
#'
#'
#' @export
#
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
