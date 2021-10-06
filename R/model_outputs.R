#' model_outputs
#'
#' This is a function to get the model output available (variables and settings to get them).
#' @param outputs show the possible outputs and the settings to get them.
#' @return The result is a table with the outputs and settings.
#' @examples
#' Examples of uses of the function
#'
#' model_outputs()
#'
#'
#' @export
model_outputs <- function(outputs = TRUE
){
  outputs <- data("outputs_var")

  outputs_table <- tibble::tibble(outputs)

  return(outputs_table)
}
