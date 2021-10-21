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
#' @param prob default TRUE, if FALSE return the full fooprint
#' @param resample default TRUE, if FALSE return the grid from the FP function
#' @return It returns a data frame (or vector) with the FP average extracted from the tower's location.
#' @examples
#' ## Examples of uses of the extract_fp probability raster
#' ROTH_Map <- raster::crop(atlas_maps[[1]], extent(c(385566.5-2000, 385566.5+2000, 5813229-2000, 5813229+2000)))
#'
#' FP_ROTH_prob <- pbapply::pblapply(4501:4524, function(i)
#'   get_probRaster(
#'     fetch = 1000, zm = 39.75, grid = 200, lon = 385566.5, lat = 5813229,
#'     speed = zoo::na.approx(EC_DWD_ROTH$ws)[i], # FP input variables
#'     direction = zoo::na.approx(EC_DWD_ROTH$wd)[i],
#'     uStar = zoo::na.approx(EC_DWD_ROTH$u.)[i],
#'     zd = zoo::na.approx(EC_DWD_ROTH$zd)[i],
#'     v_var = zoo::na.approx(EC_DWD_ROTH$v_var)[i],
#'     L = zoo::na.approx(EC_DWD_ROTH$L)[i],
#'     timestamp = EC_DWD_ROTH$timestamp[i],
#'     FP_probs = 0.90,# FP probability
#'     prob = TRUE,
#'     resample = TRUE,
#'     input_raster = ROTH_Map # raster model inputs (utm)
#'   ))
#'
#' FP_ROTH_prob <- stack(FP_ROTH_prob)
#'
#' plot(FP_ROTH_prob[[c(1,6,12,18)]])
#'
#' for (i in 1:24) {
#'   print(sum(raster::values(FP_ROTH_prob[[i]]), na.rm = TRUE))
#' }
#'
#' @export
get_probRaster <- function(
  # FP parameters for Calculate from FREddyPro
  fetch, zm, grid, speed, direction, uStar, zd, v_var, L,
  # tower position and datetime for exportFootprintPoints
  lon, lat, timestamp,
  # probability to keep as the main ellipse area - suggested 0.99
  FP_probs = 0.99,
  input_raster,
  prob = TRUE,
  resample = TRUE
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
  if(prob == TRUE){

     if(resample == TRUE){

    footprint <- raster::rasterFromXYZ(xyz = footprint,
                                       crs = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

    footprint <- raster::crop(footprint, raster::extent(input_raster))
    footprint <- raster::projectRaster(footprint, input_raster)

    footprint[which(raster::values(footprint) <= raster::quantile(footprint, probs = FP_probs, names = FALSE))] <- NA
    raster::values(footprint) <- raster::values(footprint)*1/sum(raster::values(footprint), na.rm = TRUE)

    }else{

    footprint <- raster::rasterFromXYZ(xyz = footprint,
                                       crs = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

    footprint[which(raster::values(footprint) <= raster::quantile(footprint, probs = FP_probs, names = FALSE))] <- NA
    raster::values(footprint) <- raster::values(footprint)*1/sum(raster::values(footprint), na.rm = TRUE)
    }

  }else{

  footprint <- raster::rasterFromXYZ(xyz = footprint,
                                       crs = "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")

  }
  ### return a data frame (or vector) with the FP average extracted from the tower location
  return(footprint)

  options(warn = 1)

  unlink(Rasterdir, recursive = TRUE)
  raster::rasterOptions(tmpdir = tmpdir_raster)
}
