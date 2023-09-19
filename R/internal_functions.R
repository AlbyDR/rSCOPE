#' internal functions
#'
#' This are functions used inside of otherfunctions.
# Kanda_zd
Kanda_zd <- function(pai, fai, zH, zstd, zHmax){
  Alph <- 4.43
  Beet <- 1.0
  k <- 0.4
  Ao <- 1.29
  Bo <- 0.36
  Co <- -0.17
  Cd = 1.2
  z_d_output <- (1+ (Alph^(-pai)) * (pai-1))*zH
  X <- (zstd+zH)/zHmax
  if(!is.na(X)){
    if(X >0 & X <= 1){
      z_d_output <- ((Co*(X^2))+((Ao*(pai^Bo)) -Co)*X)*zHmax
    }else{
      z_d_output <- (Ao*(pai^Bo))*zH
    }
  }else{
    z_d_output <- (Ao*(pai^Bo))*zH
  }

  return(z_d_output)
}

# Kanda_z0
Kanda_z0 <- function(fai, pai, zstd, zH, zHmax){
  Alph <- 4.43
  Beet <- 1.0
  k <- 0.4
  A1 <- 0.71
  B1 <- 20.21
  C1 <- -0.77
  Cd = 1.2
  # THe basic zd from McDonald is needed for the calculation of the z0Mac
  z_d_output <- (1+ (Alph^(-pai)) * (pai-1))*zH
  z0Mac <- (zH*(1-z_d_output/zH)*exp(-(0.5*(Cd/k^2)*(1-(z_d_output/zH))*fai)^-0.5))
  # This z0Mac is than adjusted by the Kanda method
  Y <- (pai*zstd/zH)
  if(!is.na(Y)){
    if(Y >= 0){
      z_0_output <- ((B1*(Y^2))+(C1*Y)+A1)*z0Mac
    }else{
      z_0_output <- A1*z0Mac
    }
  }else{
    z_0_output <- A1*z0Mac
  }
  return(z_0_output)
}

# Running mean code
running_mean <- function(data){
  if(nrow(data) != 360){
    stop("The data should have 360 rows, one for each degree!")
  }
  output_mean <- data.table::data.table(matrix(as.numeric(), ncol = ncol(data), nrow = 360))
  names(output_mean) <- names(data)
  for(i in 1:360){
    for(j in 2:ncol(data)){
      if(i <5){
        output_mean[i,j] <- mean(unlist(data[c(((360+i-5):360),(0:(i+5))),j]))
      }else if(i > 355 & i < 360){
        output_mean[i,j] <- mean(unlist(data[c(((i-5):i),(i+1):360,(1:(5+i-360))),j]))
      }else if(i == 360){
        output_mean[i,j] <- mean(unlist(data[c((355:360),(1:5)),j]))
      }else{
        output_mean[i,j] <- mean(unlist(data[c((i-5):(i+5)),j]))
      }
    }
  }
  output_mean[,1] <- c(1:360)
  return(output_mean)
}

# average_z_by wd
average_z_by_wd <- function(wd, v_sd = NULL, z_data, deg_column, Kotthaus = F){
  # create the winddirection range where to average over
  if(Kotthaus == F){
    # in case that the wd+v_sd is above 360 degree
    if(round(wd,0) >360){
      max_wd <- round(round((wd)-360,0),0)
      min_wd <- round(wd,0)
    }else if(round(wd,0) < 1){ # and in case that the wd+v_sd is below 1 deg
      min_wd <- round(round((wd)+360,0))
      max_wd <- round(wd,0)
    }else{
      min_wd <- round(wd,0)
      max_wd <- round(wd,0)
    }
  }else{
    # in case that the wd+v_sd is above 360 degree
    if(round(wd+v_sd,0) >360){
      max_wd <- round(round((wd+v_sd)-360,0),0)
      min_wd <- round(wd-v_sd,0)
    }else if(round(wd-v_sd,0) < 1){ # and in case that the wd+v_sd is below 1 deg
      min_wd <- round(round((wd-v_sd)+360,0))
      max_wd <- round(wd+v_sd,0)
    }else{
      min_wd <- round(wd-v_sd,0)
      max_wd <- round(wd+v_sd,0)
    }
  }

  # select the z_data according to max_wd and min_wd
  output_1 <- mean(z_data$zd[which(z_data$deg <= max_wd &
                                     z_data$deg >= min_wd)])
  output_2 <- mean(z_data$z0[which(z_data$deg <= max_wd &
                                     z_data$deg >= min_wd)])
  return(c(output_1,output_2))
}

get_X_Y_coordinates <- function(x) {
  sftype <- as.character(sf::st_geometry_type(x, by_geometry = FALSE))
  if(sftype == "POINT") {
    xy <- as.data.frame(sf::st_coordinates(x))
    dplyr::bind_cols(x, xy)
  } else {
    x
  }
}


