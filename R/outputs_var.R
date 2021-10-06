#' All possible outputs from SCOPE model
#'
#' Data shows the output variable names, unit and descripition.
#' The table show also the file name where it can befind in the SCOPE diretory,
#' and the settings used to derive that output.
#'
#' @docType data
#'
#' @usage data(outputs_var)
#'
#' @format A data frame with 98 rows and 5 variables:
#' \describe{
#'   \item{variable}{output variable names}
#'   \item{units}{output variables units}
#'   \item{description}{output variables description}
#'   \item{simulation}{file name, where to find the outputs variables}
#'   ...
#' }
#'
#' @keywords datasets
#'
#' @references C. Van der Tol, W. Verhoef, J Timmermans, A Verhoef, and Z Su. (2009).
#' An integrated model of soil-canopy spectral radiances, photosynthesis, fluorescence, temperature and energy balance.
#' Biogeosciences, 6(12):3109–3129.
#' (\href{www.biogeosciences.net/6/3109/2009/}{doi:10.5194/bg-6-3109-2009})
#'
#' @source \href{https://scope-model.readthedocs.io/en/latest/outfiles.html}{SCOPE Documentation}
#'
#' @examples
#' data(outputs_var)
#'
"outputs_var"
