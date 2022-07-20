#' map_urbanET
#'
#' This is function map Urban ET based on the SCOPE outputs according to a selected period.
#' @param dataset a data.frame with SCOPE outputs, a datetime variable and pixel numbers (timestamp, id_pixel) from the get_prediction function
#' @param function_var aggregation function, default = sum .
#' @param function_time to define the period use data.table::year, data.table::quarters, data.table::month, data.table::week, data.table::yday" for day of the year
#' @param output_vars variables to map, default c("ET", "ET_soil", "ET_canopy"),
#' @param period_var name for the ET, default "annual"
#' @param input_raster the grip template (raster object, the same as the interpolation)
#' @param NA_cells a vector the raster grid id_pixel masked and excluded from the SCOPE run
#' @param Input_vector name of the sf polygon map object
#' @param veg_fraction name of the vegetation fraction variable
#' @param extract_fun get the max ET form the 1km grid, default = 'max', faster and suitable in case of coarse grid
#' @return It will save the sf map with the Urban ET aggregated by the selected period .
#' @examples
#' Map Urban ET based on the SCOPE predictions
#'
#' Urban_ET_map <- map_urbanET(dataset = Berlin2020_pred,
#'                             input_raster = krg_grid,
#'                             NA_cells = cellNA,
#'                             Input_vector = Green_vol,
#'                             veg_fraction = "vegproz",
#'                             function_var = sum,
#'                             function_time = data.table::year,
#'                             output_vars = c("ET", "ET_soil", "ET_canopy"),
#'                             period_var = "annual",
#'                             extract_fun = 'max')
#'
#' plot(Urban_ET_map, border = "transparent", nbreaks=11,
#'      pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)
#'
#' Urban_ET_map_hotday <- map_urbanET(dataset = Berlin2020_pred[as.IDate(timestamp) == "2020-08-08",], # hottest day subset
#'                                    input_raster = krg_grid,
#'                                    NA_cells = cellNA,
#'                                    Input_vector = Green_vol,
#'                                    veg_fraction = "vegproz",
#'                                    function_var = sum,
#'                                    function_time = data.table::yday,
#'                                    output_vars = c("ET"),
#'                                    period_var = "hottest_day",
#'                                    extract_fun = 'max')
#'
#' plot(Urban_ET_map_hotday, border = "transparent", nbreaks=11,
#'      pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)
#'
#' Urban_ET_map_month <- map_urbanET(input_raster = krg_grid,
#'                                   NA_cells = cellNA,
#'                                   Input_vector = Green_vol,
#'                                  veg_fraction = "vegproz",
#'                                   dataset = Berlin2020_pred,
#'                                   function_var = sum,
#'                                   function_time = data.table::month,
#'                                   output_vars = c("ET"),
#'                                   period_var = "monthly",
#'                                   extract_fun = 'max')
#'
#' plot(Urban_ET_map_month[c(3,9,17,21)], border = "transparent", nbreaks=11,
#'      pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)
#'
#' Urban_ET_map_quarter <- map_urbanET(dataset = Berlin2020_pred, # data.table with datetime, id_pixel and SCOPE outputs
#'                                     input_raster = krg_grid, # raster used to interpolate and modelling
#'                                     NA_cells = cellNA, # vector with the NA cells mask by the city (Berlin) border
#'                                     Input_vector = Green_vol, # vector map (sf) with the vegetation fraction
#'                                     veg_fraction = "vegproz", # name of the vegetation fraction var in the map (sf)
#'                                     function_var = sum, # function to summarize (sum, mean, max, min)
#'                                     function_time = quarter, # time to summarize (year, quarter, month, week, yday, hour). If hour or day maybe is need to reduce the range of the timestamp before run
#'                                     output_vars = c("ET", "ET_canopy"), # possible outputs (ET, ET_soil, Tsave - see names(Berlin2020_pred)). If many, better year, quarter or up tp month
#'                                     period_var = "quarter", # name to enumerate the period
#'                                     extract_fun = 'max') # function to extract the raster values into the vector. If the raster is high-resolution use "mean",  otherwise "max" (e.g. 1km grid)
#'
#' plot(Urban_ET_map_quarter[c(3,7,11,15)], border = "transparent", nbreaks=11,
#'      pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)
#'
#' @export
map_urbanET <- function(
    dataset,
    function_var,
    function_time,
    output_vars,
    period_var = "annual",
    input_raster,
    NA_cells,
    Input_vector,
    veg_fraction,
    extract_fun = 'max'
){

  #dataset <-  data.table::as.data.table(dataset)
  .datatable.aware <- TRUE

  output_sumarized <- dataset[, lapply(.SD, function_var),
                              .SDcols = output_vars,
                              keyby=list(function_time(timestamp), id_pixel)]

  output_sumarized <- data.table::dcast(output_sumarized, id_pixel ~ function_time, value.var = output_vars)

  dt_pixelsNA <- data.table::as.data.table(matrix(rep(NA_cells,each=length(output_sumarized)-1),
                                      ncol=length(output_sumarized)-1, byrow=TRUE))

  dt_pixelsNA[which(!is.na(dt_pixelsNA$V1)),] <- output_sumarized[,2:length(output_sumarized)]

  output_raster <- input_raster

  for (i in 1:length(dt_pixelsNA)) {
    output_raster[[paste0("output_",i)]] <- dt_pixelsNA[[i]]
  }

  # extract the values of the raster with the SCOPE model outputs into a vector map (polygon)
  output_vector <- data.table::as.data.table(exactextractr::exact_extract(output_raster,
                                                              Input_vector,
                                                              extract_fun)) # 'mean'

  # include the values into a vector map
  Urban_map  <- Input_vector["geometry"] # only the geometry of multipolygon object

  # include Annual_ET values
  for (i in 1:length(dt_pixelsNA)) {
    Urban_map[[paste0(period_var,"_", i, "_", output_vars[i])]] <- output_vector[[i+1]]
    Urban_map[[paste0("Urban_", period_var,"_", i, "_", output_vars[i])]] <- Urban_map[[paste0(period_var,"_", i,"_", output_vars[i])]]*(Input_vector[[veg_fraction]])/100
  }

  names(Urban_map) <- gsub("NA", "ET",names(Urban_map))

  return(Urban_map)

}
