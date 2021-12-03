#' split_df
#'
#' This is a function to divide the SCOPE inputs per period, parts or pixels to run the simulations.
#' @param df a data.frame with a datetime variable required to SCOPE (BerkeleyJulianDate) and pixel numbers
#' @param split_by for period use "season" for quarters, "month", "week", "doy" for day of the year. For equal parts use "parts" and for a one or more pixels use "id_pixel".
#' @param n_parts if "parts", an number to divide into
#' @param name_file for the file name start with
#' @param folder_files directory to be save
#' @param pixel logical, if TRUE split by pixel, default is FALSE
#' @param pixel_id if pixel is TRUE, the id number of the pixel(s)
#' @return It will save the split files in the SCOPE directory.
#' @examples
#' split and save in different files to facilitate the processing
#' ## divided by parts
#' df_splited <- split_df(df = Inputs_Berlin_masked,
#'                       split_by = "parts", #season #month, #week, #doy , #parts
#'                       n_parts = 2, ### if parts , how many?
#'                       name_file = "Inputs_",
#'                       folder_files = "D:/SCOPE-master/input/dataset for_verification/")
#'
#' ## divided by period
#' df_splited <- split_df(df = Inputs_Berlin_masked,
#'                       split_by = "season",
#'                       name_file = "Inputs_",
#'                       folder_files = "D:/SCOPE-master/input/dataset for_verification/")
#'
#' ## divided by pixel
#' raster::extract(krg_mask, tower_points_utm, buffer = 1000) # near the EC_tower
#'
#' df_splited <- split_df(df = Inputs_Berlin_masked,
#'                       split_by = "id_pixel",
#'                       pixel_id = c(1169, 882), # ROTH and TUCC
#'                       name_file = "Inputs_",
#'                       folder_files = "D:/SCOPE-master/input/dataset for_verification/")
#'
#' df_splited
#'
#' @export
split_df <- function(
  df,
  split_by,
  n_parts,
  name_file = "Inputs_",
  folder_files,
  pixel = FALSE,
  pixel_id
){
  df$season <- lubridate::quarter(REddyProc::BerkeleyJulianDateToPOSIXct(df$t, tz = "UTC"))
  df$month <- lubridate::month(REddyProc::BerkeleyJulianDateToPOSIXct(df$t, tz = "UTC"))
  df$week <- lubridate::week(REddyProc::BerkeleyJulianDateToPOSIXct(df$t, tz = "UTC"))
  df$doy <- lubridate::yday(REddyProc::BerkeleyJulianDateToPOSIXct(df$t, tz = "UTC"))
  df$parts <- rep(seq(1:n_parts), each = (length(df$t)/n_parts))

  if(split_by == "id_pixel"){
    df <- dplyr::filter(df, df[,split_by] == pixel_id)
    df_splited <- split(df, df[split_by])

    lapply(1:length(df_splited), function(x){
      readr::write_csv(df_splited[[x]], file = paste0(folder_files, name_file, split_by, pixel_id[x],".csv"))})

    name_file <-  lapply(1:length(df_splited), function(i) paste0(folder_files, name_file,
                                                                  split_by, pixel_id[i], ".csv"))
  }else{
    df_splited <- split(df, df[split_by])

    lapply(1:length(df_splited), function(x){
      readr::write_csv(df_splited[[x]], file = paste0(folder_files, name_file, split_by, x, ".csv"))})

    name_file <-  lapply(1:length(df_splited), function(i) paste0(folder_files, name_file,
                                                                  split_by, i, ".csv"))
  }

  print("Done!")

  return(name_file)
}
