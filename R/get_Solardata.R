#' get_Solardata
#'
#' This is a function to download DWD data based on a buffer distance.
#' The meteorological variables are provide in data.frame per station id.
#' @param lat_center latitude central point for the buffer
#' @param lon_center longitude central point for the buffer
#' @param radius_km for the buffer
#' @param time_lag default "hourly" , it can be change for daily or other timestamp available
#' @param period default "historical", if change to "recent" you get one year lag up to "now".
#' @param start_date select stations with date later than
#' @param end_date select stations with date earlier than
#' @param meteo_var type of meteorological data target in the DWD ftp (see option below)
#' @param var_name variable name target in the the downloaded meteo_var file (see option below)
#' @param data_dir where to save the downlaod data, default temporary.
#' @return a list with: 1- a data.frame with the selected variable per station id for the set timestamp, and 2- a data.frame with metadata information, such as stations_id, start_date, end_date, station_height, latitude, longitude, stations_name, region, time_lag, variable, period, file, distance, url.
#' @examples
#' #########
#' solar_radiation <- get_Solardata(lat_center = 52.4537,
#'                                  lon_center = 13.3017,
#'                                  radius_km = 70,
#'                                  time_lag = "hourly",
#'                                  meteo_var = "solar",
#'                                  start_date = "2018-12-31",
#'                                  end_date = "2021-01-01");
#'
#' solar_radiation[[1]][[1]];
#' summary(solar_radiation[[1]][[1]]);
#'
#' @export
get_Solardata <- function(
  lat_center,
  lon_center,
  radius_km,
  time_lag = "hourly",
  meteo_var = "solar",
  start_date,
  end_date,
  data_dir = tempdir()
){
  ###### # stations
  stations_loc <- rdwd::nearbyStations(lat = lat_center, lon = lon_center,
                                       radius = radius_km,
                                       res = time_lag,
                                       var = meteo_var,
                                       mindate=as.Date(start_date))

  stations_loc <- stations_loc[-1,]

  links_data <- rdwd::selectDWD(stations_loc$Stationsname,
                                res = time_lag,
                                var = meteo_var)
  # download file:
  data_name <- rdwd::dataDWD(links_data, dir = "DWDdata", read = FALSE)
  # read and plot file:
  data_set <- rdwd::readDWD(sub(paste0(getwd(),"/"), "", data_name), varnames = FALSE, tz = "UTC") #, format = NULL

  ts <- seq(as.POSIXct(start_date, tz = "UTC"), as.POSIXct(end_date, tz = "UTC"),
            by = "hour") #"30 min"

  ts <- force_tz(ts, tz = "UTC")

  ts <- data.frame("MESS_DATUM_WOZ" = ts[1:(length(ts)-1)])

  for(i in 1:length(data_set)) {
    data_set[[i]]$MESS_DATUM_WOZ <- lubridate::ymd_hm(data_set[[i]]$MESS_DATUM_WOZ)
  }

  data_set_period <- lapply(1:length(data_set), function(i) dplyr::left_join(ts, data_set[[i]],
                                                                             by = "MESS_DATUM_WOZ"))

  names(stations_loc) <- c("stations_id", "start_date", "end_date", "station_height", "latitude", "longitude",
                           "stations_name", "region", "time_lag", "variable", "period", "file", "distance", "url")

  data_list <- list(data_set_period, stations_loc)

  return(data_list)
}
