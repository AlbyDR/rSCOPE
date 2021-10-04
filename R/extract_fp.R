#' extract_fp
#'
#' This is a function to extract footprint FP for inputs or outputs for the EC towers source area.
#' It extracts the FP average (i.e. sum of probability) for inputs in a multilayer stack or brick raster, or
#' in a data frame (timestamp, output values per "pixel number").
#' @param fetch source area maximum distance in meters for the footprint (radious).
#' @param zm EC measurement height above ground (in meter)
#' @param grid the grid size (square)
#' @param speed wind speed
#' @param direction wind direction
#' @param uStar friction velocity
#' @param zd roughness length
#' @param v_var sigma var
#' @param L stability parameter
#' @param lon longitude of the EC tower
#' @param lat latitude of the EC tower
#' @param timestamp datetime (Lubridate)
#' @param FP_probs probability to keep as the main ellipse area - suggested 0.99
#' @param fix_time logical, if the raster layers are timestamps, change to FALSE and include "[[i]]" after the "input_raster[[i]]".
#' @param input_raster if a data frame is used include a one layer raster template that match the df
#' @param resample_raster logical, if TRUE the input_raster should be resample to the FP.
#' @param df_input logical, default FALSE, if TRUE the data come from a data frame rather than a multilayer raster
#' @param df_dataset if df_input=TRUE, the dataframe name (2 variables - datetime and the output)
#' @param df_mask  a vector of NA and Non-NA if the data frame and raster layer do not match as result of a mask (otherwise the df is assumed)
#' @param extract_list logical, default FALSE, if TRUE extract also the values at tower location, full fp extent and buffer
#' @param buffer # buffer diameter value (in meters) to be extracted, default 500m
#' @return It returns a data frame (or vector) with the FP average extracted from the tower's location.
#' @examples
#' ## Examples of uses of the extract_fp function
#' # fix time and no resample (as before) - Atlas Maps
#' # fix time resample from a map of entire the Berlin - Atlas Maps
#' # varying in time using a multilayer raster stacked hourly (if daily change timestamp from ymd_hms to ymd)
#' # varying in time using a data frame with all pixels values and timestamp together - modeled ET
#'
#' n = 8760
#' # ROTH location, fix in time and no resample. The raster has to be cropped and reproject to FP before
#'
#' FP_ROTH_extrated <- data.frame(t(sapply(1:n, function(i) extract_fp(
#'   fetch = 1000, zm = 40 , grid = 200, lon = 385566.5, lat = 5813229, # constants
#'   speed = na.approx(EC_ROTH$ws)[i], # FP input variables
#'   direction = na.approx(EC_ROTH$wd)[i],
#'   uStar = na.approx(EC_ROTH$u.)[i],
#'   zd = na.approx(EC_ROTH$zd)[i],
#'   v_var = na.approx(EC_ROTH$v_var)[i],
#'   L = na.approx(EC_ROTH$L)[i],
#'   timestamp = EC_ROTH$timestamp[i],
#'   FP_probs = 0.9925, # FP probability
#'   fix_time = TRUE, # default
#'   resample_raster = FALSE,
#'   input_raster = atlas_maps_ROTH_FP # raster model inputs - utm
#' )) ))
#'
#' FP_ROTH_extrated
#'
#' FP_ROTH_extrated$timestamp <- EC_ROTH$timestamp[1:n]
#' summary(FP_ROTH_extrated)
#'
#'
#' # TUCC location, fix in time and resample from a Berlin map
#' plot(atlas_r_maps[[1]])
#'
#' FP_TUCC_atlas <- data.frame(t(sapply(1:n, function(i)
#' extract_fp(
#'   fetch = 1000, zm = 56 , grid = 200, lon = 386525.1, lat = 5819332,  #constants
#'   speed = na.approx(EC_TUCC$ws)[i],# FP input variables
#'   direction = na.approx(EC_TUCC$wd)[i],
#'   uStar = na.approx(EC_TUCC$u.)[i],
#'   zd = na.approx(EC_TUCC$zd)[i],
#'   v_var = na.approx(EC_TUCC$v_var)[i],
#'   L = na.approx(EC_TUCC$L)[i],
#'   timestamp = EC_TUCC$timestamp[i],
#'   FP_probs = 0.9925,# FP probability
#'   fix_time = TRUE, # default - raster info
#'   resample_raster = TRUE,
#'   input_raster = atlas_r_maps # raster model inputs (utm)
#' )) ))
#'
#' FP_TUCC_atlas
#' FP_TUCC_atlas$timestamp <- EC_TUCC$timestamp[1:n]
#' summary(FP_TUCC_atlas)
#'
#' # TUCC vary in time using a stack rasters (need to include "[[i]]" after the raster name)
#' LAI_FP_noNA <- stack("LAI_FP_noNA.gri")
#'
#' FP_TUCC_LAI <- sapply(1:n, function(i)
#' extract_fp(
#'   fetch = 1000, zm = 56 , grid = 200, lon = 386525.1, lat = 5819332,  # FP input constants
#'   speed = na.approx(EC_TUCC$ws)[i], # FP input variables
#'   direction = na.approx(EC_TUCC$wd)[i],
#'   uStar = na.approx(EC_TUCC$u.)[i],
#'   zd = na.approx(EC_TUCC$zd)[i],
#'   v_var = na.approx(EC_TUCC$v_var)[i],
#'   L = na.approx(EC_TUCC$L)[i],
#'   timestamp = EC_TUCC$timestamp[i],
#'   FP_probs = 0.9925,# FP probability
#'   fix_time = FALSE,
#'   input_raster = LAI_FP_noNA[[i]], #  is need to include [[i]] after the raster name
#'   resample_raster = TRUE,
#'   extract_list = TRUE, # if TRUE extract also the point, extent and buffer
#'   buffer = 500  # 500m buffer
#' ))
#'
#' FP_TUCC_LAI
#
#' FP_TUCC_LAI <- tibble("timestamp" = EC_TUCC$timestamp[1:n],
#'                       "LAI_FP" = unlist(FP_TUCC_LAI[1,]),
#'                       "LAI_point" = unlist(FP_TUCC_LAI[2,]),
#'                       "LAI_extent" = unlist(FP_TUCC_LAI[3,]),
#'                       "LAI_buffer" = unlist(FP_TUCC_LAI[4,]) )
#'
#' summary(FP_TUCC_LAI)
#'
#' # when extract_list FALSE
#'  FP_TUCC_LAI <- data.frame("timestamp"=EC_TUCC$timestamp[1:n], "LAI" = FP_TUCC_extrated)
#'  FP_TUCC_LAI
#'  summary(FP_TUCC_LAI)
#'
#' # TUCC varying in time using a data frame with all pixels values and timestamp together
#'
#' # str(SCOPE_Berlin) # data frama exemple
#' # $ timestamp        : POSIXct[1:9469560], format: "2019-01-01 00:00:00" "2019-01-01 01:00:00"
#' # $ id_time          : num [1:9469560] 1 2 3 4 5 6 7 8 9 10 ...
#' # $ id_pixel         : num [1:9469560] 28 28 28 28 28 28 28 28 28 28 ...
#' # $ SCOPE_ET         : num [1:9469560] 0.00408 0.00484 0.00475 0.00465 0.00507 ...
#' # $ SCOPE_ETsoil     : num [1:9469560] 0.00372 0.00444 0.00436 0.00426 0.00466 ...
#' # $ SCOPE_ETcanopy   : num [1:9469560] 0.000359 0.000398 0.000391 0.00039 0.00041 ...
#'
#' plot(ETmap_raster)
#'
#' FP_TUCC_ET <- sapply(1:n, function(i)
#' extract_fp(
#'   fetch = 1000, zm = 56 , grid = 200, lon = 386525.1, lat = 5819332,
#'   speed = na.approx(EC_TUCC$ws)[i],
#'   direction = na.approx(EC_TUCC$wd)[i],
#'   uStar = na.approx(EC_TUCC$u.)[i],
#'   zd = na.approx(EC_TUCC$zd)[i],
#'   v_var = na.approx(EC_TUCC$v_var)[i],
#'   L = na.approx(EC_TUCC$L)[i],
#'   timestamp = EC_TUCC$timestamp[i],
#'   FP_probs = 0.9925,
#'   fix_time = FALSE,
#'  input_raster = ETmap_raster, # template raster with one layer that match the df pixel values
#'   resample_raster = TRUE,
#'   # data.frames
#'   df_input = TRUE,
#'   df_mask = ET_df, # if the area modeled was masked, include a vector with NA values
#'   df_dataset = data.frame("datetime" = SCOPE_Berlin$timestamp, # a variable with datetime and output is required
#'                           "output" = SCOPE_Berlin$SCOPE_ET),    # do NOT change the names datetime and output
#'   extract_list = TRUE,
#'   buffer = 500
#' ))
#'
#' FP_TUCC_ET
#' FP_TUCC_ET <- tibble("timestamp" = EC_TUCC$timestamp[1:n],
#'                      "ET_FP" = unlist(FP_TUCC_ET[1,]),
#'                      "ET_point" = unlist(FP_TUCC_ET[2,]),
#'                      "ET_extent" = unlist(FP_TUCC_ET[3,]),
#'                      "ET_buffer" = unlist(FP_TUCC_ET[4,]) )
#' summary(FP_TUCC_ET)
#'
#' @export
extract_fp <- function(
  # FP parameters for Calculate from FREddyPro
  fetch, zm, grid, speed, direction, uStar, zd, v_var, L,
  # tower position and datetime for exportFootprintPoints
  lon, lat, timestamp,
  # probability to keep as the main ellipse area - suggested 0.99
  FP_probs = 0.99,
  ### Raster
  # Stack/brick raster with the layers to be extracted
  fix_time = TRUE,        # if the raster layers are timestamps, change to FALSE and include [[i]] after the input_raster[[i]]
  input_raster,           # if a data frame is used include a one layer raster template that match the df
  resample_raster = TRUE, # if the input_raster should be resample to the FP
  ### Convert a data frame to Raster
  df_input = FALSE,       # if the data come from a data frame rather than a multilayer raster
  df_dataset,             # the dataframe name (2 variables - datetime and the output)
  df_mask = df_dataset,   # a vector of NA when data frame and raster layer dont match as result of a mask (otherwise the df is assumed)
  extract_list = FALSE,   # If TRUE extract also the values at tower location, full fp extent and buffer
  buffer = 500            # buffer diameter to be extracted, default 500m
){ # If TRUE crop and reproject for the footprint resolution/extent
  ### make the footprint calculation according to Kormann and Meixner (2001) from FREddyPro
  footprint <- FREddyPro::exportFootprintPoints(FREddyPro::Calculate(fetch = fetch,
                                                                     height = zm,
                                                                     grid = grid,
                                                                     speed = speed,
                                                                     direction = direction,
                                                                     uStar = uStar,
                                                                     zol = (zm-zd)/L,
                                                                     sigmaV = sqrt(v_var)),
                                                xcoord = lon, ycoord = lat)
  # convert to raster (utm)
  footprint <- raster::rasterFromXYZ(xyz = footprint,
                                     crs = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

  # reduce the FP area to the elipse that the probability is equal to the input FP_probs (suggested 0.99)
  footprint[which(raster::values(footprint) <= raster::quantile(footprint, probs = FP_probs, names = FALSE))] <- NA
  raster::values(footprint) <- raster::values(footprint)*1/sum(raster::values(footprint), na.rm = TRUE)

  ### if is a multilayer raster fix in time
  if(fix_time == TRUE){
    ## if the input_raster need to be cropped and resampled
    if(resample_raster == TRUE){
      input_raster <- raster::crop(input_raster, raster::extent(footprint))
      #input_raster <- raster::disaggregate(input_raster, dim(footprint)[1]/2)
      input_raster <- raster::projectRaster(input_raster, footprint)
      # multiply the FP probability to all layers in the raster
      input_fp_raster <- input_raster*footprint
      # extract the average (i.e. sum) of all the layers in the raster
      input_FP <- sapply(1:raster::nlayers(input_raster), function(i) sum(raster::values(input_fp_raster[[i]]), na.rm = TRUE))
      input_FP <- c(timestamp, input_FP)
      names(input_FP) <- c("timestamp", names(input_raster))
      ## if the input_raster is already in the same resolution and extent of the FP
    }else{
      # multiply the FP probability to all layers in the raster
      input_fp_raster <- input_raster*footprint
      # extract the average (i.e. sum) of all the layers in the raster
      input_FP <- sapply(1:raster::nlayers(input_raster), function(i) sum(raster::values(input_fp_raster[[i]]), na.rm = TRUE))
      input_FP <- c(timestamp, input_FP)
      names(input_FP) <- c("timestamp", names(input_raster))
    }
    ### if is a multilayer raster or a data frame of pixel values that vary on time (timestamp)
  }else{
    ## if the input is data frame of pixel values rather than stack/brick raster
    if(df_input == TRUE){
      # filter values for a simple timestamp
      ET_timestamp <- dplyr::filter(df_dataset, "datetime" == timestamp)$output
      # df_dataset %>%
      #   dplyr::filter(datetime == timestamp) %>%
      #   dplyr::select(output) -> ET_timestamp
      # if the grid/raster was masked (e.g. Berlin borders) include the NA cells to reconstruct the template raster
      df_mask[!is.na(df_mask)] <- ET_timestamp[,1] # include the df values were is not NA
      raster::values(input_raster) <- df_mask[,1]  # include the df values with NA in the template raster

      # resample the template raster to the FP
      input_raster <- raster::crop(input_raster, raster::extent(footprint))
      input_raster <- raster::disaggregate(input_raster, dim(footprint)[1]/2)
      input_raster <- raster::projectRaster(input_raster, footprint)
      # multiply the FP probability to all layers in the raster
      input_fp_raster <- input_raster*footprint
      # extract the average (i.e. sum) of all the layers in the raster
      input_FP <- sum(raster::values(input_fp_raster), na.rm = TRUE)
      ## extract the point location, FP extent and buffer as a list with FP
      if(extract_list == TRUE){
        # extract the average (i.e. sum) of all the layers in the raster
        input_FP <- sum(raster::values(input_fp_raster), na.rm = TRUE)
        # create a list with the extracted at the point location, FP extent and 500 buffer
        input_point <- raster::extract(input_raster, data.frame(x = lon, y = lat))
        input_extent <- raster::extract(input_raster, raster::extent(footprint), weights = TRUE, fun=mean, na.rm = TRUE)
        input_buffer <- raster::extract(input_raster, data.frame(x = lon, y = lat), buffer = 500,
                                        fun = mean, na.rm = TRUE, df = TRUE)[1,2]
        input_FP <- list(input_FP, input_point, input_extent, input_buffer)
      }else{
        # extract the average (i.e. sum) of all the layers in the raster
        input_FP <- sum(raster::values(input_fp_raster), na.rm = TRUE)
      }
      ## if the time-series is already a raster
    }else{
      # resample the template raster to the FP
      input_raster <- raster::crop(input_raster, raster::extent(footprint))
      input_raster <- raster::disaggregate(input_raster, dim(footprint)[1]/2)
      input_raster <- raster::projectRaster(input_raster, footprint)
      # extract the average (i.e. sum) of all the layers in the raster
      input_fp_raster <- input_raster*footprint
      ## extract the point location, FP extent and buffer as a list with FP
      if(extract_list == TRUE){
        # extract the average (i.e. sum) of all the layers in the raster
        input_FP <- sum(raster::values(input_fp_raster), na.rm = TRUE)
        # create a list with the extracted at the point location, FP extent and 500 buffer
        input_point <- raster::extract(input_raster, data.frame(x = lon, y = lat))
        input_extent <- raster::extract(input_raster, raster::extent(footprint), weights = TRUE, fun=mean, na.rm = TRUE)
        input_buffer <- raster::extract(input_raster, data.frame(x = lon, y = lat), buffer = 500,
                                        fun = mean, na.rm = TRUE, df = TRUE)[1,2]
        input_FP <- list(input_FP, input_point, input_extent, input_buffer)
      }else{
        # create a list with the extracted at the point location, FP extent and 500 buffer
        input_FP <- sum(raster::values(input_fp_raster), na.rm = TRUE)
      }
    }
  }
  ### return a data frame (or vector) with the FP average extracted from the tower location
  return(input_FP)
}
