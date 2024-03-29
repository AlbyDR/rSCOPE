% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_urban_cooling.R
\name{map_urban_cooling}
\alias{map_urban_cooling}
\title{map_urban_cooling}
\usage{
map_urban_cooling(
  dataset,
  date_hottest,
  function_var = list(max, sum),
  output_vars = c("ET", "Tsave", "Tcave"),
  input_raster,
  NA_cells,
  Input_vector,
  veg_fraction,
  extract_fun = "max"
)
}
\arguments{
\item{dataset}{a data.frame with SCOPE outputs, a datetime variable and pixel numbers (timestamp, id_pixel) from the get_prediction function}

\item{date_hottest}{to define the day to calculate the indices}

\item{output_vars}{variables to map, default c("ET", "Tsave"),}

\item{input_raster}{the grip template (raster object, the same as the interpolation)}

\item{NA_cells}{a vector the raster grid id_pixel masked and excluded from the SCOPE run}

\item{Input_vector}{name of the sf polygon map object}

\item{veg_fraction}{name of the vegetation fraction variable}

\item{extract_fun}{get the max ET form the 1km grid, default = 'max', faster and suitable in case of coarse grid}
}
\value{
It will save the split files in the SCOPE directory.
}
\description{
This function map greening cooling services based on the SCOPE outputs according to a selected period.
}
\examples{
Map greening cooling services indices based on the SCOPE predictions
Cooling_maps_2000 <- map_urban_cooling(dataset = Berlin2020_pred,
                                      date_hottest = "2020-08-08",
                                      input_raster = krg_grid,
                                      NA_cells = cellNA,
                                      Input_vector = Green_vol,
                                      veg_fraction = "vegproz",
                                      output_vars = c("ET", "Tsave"),
                                      extract_fun = 'max')

summary(Cooling_maps_2000)

plot(Cooling_maps_2000[c(3,4,5)], border = "transparent", nbreaks=11,
    pal=RColorBrewer::brewer.pal('RdYlBu', n = 11), reset=FALSE)


}
