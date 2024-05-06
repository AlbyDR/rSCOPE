#' get_accuracy
#'
#' This is a function to get the predictions for a specific output simulated by SCOPE and calculate the accuracy.
#' @param obs_vec for get_accuracy a vector of observed values in the same timestamp as the predictions.
#' @param predictions the name of the file result of the get_predictions function.
#' @param metric_function for get_accuracy is possible to select the metric,
#' @return The result is a table with the accuracy metrics for all simulation starting with that name.
#' @examples
#' Examples of uses of the get_predictions function
#' ###############
#' library(tidyverse)
#'
#' possible metrics: yardstick::rmse for Root mean squared error,
#'                   yardstick::mae for Mean absolute error,
#'                   yardstick::msd for Mean signed deviation,
#'                   yardstick::ccc for Concordance correlation coefficient,
#'                   yardstick::mase for Mean absolute scaled error - order by time
#'                   yardstick::rsq for R squared - correlation
#'                   yardstick::rsq_trad for R squared - traditional
#'                   yardstick::rpiq for Ratio of performance to inter-quartile
#'                   yardstick::rpd for Ratio of performance to deviation
#'                   yardstick::iic for Index of ideality of correlation
#'                   yardstick::mpe for Mean percentage error
#'                   yardstick::mape for Mean absolute percent error
#'                   yardstick::smape for Symmetric mean absolute percentage error
#'
#' Get model accuracy for ET corrected
#' Predictions_metrics_1169 <- get_accuracy(obs_vec = EC_ROTH$ET_clean0,
#'                                          predictions = Predictions_pixel_1169,
#'                                          metric_function = yardstick::metric_set(yardstick::rsq,
#'                                                                                  yardstick::rmse,
#'                                                                                  yardstick::mae))
#' Predictions_metrics_1169
#' @export
get_accuracy <- function(
  obs_vec,
  predictions,
  metric_function,
  Filter = FALSE,
  timestamp,
  month_start = 1,
  month_end = 12,
  period = c("day", "dawn_dusk", "night"),
  nu_interations,
  interations = 101,
  dryhours_vec,
  dry_hours = 0,
  neg_vec,
  neg_null = 0,
  pred_neg = 0,
  neg_values = NA,
  lat = 52.46,
  lon = 13.32
){


  if(Filter == TRUE){

    predictions_df <- predictions

    interations_NA <- tibble::tibble(data.frame(sapply(1:length(predictions), function(i) ifelse(nu_interations[i] <= interations, 1, NA))))

    predictions_df <- interations_NA*predictions_df

    negative_NA <- tibble::tibble(data.frame(sapply(1:length(predictions), function(i) ifelse(predictions_df[i] >= pred_neg, 1, neg_values))))

    predictions_df <- negative_NA*predictions_df

    night <- suncalc::getSunlightTimes(date = lubridate::date(timestamp), lat = lat, lon = lon, tz = "UTC")

    night$time <- timestamp
    night$sun <- NULL
    night$sun[night$time>night$nadir] <- "Night" ##seting
    night$sun[night$time>night$night & lubridate::hour(night$time)<lubridate::hour(night$nadir)] <- "Night"    #rising
    night$sun[night$time>night$nightEnd & night$time<night$nauticalDawn] <- "Dawn" #Morn.Astr.night
    night$sun[night$time>night$nauticalDawn & night$time<night$dawn] <- "Dawn"     #Morn.Nau.ECsun
    night$sun[night$time>night$dawn & night$time<night$sunrise] <- "Dawn"          #Morn.Civil.ECsun
    night$sun[night$time>night$sunrise & night$time<night$goldenHourEnd] <- "Goldenhour.M"
    night$sun[night$time>night$goldenHourEnd & night$time<night$solarNoon] <- "Rising"
    night$sun[night$time>night$goldenHourEnd & lubridate::hour(night$time)<(lubridate::hour(night$solarNoon)-2)] <- "Rising"
    night$sun[lubridate::hour(night$time)==round(lubridate::hour(night$solarNoon))] <- "Noon"
    night$sun[night$time>night$solarNoon & night$time<night$goldenHour] <- "Setting"
    night$sun[night$time>night$goldenHour & night$time<night$sunset] <- "Goldenhour.A"
    night$sun[night$time>night$sunset & night$time<night$dusk] <- "Dusk"        #Even.Civil.ECsun
    night$sun[night$time>night$dusk & night$time<night$nauticalDusk] <- "Dusk"  #Even.Nau.ECsun
    night$sun[night$time>night$nauticalDusk & night$time<night$night] <- "Dusk" #Even.Astr.ECsun

    night$daynight <- NULL
    night$daynight[night$sun == "Setting"] <- "day"
    night$daynight[night$sun == "Noon"] <- "day"
    night$daynight[night$sun == "Rising"] <- "day"
    night$daynight[night$sun == "Dusk"] <- "dawn_dusk"
    night$daynight[night$sun == "Dawn"] <- "dawn_dusk"
    night$daynight[night$sun == "Night"] <- "night"
    night$daynight[night$sun == "Goldenhour.M"] <-"day"
    night$daynight[night$sun == "Goldenhour.A"] <- "day"

    day_night <- night$daynight

    obs_vec <- data.frame("timestamp" = timestamp,
                          "obs_vec" = obs_vec,
                          "dryhours_vec" = dryhours_vec,
                          "day_night" = day_night,
                          "neg_vec" = neg_vec)

    filtered <- dplyr::filter(obs_vec, lubridate::month(timestamp) >= month_start & lubridate::month(timestamp) <= month_end)

    filtered <- dplyr::filter(filtered, day_night %in% period)

    filtered <- dplyr::filter(filtered, dryhours_vec >= dry_hours)

    filtered <- dplyr::filter(filtered, neg_vec >= neg_null)

    predictions_df$timestamp <- timestamp

    predictions_df <- dplyr::left_join(filtered[,1:2], predictions_df, by = "timestamp")

    names(predictions_df) <- c("timestamp", "obs_vec", paste0("pred", "_", 1:length(predictions)))

    obs_vec <- filtered[,2]

    Predictions_metrics <- lapply(1:length(predictions),
                                  function(i) metric_function(predictions_df,
                                                              truth = "obs_vec",
                                                              estimate = paste0("pred", "_", i),
                                                              na_rm = TRUE))


    metrics_table <- data.frame(t(sapply(1:(length(predictions)), function(i) Predictions_metrics[[i]]$.estimate)))
    colnames(metrics_table) <- Predictions_metrics[[1]]$.metric
    rownames(metrics_table) <- names(predictions)

    metrics_table$rBias <- sapply(1:length(predictions), function(i) sum(predictions_df[i+2]-obs_vec, na.rm = T)/
                                    sum(obs_vec[!is.na(predictions_df[i+2])==T], na.rm = T))

    names(predictions_df) <- c("timestamp", "obs_vec", names(predictions))

    metrics_table$n_obs <- sapply(1:length(predictions), function(i) length(filter(predictions_df, !is.na(obs_vec) &
                                                                                                   !is.na(predictions_df[i+2]))[,i+2]))

  }else{


  predictions_df <- predictions

  data_obs_pred <- cbind(obs_vec, predictions_df)

  names(data_obs_pred)[1] <- "obs_vec"
  names(data_obs_pred)[-1] <- paste0("pred", "_", 1:length(predictions_df))

  Predictions_metrics <- lapply(1:length(predictions_df),
                                function(i) metric_function(data_obs_pred,
                                                            truth = "obs_vec",
                                                            estimate = paste0("pred", "_", i),
                                                            na_rm = TRUE))

  metrics_table <- data.frame(t(sapply(1:length(predictions_df), function(i) Predictions_metrics[[i]]$.estimate)))
  colnames(metrics_table) <- Predictions_metrics[[1]]$.metric
  rownames(metrics_table) <- names(predictions)

  metrics_table$rBias <- sapply(1:length(predictions), function(i) sum(predictions[i]-obs_vec, na.rm = T)/
                                  sum(obs_vec, na.rm = T))

  metrics_table$n_obs <- sapply(1:length(predictions), function(i) matrix(table(is.na(obs_vec)))[1])
  }

  return(metrics_table)


}
