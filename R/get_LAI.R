# get_LAI.R 
# function 1 - download the images


get_LAI_links <- function(
    user_VITO = NA,
    pass_VITO = NA,
    destfile = NA,
    start_date = NA,
    end_date = NA  
){
  
  url_list <- paste0("https://",user_VITO,":",pass_VITO,"@","land.copernicus.vgt.vito.be/manifest/lai300_v1_333m/manifest_cgls_lai300_v1_333m_latest.txt")
  
  download.file(url_list, 
                destfile = paste0(destfile, "lai/", "LAI_list.txt"), 
                method="curl")
  
  LAI_list <- utils::read.delim(paste0(destfile, "lai/", "LAI_list.txt"),
                                header = FALSE)
  
  LAI_str <- sub("0000_GLOBE.*", "", LAI_list$V1)
  LAI_str <- stringr::str_sub(LAI_str, start= -8)
  
  LAI_dates <- data.table::as.data.table(lubridate::ymd(LAI_str))
  LAI_dates$id <- 1:length(LAI_dates$V1)
  
  dupl_dates <- LAI_dates[!duplicated(LAI_dates$V1),]
  
  id_list <- which(data.table::between(LAI_dates$V1, start_date, end_date))
  id_list <- id_list[id_list %in% dupl_dates$id]
  
  LAI_links <- LAI_list[id_list,1]
  link_dates <- LAI_str[id_list]
  
  LAI_links <- stringr::str_replace(LAI_links,"https://land", paste0("https://",user_VITO,":",pass_VITO,"@","land"))
  
  list_obj <- list(LAI_links, link_dates)
  
  return(list_obj)
  
}


# LAI_daily
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
##################################################################################
##################################################################################
