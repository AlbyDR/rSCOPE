#' get_DWDdata
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
#' @param by_lag to create a timestamp, default "hour",
#' @return a list with: 1- a data.frame with the selected variable per station id for the set timestamp, and
#'                      2- a data.frame with metadata information, such as stations_id, start_date, end_date,
#'                      station_height, latitude, longitude, stations_name, region, time_lag, variable, period, file, distance, url.
#' data_dir where to save the downlaod data, default temporary. dir.create(file.path(tempdir(), "DWDdir"), showWarnings = FALSE)
#' @examples
#' ##### meteo_var options
#' # "precipitation"       "air_temperature"     "extreme_temperature"   "extreme_wind"
#' # "solar"               "wind"                "wind_test"             "kl"
#' # "more_precip"         "weather_phenomena"   "soil_temperature"      "water_equiv"
#' # "cloud_type"          "cloudiness"          "dew_point"             "moisture"
#' # "pressure"            "sun"                 "visibility"            "wind_synop"
#' # "soil"                "standard_format"
#'
#' ##### var_name options
#' ### meteo_var = air_temperature
#' # var_name = TT_TU, air temperature at 2m height (Ta)
#' # var_name = RF_TU, relative humidity at 2m height (RH)
#' # meteo_var = "precipitation"
#' # var_name = R1, mm of precipitation (prec_mm)
#' # var_name = RS_IND, occurrence of precipitation, 0 no precipitation / 1 precipitation fell (prec_h)
#' ### meteo_var = "pressure"
#' # var_name = P0     # Pressure at station height (2m)
#' # var_name = P      # Pressure at see level
#' ### meteo_var = "wind_synop"
#' # var_name = FF     # Average wind speed (ws)
#' # var_name = DD     # wind direction (wd)
#' ### meteo_var = "moisture" (atm)
#' # var_name = P_STD	  Hourly air pressure	[hpa]
#' # var_name = RF_STD	Hourly values of relative humidity	[%]
#' # var_name = TD_STD	Dew point temperature at 2m height	[°C]
#' # var_name = TF_STD	Calculated hourly values of the wet temperature	[°C]
#' # var_name = TT_STD	Air temperature at 2m height	[°C]
#' # var_name = VP_STD	calculated hourly values of the vapour pressure [hpa]
#' ### meteo_var = "sun"
#' # var_name = SD_SO   # sunshine duration - minutes
#' ### "soil_temperature"
#' # soil.temp.2cm
#' # soil.temp.5cm
#' # soil.temp.10cm
#' # soil.temp.20cm
#' # soil.temp.50cm
#' # soil.temp.100cm
#' ### "visibility"
#' # V_VV      # Visibility in meter
#' # V_VV_I    # from the observer
#' ### "dew_point"
#' # TT   # dry bulb temperature at 2 meter above ground
#' # TD   # dew point temperature at 2 meter above ground
#' ### "cloudiness"
#' # V_N    # Total coverage - eighth levels # same as cloudness
#'
#' #########
#' Air_temp <- get_DWDdata(lat_center = 52.4537,
#'                         lon_center = 13.3017,
#'                         radius_km = 70,
#'                         time_lag = "hourly",
#'                         period = "historical",
#'                         meteo_var = "air_temperature",
#'                         start_date = "2019-01-01",
#'                         end_date = "2020-12-31",
#'                         var_name = "TT_TU");
#'
#' Air_temp[[1]];
#' summary(Air_temp[[1]]);
#'
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
#' ##########
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
get_DWDdata <- function(
  lat_center,
  lon_center,
  radius_km,
  time_lag = "hourly",
  period,
  meteo_var,
  start_date,
  end_date,
  var_name,
  by_lag = "hour"
){
  ###### # stations
  stations_loc <- rdwd::nearbyStations(lat = lat_center,
                                       lon = lon_center,
                                       radius = radius_km,
                                       res = time_lag,
                                       per = period,
                                       var = meteo_var,
                                       mindate = as.Date(start_date))

  stations_loc <- stations_loc[-1,]

  links_data <- rdwd::selectDWD(stations_loc$Stationsname,
                                outvec =  TRUE,
                                res = time_lag,
                                per = period,
                                var = meteo_var)

  DWDdir <- file.path(tempdir(), "DWDdir")

  dir.create(DWDdir)

  # download file:
  data_name <- rdwd::dataDWD(links_data, dir = DWDdir, read = FALSE)

  # read and plot file:
  data_set <- rdwd::readDWD(data_name, varnames = FALSE, tz = "UTC") #, format = NULL

  delete_staions <- as.vector(stats::na.omit(sapply(1:length(data_set), function(i)
    ifelse((as.Date(utils::tail(data_set[[i]]$MESS_DATUM, n = 1)) >= as.Date(end_date)) == FALSE |
           (as.Date(utils::head(data_set[[i]]$MESS_DATUM, n = 1)) <= as.Date(start_date)) == FALSE,
           i, NA))))

  data_set <- data_set[-c(delete_staions)]

  stations_loc <- stations_loc[-c(delete_staions),]

  delete_staions2 <- as.vector(stats::na.omit(sapply(1:length(data_set), function(i)
    ifelse(is.na(utils::head(dplyr::filter(data_set[[i]], lubridate::year(MESS_DATUM) >= lubridate::year(start_date))[var_name], n = 1)) == TRUE |
           is.na(utils::tail(dplyr::filter(data_set[[i]], lubridate::year(MESS_DATUM) >= lubridate::year(start_date))[var_name], n = 1)) == TRUE,
           i, NA)
  )))

  # ### if dif than NA
  if (class(delete_staions2) == "integer"){
    data_set <- data_set[-c(delete_staions2)]
  }
  if (class(delete_staions2) == "integer"){
    stations_loc <- stations_loc[-c(delete_staions2),]
  }

  # #####
  ts <- seq(as.POSIXct(as.Date(start_date), tz = "UTC"), as.POSIXct(as.Date(end_date)+1, tz = "UTC"),
            by = by_lag) #"30 min"

  ts <- force_tz(ts, tz = "UTC")

  ts <- data.frame("MESS_DATUM" = ts[24:(length(ts)-2)])

  data_set_period_NA <- sapply(1:length(data_set), function(i) dplyr::left_join(ts, data_set[[i]],
                                                                                by = "MESS_DATUM")[var_name])

  data_set_period <- data.frame("MESS_DATUM" = ts)

  for (i in 1:length(data_set_period_NA)) {
    ifelse(meteo_var == "sun",
           data_set_period[i] <- c(c(0,0,0), zoo::na.approx(data_set_period_NA[[i]]), c(0,0,0)),
           data_set_period[i] <- c(as.numeric(zoo::na.approx(data_set_period_NA[[i]]))) )
  }

  colnames(data_set_period) <- sapply(1:length(data_set_period), function(i) paste0("ID_", data_set[[i]][1,1]))

  unlink(DWDdir, recursive = TRUE)

  dataset <- data.frame("timestamp" = ts, data_set_period)

  names(stations_loc) <- c("stations_id", "start_date", "end_date", "station_height", "latitude", "longitude",
                           "stations_name", "region", "time_lag", "variable", "period", "file", "distance", "url")

  data_list <- list(dataset, stations_loc)

  return(data_list)
}
