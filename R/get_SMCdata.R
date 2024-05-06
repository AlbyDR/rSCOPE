#' get_SMCdata
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
#' SMC_daily <- get_SMCdata(lat_center = 52.4537,
#'                          lon_center = 13.3017,
#'                          radius_km = 70,
#'                          time_lag = "daily",
#'                          meteo_var = "soil",
#'                          start_date = "2019-01-01",
#'                          end_date = "2020-12-31");
#'
#' SMC_daily[[1]][[1]];
#' summary(SMC_daily[[1]][[1]]);
#'
#' @export
get_SMCdata <- function(
  lat_center,
  lon_center,
  radius_km,
  time_lag = "daily",
  meteo_var = "soil",
  start_date,
  end_date,
  data_dir = tempdir()

){
  dbase <- "ftp://opendata.dwd.de/climate_environment/CDC/derived_germany"
  soilIndex <- rdwd::indexFTP(folder="soil/daily", base = dbase)
  soilIndex <- rdwd::createIndex(soilIndex, base = dbase)

  #  "res" and "var" are inverted in the derived_germany folder!
  colnames(soilIndex)[1:2] <- c("var", "res")
  # non-standard column order, but rdwd should always use names (not positions)

  stations_loc <- rdwd::nearbyStations(lat_center, lon_center,
                                       radius = radius_km,
                                       res = c("hourly"),
                                       per = c("historical"),
                                       var = c("moisture"),
                                       mindate=as.Date(start_date))

  stations_loc <- stations_loc[-1,]

  # select URL:
  links_data <- rdwd::selectDWD(unique(stations_loc$Stationsname),
                                var = meteo_var,
                                res = time_lag,
                                per = c("historical"),
                                outvec =  TRUE,
                                base = dbase,
                                findex = soilIndex)

  data_name <- rdwd::dataDWD(unique(links_data), base = dbase, dir = tempdir(), read = FALSE)

  # download and read files:
  data_set <- rdwd::dataDWD(unique(links_data), base = dbase)

  stations_loc <- stations_loc[!duplicated(stations_loc$Stations_id), ]

  delete_staions <- as.vector(stats::na.omit(sapply(1:length(data_set), function(i)
    ifelse((as.Date(utils::tail(data_set[[i]]$Datum, n=1)) >= as.Date(end_date)) == FALSE |
             (as.Date(utils::head(data_set[[i]]$Datum, n=1)) <= as.Date(start_date)) == FALSE,
           i, NA))))

  data_set <- data_set[-c(delete_staions)]

  stations_loc <- stations_loc[-c(delete_staions),c(1,2,3,5,6,7,8,13)]

  ts <- seq(as.POSIXct(start_date, tz = "UTC"), as.POSIXct(end_date, tz = "UTC"),
            by = "day") #"30 min"

  ts <- lubridate::force_tz(ts, tz = "UTC")

  ts <- data.frame("Datum" = ts[1:(length(ts)-1)])

  data_set_period <- lapply(1:length(data_set), function(i) dplyr::left_join(ts, data_set[[i]][,-33],
                                                                             by = "Datum"))

  names(stations_loc) <- c("stations_id", "start_date", "end_date", "latitude", "longitude",
                           "stations_name", "region",  "distance")
  #"station_height","time_lag", "variable", "period", "file", "url",

  data_list <- list(data_set_period, stations_loc, unique(links_data))

  return(data_list)
}
