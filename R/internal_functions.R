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
