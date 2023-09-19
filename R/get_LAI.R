#' get_LAI.R
#' This is a function download maps download the LAI 300m images from the Copernicus Vito portal.
#' @param user_VITO user name from the Copernicus Vito portal
#' @param pass_VITO, password from the Copernicus Vito portal
#' @param destfile directory to download the file e.g. D:/data/lai/
#' @param start_date start date of the images , e.g. "2017-12-01"
#' @param end_date end date of the images
#' @return list with links to download .nc file in a folder
#' @examples
#' LAI_links <- get_LAI_links(user_VITO = 'your_user_name',
#'                            pass_VITO = '123456',
#'                            destfile = "D:/Data-Modelling/",
#'                            start_date = "2017-12-01",
#'                            end_date = "2022-09-20")
#'
#' # download the images
#' for (i in 1:length(LAI_links)) {
#'                download.file(LAI_links[[1]][i],
#'                destfile = paste0("D:/Data-Modelling/LAI/",
#'                                  "LAI_", LAI_links[[2]][i],"_", i,".nc"),
#'                method="curl")
#' }
#'
#' @export

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
