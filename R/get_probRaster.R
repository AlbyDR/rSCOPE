#' get_probRaster
#'
#' This is a function to extract footprint FP for inputs or outputs for the EC towers source area.
#' It extracts the FP average (i.e. sum of probability) for inputs in a multilayer stack or brick raster, or
#' in a data frame (timestamp, output values per "pixel number").
#' @param fetch source area maximum distance in meters for the footprint (radious).
#' @param zm EC measurement height above ground (in meter)
#' @param grid the grid size (square)
#' @param speed wind speed
#' @param direction wind direction
#' @param uStar friction velocity
#' @param zd roughness length
#' @param v_var sigma var
#' @param L stability parameter
#' @param lon longitude of the EC tower
#' @param lat latitude of the EC tower
#' @param timestamp datetime (Lubridate)
#' @param FP_probs probability to keep as the main ellipse area - suggested 0.99
#' @return It returns a data frame (or vector) with the FP average extracted from the tower's location.
#' @examples
#' ## Examples of uses of the extract_fp function
#' # fix time and no resample (as before) - Atlas Maps
#' # fix time resample from a map of entire the Berlin - Atlas Maps
#' # varying in time using a multilayer raster stacked hourly (if daily change timestamp from ymd_hms to ymd)
#' # varying in time using a data frame with all pixels values and timestamp together - modeled ET
#'
#' n = 8760
#' # ROTH location, fix in time and no resample. The raster has to be cropped and reproject to FP before
#'
#' FP_ROTH_extrated <- data.frame(t(sapply(1:n, function(i) extract_fp(
#'   fetch = 1000, zm = 40 , grid = 200, lon = 385566.5, lat = 5813229, # constants
#'   speed = na.approx(EC_ROTH$ws)[i], # FP input variables
#'   direction = na.approx(EC_ROTH$wd)[i],
#'   uStar = na.approx(EC_ROTH$u.)[i],
#'   zd = na.approx(EC_ROTH$zd)[i],
#'   v_var = na.approx(EC_ROTH$v_var)[i],
#'   L = na.approx(EC_ROTH$L)[i],
#'   timestamp = EC_ROTH$timestamp[i],
#'   FP_probs = 0.9925, # FP probability
#'   fix_time = TRUE, # default
#'   resample_raster = FALSE,
#'   input_raster = atlas_maps_ROTH_FP # raster model inputs - utm
#' )) ))
#'
#'
#' @export
get_probRaster <- function(
  # FP parameters for Calculate from FREddyPro
  fetch, zm, grid, speed, direction, uStar, zd, v_var, L,
  # tower position and datetime for exportFootprintPoints
  lon, lat, timestamp,
  # probability to keep as the main ellipse area - suggested 0.99
  FP_probs = 0.99
){ # If TRUE crop and reproject for the footprint resolution/extent

  #creates a new filepath for temp directory
  Rasterdir <- file.path(tempdir(), "Rasterdir")
  dir.create(Rasterdir)

  #sets temp directory
  sink("NUL")
  tmpdir_raster <- raster::rasterOptions()$tmpdir
  raster::rasterOptions(tmpdir = Rasterdir)
  sink()

  ### make the footprint calculation according to Kormann and Meixner (2001) from FREddyPro
  footprint <- FREddyPro::exportFootprintPoints(FREddyPro::Calculate(fetch = fetch,
                                                                     height = zm-zd,
                                                                     grid = grid,
                                                                     speed = speed,
                                                                     direction = direction,
                                                                     uStar = uStar,
                                                                     zol = (zm-zd)/L,
                                                                     sigmaV = sqrt(v_var)),
                                                xcoord = lon,
                                                ycoord = lat)
  # convert to raster (utm)
  footprint <- raster::rasterFromXYZ(xyz = footprint,
                                     crs = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

  # reduce the FP area to the elipse that the probability is equal to the input FP_probs (suggested 0.99)
  footprint[which(raster::values(footprint) <= raster::quantile(footprint, probs = FP_probs, names = FALSE))] <- NA
  raster::values(footprint) <- raster::values(footprint)*1/sum(raster::values(footprint), na.rm = TRUE)

  ### return a data frame (or vector) with the FP average extracted from the tower location
  return(footprint)

  options(warn = 1)

  unlink(Rasterdir, recursive = TRUE)
  raster::rasterOptions(tmpdir = tmpdir_raster)
}
