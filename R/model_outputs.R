#' model_outputs
#'
#' This is a function to get the model output available (variables and settings to get them).
#' @param outputs show the possible outputs and the settings to get them.
#' @return The result is a table with the outputs and settings.
#' @examples
#' Examples of uses of the function
#'
#' data(outputs_var)
#'
#' outputs_var %>%
#' filter(simulation_file == "fluxes.csv")
#'
#' @export
model_outputs <- function(outputs = TRUE
){
  data("outputs_var")

  outputs <- tibble::tibble(outputs_var)

  return(outputs)
}
