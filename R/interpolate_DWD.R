#' interpolate_DWD
#'
#' This is a function to interpolate the DWD data downloaded.
#' The meteorological variables are point values and coordinates converted to a grid based on raster.
#' @param var_DWD a numeric vector with the DWD values per station and timestamp
#' @param stations_DWD the coordination of the DWD station
#' @param res_utm resolution of the final raster
#' @param radius_km the distance used in the get_dwd data to select the stations
#' @param crop_extent the extent of the area to crop
#' @param vgm_model the variagram theoretical model, default "Sph"
#' @return stack raster with the climatological variable interpolated in space and time
#' @examples
#' # air temperature
#'
#' krg_Ta <- lapply(1:n, FUN = function(i) Interp_DWD(var_DWD = as.numeric(Air_temp[[1]][i,-1]),
#'             stations_DWD = Air_temp[[2]],
#'             res = st_grid,
#'             crop_extent = raster::extent(Berlin_border_utm)));
#'
#' krg_Ta[[1]];
#' plot(krg_Ta[[1]]);
#'
#' @export
interpolate_DWD <- function(
  var_DWD,
  stations_DWD,
  res_utm,
  radius_km,
  crop_extent,
  vgm_model = c("Exp", "Mat", "Gau", "Sph")
  ){

  Rasterdir <- file.path(tempdir(), "Rasterdir")

  dir.create(Rasterdir)

  sink("NUL")
  tmpdir_raster <- raster::rasterOptions()$tmpdir
  raster::rasterOptions(tmpdir = Rasterdir)
  options(warn = -1)

  stations <- matrix(cbind(stations_DWD$longitude,
                           stations_DWD$latitude),
                     length(stations_DWD$longitude))

  stations_df <- data.frame(x = stations[,1], y = stations[,2])
  sp::coordinates(stations_df) = c("x", "y")
  sp::proj4string(stations_df) <- sp::CRS("+proj=longlat +datum=WGS84")
  stations <- sp::spTransform(stations_df, "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs")

  # grd_stations <- raster::raster(stations, res = res_utm)
  # raster::values(grd_stations) <- 1:ncell(grd_stations)

  grd_stations <- raster::raster(raster::extent(crop_extent) + radius_km*res_utm, res = res_utm)
  raster::values(grd_stations) <- 1:raster::ncell(grd_stations)
  raster::crs(grd_stations) <- "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs"

  # Convert to spatial pixel
  st_grid <- raster::rasterToPoints(grd_stations, spatial = TRUE)
  sp::gridded(st_grid) <- TRUE
  st_grid <- methods::as(st_grid, "SpatialPixels")

  vgm_var = gstat::variogram(object = var_DWD ~ 1, data = stations)# set a variogram
  fit_var = gstat::fit.variogram(object = vgm_var, gstat::vgm(vgm_model)) # fit a variogram

  fit_var$range[fit_var$range < 0] <- abs(fit_var$range)[2]

  krg_var = gstat::krige(var_DWD ~ 1, locations = stations, newdata = st_grid, model = fit_var, debug.level = 0)
  krg_var = raster::raster(krg_var)
  krg_var = raster::crop(x = krg_var, crop_extent)

  options(warn = 1)

  unlink(Rasterdir, recursive = TRUE)
  raster::rasterOptions(tmpdir = tmpdir_raster)
  sink()

  return(krg_var)
}