sf_save <- function(z, fname) {
  ifelse(!dir.exists(fname), dir.create(fname), "Folder exists already")
  ff <- paste(file.path(fname, fname), export_format, sep = ".")
  purrr::walk(ff, ~{ sf::st_write(z, .x, delete_dsn = TRUE)})
  saveRDS(z, paste0(file.path(fname, fname), ".rds"))

}

# funtion to resample
resample_to_footprint = function(r, footprint_rast) {
  r_new = raster::crop(x=r, y=raster::extent(footprint_rast))  # first crop
  r_new = raster::projectRaster(r_new, footprint_rast) # reproject
  return(r_new)
}

set_names <- function(x, colnames) {
  # Do some checks
  if (! "data.frame" %in% class(x)) stop("Argument must be a data.frame")
  if (class(colnames) != "character") stop("New names must be character")
  if (length(names(x)) != length(colnames)) stop("Invalid nr. of new names")
  # Actual replacement of  column names
  names(x) <- colnames
  return(x)
}


#################################################################################################
# function to download GCH Canopy Height
#################################################################################################

get_GCH <- function(
    city_border = NA,
    i_city = NA,
    N_S_degree = NA,
    W_E_degree = NA,
    dest_file = NA

){

  degree_N_S <- seq(0, 180, 3)[which(data.table::between(round(N_S_degree), seq(0, 177, 3), seq(3, 180, 3)))]
  degree_W_E <- seq(0, 180, 3)[which(data.table::between(round(W_E_degree), seq(0, 177, 3), seq(3, 180, 3)))]

  for (i in 1:length(degree_N_S)) {
    degree_N_S[i] <- ifelse(as.numeric(degree_N_S[i]) < 10, paste0("0", degree_N_S[i]), degree_N_S[i])
  }

  for (i in 1:length(degree_W_E)) {
    degree_W_E[i] <- ifelse(as.numeric(degree_W_E[i]) < 10, paste0("00", degree_W_E[i]),  paste0("0",degree_W_E[i]))
  }

  url <- ifelse(W_E_degree < 0,
                paste0("https://share.phys.ethz.ch/~pf/nlangdata/ETH_GlobalCanopyHeight_10m_2020_version1/3deg_cogs/ETH_GlobalCanopyHeight_10m_2020_",
                       "N", degree_N_S, "W", "003","_Map.tif"),
                paste0("https://share.phys.ethz.ch/~pf/nlangdata/ETH_GlobalCanopyHeight_10m_2020_version1/3deg_cogs/ETH_GlobalCanopyHeight_10m_2020_",
                       "N", degree_N_S, "E", degree_W_E,"_Map.tif"))

  for (i in 1:length(url)) {
    utils::download.file(url[i],
                         destfile = paste0(dest_file, "GCH_map_", names(city_border)[i_city], "_", i, ".tif"),
                         method="curl")
  }

  print(url)

}
##############################################################################################
##################################################################################

##################################################################################
# function - open the GCH downloaded
#######################################################################################
open_GCH <- function(
    city_name = NA,
    crop_area = NA,
    list_GCH = NA,
    patch_file = NA

){

  canopy_height <- NULL

  if(length(list_GCH) > 1){

    canopy_height_list <- list(terra::rast(paste0(patch_file, "GCH_map_", city_name, "_1",".tif")),
                               #terra::rast(paste0(patch_file, "GCH_map_", city_name, "_2",".tif")),
                               terra::rast(paste0(patch_file, "GCH_map_", city_name, "_3",".tif")),
                               terra::rast(paste0(patch_file, "GCH_map_", city_name, "_2",".tif"))
                               )

    rsrc <- terra::sprc(canopy_height_list)
    merge <- terra::merge(rsrc)

    canopy_height <- terra::crop(merge, crop_area)

  }else{

    single <- terra::rast(paste0(patch_file, "GCH_map_", city_name, "_1",".tif"))

    canopy_height <- terra::crop(single, crop_area)

  }

  return(canopy_height)

}

##################################################################################
  # function - Impervious LULC
##################################################################################
get_nonimpervious <- function(
    file_patch = NA,
    file_pattern = "_v020.tif$",
    bbox = NA,
    prj = "+proj=longlat +datum=WGS84 +no_defs"

){

  Impervious_list <- list.files(path = file_patch, pattern = file_pattern, full.names = TRUE)

  raster_list <- lapply(Impervious_list, terra::rast)
  raster_list <- lapply(raster_list, "+", 0)
  raster_list <- lapply(raster_list, classify, cbind(255, 0))
  rsrc <- terra::sprc(raster_list)
  impervious <- terra::merge(rsrc)

  bbox_laea <- sf::st_transform(bbox, "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs")

  impervious_prj <- terra::crop(impervious, bbox_laea)

  impervious_prj <- terra::project(impervious_prj, prj_utm)

  impervious <- (1-impervious_prj/100)

  names(impervious) <- "non-impervious"

  return(impervious)

}



##################################################################################
##################################################################################
# function - daily LAI for a city/location
##################################################################################
##################################################################################
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
    terra::time(LAI_daily[[i]]) <- lubridate::ymd(tsLAI_names[i])
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
 # function - convert the input raster into  the FP raster
