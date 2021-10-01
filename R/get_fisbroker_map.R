#' get_fisbroker_map
#'
#' This is a function download maps from the Berlin Urban Atlas (fisbroker) site.
#' @param url map ulr from the Berlin Urban Atlas (fisbroker) site.
#' @param crs_map, projection default "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs".
#' @return sf multipolygon map.
#' @examples
#' split and save in different files to facilitate the processing
#' ########
#' ETmap <- get_fisbroker_map("https://fbinter.stadt-berlin.de/fb/wfs/data/senstadt/s02_13whaus2017")
#'
#' @export
get_fisbroker_map <- function(url,
                              crs_map = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"
){
  typenames <- basename(url)
  url <- httr::parse_url(url)
  url$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    srsName = "EPSG:25833",
                    TYPENAMES = typenames)
  request <- httr::build_url(url)
  print(request)
  out <- sf::read_sf(request)
  out <- sf::st_transform(out, 4326)
  out <- get_X_Y_coordinates(out)

  # map <- out %>%
  #   dplyr::mutate(RAUMID = stringr::str_sub(gml_id, 12, 19)) %>%
  #   dplyr::select(gml_id, RAUMID, everything()) %>%
  #   dplyr::arrange(RAUMID)

  map <- sf::st_transform(out, crs=crs_map)

  return(map)
}

export_format <- c(
  "geojson",
  "sqlite"
)
