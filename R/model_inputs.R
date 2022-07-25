#' model_inputs
#'
#' This is a function to get the model input parameters available (variables, constants values and settings).
#' @param SCOPE_dir the directory of SCOPE.
#' @return The result is a list with 3 object. the first is the input that vary in time or space.
#' The second is the constants and respectively default values. To change the constants in the run_scope functions
#' it is needed to include "_c" after the name, for instance, hc = 2 became hc_c = 10. The third are setting,
#' if set as zero (off) they are not applied when run SCOPE.
#' @examples
#' Examples of uses of the function
#' ###########
#' model_inputs(SCOPE_dir = "D:/SCOPE-master/")
#'
#' @export
model_inputs <- function(SCOPE_dir
){
  filenames_d <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                        deparse(quote(filenames)),".csv"), col_names = FALSE)

  variables <- filenames_d[c(4,7,16,35,36,37,38,39,40,41,42,43,44,45,47,48,49,
                50,51,52,54,55,56,57,59,60,61,62,64,65,67,68,69),]

  contants <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                         deparse(substitute(input_data_default)),".csv"), col_names = FALSE)

  settings <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                         deparse(quote(setoptions)),".csv"), col_names = FALSE)

  model_parameters <- list(variables, contants, settings)


  return(model_parameters)
}