##################################################################################

raster_to_FPgrid <- function(
    # FP parameters for Calculate from FREddyPro
  fetch = NA,
  grid = 200,
  utm_x_lon = NA,
  utm_y_lat = NA,
  ### Raster
  water_polygons = NA,
  input_raster = NA,
  prj = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"
  # if a data frame is used include a one layer raster template that match the df
){ # If TRUE crop and reproject for the footprint resolution/extent

  footprint <- FREddyPro::exportFootprintPoints(FREddyPro::Calculate(fetch = fetch,
                                                                     height = 40,
                                                                     grid = grid,
                                                                     speed = 2.58,
                                                                     direction = 194,
                                                                     uStar = 0.134,
                                                                     zol = 1.06,
                                                                     sigmaV = sqrt(0.094)*5),
                                                xcoord = utm_x_lon,
                                                ycoord = utm_y_lat)
  # convert to terra (utm)
  footprint <- terra::rast(footprint, type = "xyz",
                           crs = prj)

  input_fp_raster <- terra::crop(input_raster, terra::ext(footprint))

  #input_fp_raster <- terra::mask(input_fp_raster, water_polygons, inverse = T)

  fp_raster <- terra::project(input_fp_raster, footprint)

  #fp_raster <- terra::mask(fp_raster, water_polygons, inverse = T)

  return(fp_raster)
}


##################################################################################
 # function - get the FP probability raster with zol as a function of = (zm-zd)/L
##################################################################################
get_FPprob <- function(
    fetch = NA,
    grid = NA,
    zm = NA,
    zd = NA,
    ws = NA,
    wd = NA,
    uStar = NA,
    L = NA,
    v_var = NA,
    u_var_factor = NA,
    utm_x_lon = NA,
    utm_y_lat = NA,
    zol = zol,
    prob = NA,
    timestamp = NA,
    prj = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"
){

  ### make the footprint calculation according to Kormann and Meixner (2001) from FREddyPro
  footprint_matrix <- FREddyPro::exportFootprintPoints(FREddyPro::Calculate(fetch = fetch,
                                                                            height = zm-zd,
                                                                            grid = grid,
                                                                            speed = ws,
                                                                            direction = wd,
                                                                            uStar = uStar,
                                                                            zol = (zm-zd)/L,
                                                                            sigmaV = sqrt(v_var*u_var_factor)),
                                                       xcoord = utm_x_lon,
                                                       ycoord = utm_y_lat)

  # convert to terra (utm)
  footprint <- terra::rast(footprint_matrix, type = "xyz", crs = prj)
  # input_raster <- terra::crop(input_raster, terra::extent(footprint))

  prob_value <- terra::global(footprint, quantile, probs = prob, names = FALSE, na.rm = TRUE)[[1]]

  # reduce the FP area to the elipse that the probability is equal to the input FP_probs (suggested 0.99)
  footprint <- terra::app(footprint, fun = function(x){ x[x <= prob_value] <- NA; return(x)} )

  terra::time(footprint) <- timestamp

  names(footprint) <- REddyProc::POSIXctToBerkeleyJulianDate(timestamp)

  return(footprint)

}

##################################################################################
 # function - get the FP probability raster with zol = z.d.L already calculated
##################################################################################
get_FPprobII <- function(
    fetch = NA,
    grid = NA,
    zm = NA,
    zd = NA,
    ws = NA,
    wd = NA,
    uStar = NA,
    z.d.L = NA,
    v_var = NA,
    u_var_factor = NA,
    utm_x_lon = NA,
    utm_y_lat = NA,
    prob = NA,
    timestamp = NA,
    prj = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"
){

  ### make the footprint calculation according to Kormann and Meixner (2001) from FREddyPro
  footprint_matrix <- FREddyPro::exportFootprintPoints(FREddyPro::Calculate(fetch = fetch,
                                                                            height = zm-zd,
                                                                            grid = grid,
                                                                            speed = ws,
                                                                            direction = wd,
                                                                            uStar = uStar,
                                                                            zol = z.d.L,
                                                                            sigmaV = sqrt(v_var*u_var_factor)),
                                                       xcoord = utm_x_lon,
                                                       ycoord = utm_y_lat)

  # convert to terra (utm)
  footprint <- terra::rast(footprint_matrix, type = "xyz", crs = prj)
  # input_raster <- terra::crop(input_raster, terra::extent(footprint))

  prob_value <- terra::global(footprint, quantile, probs = prob, names = FALSE, na.rm = TRUE)[[1]]

  # reduce the FP area to the elipse that the probability is equal to the input FP_probs (suggested 0.99)
  footprint <- terra::app(footprint, fun = function(x){ x[x <= prob_value] <- NA; return(x)} )

  terra::time(footprint) <- timestamp

  names(footprint) <- REddyProc::POSIXctToBerkeleyJulianDate(timestamp)

  return(footprint)

}
########################################
