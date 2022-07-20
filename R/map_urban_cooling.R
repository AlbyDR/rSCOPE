#' map_urban_cooling
#'
#' This function map greening cooling services based on the SCOPE outputs according to a selected period.
#' @param dataset a data.frame with SCOPE outputs, a datetime variable and pixel numbers (timestamp, id_pixel) from the get_prediction function
#' @param date_hottest to define the day to calculate the indices
#' @param output_vars variables to map, default c("ET", "Tsave"),
#' @param input_raster the grip template (raster object, the same as the interpolation)
#' @param NA_cells a vector the raster grid id_pixel masked and excluded from the SCOPE run
#' @param Input_vector name of the sf polygon map object
#' @param veg_fraction name of the vegetation fraction variable
#' @param extract_fun get the max ET form the 1km grid, default = 'max', faster and suitable in case of coarse grid
#' @return It will save the split files in the SCOPE directory.
#' @examples
#' Map greening cooling services indices based on the SCOPE predictions
#'Cooling_maps_2000 <- map_urban_cooling(dataset = Berlin2020_pred,
#'                                       date_hottest = "2020-08-08",
#'                                       input_raster = krg_grid,
#'                                       NA_cells = cellNA,
#'                                       Input_vector = Green_vol,
#'                                       veg_fraction = "vegproz",
#'                                       output_vars = c("ET", "Tsave"),
#'                                       extract_fun = 'max')
#'
#'summary(Cooling_maps_2000)
#'
#'plot(Cooling_maps_2000[c(3,4,5)], border = "transparent", nbreaks=11,
#'     pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)
#'
#'
#' @export
map_urban_cooling <- function(
    dataset,
    date_hottest,
    function_var = list(max, sum),
    output_vars = c("ET", "Tsave", "Tcave"),
    input_raster,
    NA_cells,
    Input_vector,
    veg_fraction,
    extract_fun = 'max'
){

  .datatable.aware <- TRUE

  dt_hottest <- dataset[as.IDate(timestamp) == date_hottest,]

  dt_output_max <- dt_hottest[, lapply(.SD, max),
                              .SDcols = output_vars,
                              by=list(id_pixel)]

  dt_output_sum <- dt_hottest[, lapply(.SD, sum),
                              .SDcols = output_vars,
                              by=list(id_pixel)]

  dt_pixelsNA <- data.table::as.data.table(matrix(rep(NA_cells,each=length(dt_output_max)-1),
                                      ncol=length(dt_output_max)-1, byrow = TRUE))

  dt_pixelsNA[which(!is.na(dt_pixelsNA$V1)),1] <- dt_output_sum[[output_vars[1]]]
  dt_pixelsNA[which(!is.na(dt_pixelsNA$V2)),2] <- dt_output_max[[output_vars[2]]]

  r_output <- input_raster

  for (i in 1:length(dt_pixelsNA)) {
    r_output[[paste0("output_",i)]] <- dt_pixelsNA[[i]]
  }

  r_output <- r_output[[-1]]

  # extract the values of the raster with the SCOPE model outputs into a vector map (polygon)
  map_output <- data.table::as.data.table(exactextractr::exact_extract(r_output,
                                                           Input_vector,
                                                           extract_fun))

  names(map_output) <- output_vars

  map_output$Urban_ET <-  (map_output$ET * (Input_vector[[veg_fraction]])/100)

  # include the values into a vector map
  map_cooling  <- Input_vector["geometry"] # only the geometry of multipolygon object

  map_cooling$Urban_ET_daily  <- map_output$Urban_ET

  # create the Evapotranspirative cooling index (ECoS) based on the hottest day
  map_cooling$ECoS <- scales::rescale(
    (map_output$Urban_ET - min(map_output$Urban_ET, na.rm=T))/
      (max(map_output$Urban_ET,na.rm=T) - min(map_output$Urban_ET,na.rm=T))
    , to = c(0,1))

  # create an index for the soil temperature under vegetation in the hottest day (radiation cooling effect)
  # correct the radiation cooling index (RCoS) to urban environment using vegetation fraction
  map_cooling$RCoS <- scales::rescale(1-(
    (map_output$Tsave - min(map_output$Tsave,na.rm=T))/
      (max(map_output$Tsave,na.rm=T)-min(map_output$Tsave,na.rm=T))),
    to = c(0,1))* (Input_vector[[veg_fraction]]/100)

  # calculate the greening cooling index as the average of RCoS and ECoS
  map_cooling$GCoS <- ((map_cooling$RCoS + map_cooling$ECoS)/2)

  return(map_cooling)

}

