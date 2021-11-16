#' prec_window
#'
#' This is a function to get the predictions for a specific output simulated by SCOPE and calculate the accuracy.
#' @param prec_vec a vector with the volume of precipitation.
#' @param timestamp timestamp datetime.
#' @param max_dry_hours max possible number of hours without raining.
#' @return The result is a data.frame with all the number of hours after raining and the precipitaion volume in mm
#' @examples
#' Examples of uses of the function
#' library(tidyverse)
#'
#' Input_Berlin_grid %>%
#'  filter(id_pixel == 1169) %>%
#'  mutate(timestamp=REddyProc::BerkeleyJulianDateToPOSIXct(t, tz = "UTC")) %>%
#'  select(timestamp, prec_hour) -> prec_1169
#'
#' prec_window_1169 <- prec_window(prec_vec = prec_1169$prec_hour,
#'                               timestamp = prec_1169$timestamp,
#'                                max_dry_hours = 400)
#'
#' @export
prec_window <- function(prec_vec,
                        max_dry_hours,
                        timestamp,
                        value_on = 0.01
){
  window.prec <- NULL

  for (i in 1:max_dry_hours) {
    window.prec[[i]] <- data.frame(
      dplyr::arrange(data.frame(row = unique(c(which(prec_vec >= value_on) + i))), row),
      hour = i )
    colnames(window.prec[[i]]) <- c("row", paste("hour", i, sep = ""))
  }

  window.prec.0 <- data.frame(
    dplyr::arrange(data.frame(row = unique(c(which(prec_vec >= value_on) + 0))), row),
    "hour0" = 0)

  row_timestamp <- data.frame(timestamp = timestamp)
  row_timestamp$row <- dplyr::row_number(timestamp)
  row_timestamp <- dplyr::left_join(row_timestamp, window.prec.0, by = "row")

  for (i in 1:max_dry_hours) {
    row_timestamp <- dplyr::left_join(row_timestamp, window.prec[[i]], by = "row")
  }

  row_timestamp$prec.window <- max_dry_hours

  for (i in (max_dry_hours-1):0) {
    row_timestamp$prec.window[row_timestamp[i + 3] == i] <- i
  }

  prec_window <- data.frame("timestamp" = timestamp,
                            "dry_hours" = row_timestamp$prec.window,
                            "prec_mm" = prec_vec)

  return(prec_window)
}
