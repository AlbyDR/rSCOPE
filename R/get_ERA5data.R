#' get_ERA5data
#'
#' This is a function to download ERA5 reanalysis data based on a city border.
#' The meteorological variables are provided in dataframe file per city and year.
#'
#' @param format = "netcdf" (default)
#' @param city_border , a sf vector object with the city borders
#' @param user_cds, your user from the Copernicus portal
#' @param var , the variable names (see variable options)
#' @param year_vec
#' @param month_vec
#' @param day_vec
#' @param time_vec
#' @param path_file , where to save the downloaded data
#' @param dataset , name of the file
#' @return a file .nc
#' 
#' @examples
#' ##### variable options
#' # see https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land?tab=overview
#'
#' library(ncdf4)
#' library(terra)
#' library(raster)
#' library(sf)
#' library(ecmwfr)
#' library(lubridate)
#' library(tidyverse)
#' library(rSCOPE)
#'
#' # request Berlin reanalysis-era5-single-levels
#' request_Berlin_meteo_2020 <- list(
#'         product_type = "reanalysis",
#'         format = "netcdf",
#'         var = c(
#'               "2m_temperature",
#'               "10m_u_component_of_wind", 
#'               "surface_pressure",
#'               'surface_thermal_radiation_downwards',
#'               'surface_solar_radiation_downwards', 
#'               'total_precipitation'), # [m]
#'  year = "2020",
#'  month = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"),
#'  day = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"),
#'  time = c("00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"),
#'  area = c(53, 12, 52, 14), # 
#'  target = "Berlin_meteo_2020.nc")
#'
#'  ecmwfr::wf_request(user = user_cds,                           # user ID (for authentification)
#'            request  = request_Berlin_meteo_2020,       # the request
#'            transfer = TRUE,                            # download the file
#'            path = "D:/Data-Modelling/EUcities/Meteo/") # store data in a directory
#'
#'  names(nc_open(paste0("D:/Data-Modelling/EUcities/Meteo/", "Berlin_meteo_2020.nc"))$var)
#'
#' @export
get_ERA5 <- function(
    product_type = "reanalysis",
    format = "netcdf",
    city_border = NA,
    user_cds = NA,
    var = NA,
    year_vec = NA,
    month_vec = NA,
    day_vec = NA,
    time_vec = NA,
    path_file = "D:/Research topics/Data-Modelling/EUcities/Meteo/",
    dataset = NA
    
){
  
  request <- lapply(1:length(city_border), FUN=function(i) list(
    product_type = "reanalysis",
    format = "netcdf",
    variable = var, #
    year = year_vec,
    month = month_vec,
    day = day_vec,
    time = time_vec,
    area = c(city_border[[i]]$latlon$bbox_border[4] + 0.5,
             city_border[[i]]$latlon$bbox_border[1] - 0.5,
             city_border[[i]]$latlon$bbox_border[3] - 0.5,
             city_border[[i]]$latlon$bbox_border[2] + 0.5),
    dataset_short_name = dataset,
    target = paste0(names(city_border)[i], "-", var, "-", dataset, ".nc")))
  
  
  for (i in 1:length(city_border)) {
    R.utils::withTimeout({
      ecmwfr::wf_request(user = user_cds,   # user ID (for authentification)
                         request  = request[[i]],  # the request
                         transfer = TRUE,     # download the file
                         path = path_file)# store data in current working directory
    }, timeout = 30, onTimeout = "warning")
    
  }
}
############################################################################
