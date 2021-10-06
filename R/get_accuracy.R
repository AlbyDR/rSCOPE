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
  metric_function
){
  predictions_df <- predictions
  names(predictions_df) <- rep("pred",length(predictions_df))

  Predictions_metrics <- lapply(1:length(predictions_df), function(i) metric_function(
    predictions_df[i],
    truth = obs_vec,
    estimate = "pred", na_rm = TRUE))

  metrics_table <- data.frame(t(sapply(1:length(predictions_df), function(i) Predictions_metrics[[i]]$.estimate)))
  colnames(metrics_table) <- Predictions_metrics[[1]]$.metric
  rownames(metrics_table) <- names(predictions)

  metrics_table$rBias <- sapply(1:length(predictions), function(i) sum(predictions[i]-obs_vec, na.rm = T)/
                                  sum(obs_vec, na.rm = T))

  return(metrics_table)

}
