#' get_parameters
#'
#' This is a function to get all model inputs (variables and constants) and setting used in the simulations.
#' @param SCOPE_dir the diretory patch of SCOPE
#' @param Simulation_Name the name of the simulations
#' @param LAI,SMC, input variables, logical, if TRUE it will show the name of the input used for this parameter.
#' @param z_c,hc_c, input constant (_c), logical, if TRUE it will show the value of the input used for this parameter.
#' @param soil_heat_method model settings, logical, if TRUE it will show 0 for off and 1 or 2 for on.
#' @return the result is a list with a table for each simulation with the input variables and seeting used.
#' @examples
#' Examples of uses of the get_parameters function
#' #######
#' SCOPE_parameters_pixel_1169 <- get_parameters(
#'   SCOPE_dir = "D:/SCOPE-master/",
#'   Simulation_Name = "pixel_1169",
#'   LAI = TRUE,
#'   SMC = TRUE,
#'   hc = TRUE,
#'   hc_c = TRUE,
#'   z_c = TRUE)
#'
#' SCOPE_parameters_pixel_1169[[1]]
#' length(SCOPE_parameters_pixel_1169 )
#'
#' SCOPE_parameters_pixel_882 <- get_parameters(
#'   SCOPE_dir = "D:/SCOPE-master/",
#'   Simulation_Name = "pixel_882",
#'   LAI = TRUE,
#'   SMC = TRUE,
#'   hc = TRUE,
#'   hc_c = TRUE,
#'   z_c = TRUE)
#'
#' SCOPE_parameters_pixel_882
#' SCOPE_parameters_pixel_882[[1]]
#'
#' length(SCOPE_parameters_pixel_882)
#'
#' @export
get_parameters <- function(
  SCOPE_dir = "D:/SCOPE-master/",
  Simulation_Name,
  per_simulation = TRUE,
  # show model inputs - variables
  soil_file = TRUE, name_simulation = TRUE, t = FALSE, Rin = FALSE, Rli = FALSE, p = FALSE,
  Ta = FALSE, u = FALSE, ea = FALSE, RH = FALSE, tts = FALSE, tto = FALSE, psi = FALSE,
  Cab = FALSE, Cca = FALSE, Cdm = FALSE, Cw = FALSE, Cs = FALSE, Cant = FALSE,
  SMC = FALSE, BSMBrightnes= FALSE, BSMlat= FALSE, BSMlon= FALSE,
  LAI = FALSE, hc = FALSE, LIDFa = FALSE, LIDFb = FALSE,
  z = FALSE, Ca = FALSE,  Vcmax25 = FALSE, BallBerrySlope = FALSE,
  ############
  ### show model constant - fixed parameters
  Cab_c = FALSE,  Cca_c = FALSE , Cdm_c = FALSE, Cw_c = FALSE, Cs_c = FALSE, Cant_c = FALSE,
  cp = FALSE, Cbc = FALSE, Cp = FALSE,  N = FALSE, rho_thermal = FALSE, tau_thermal = FALSE,
  Vcmax25_c = FALSE, BallBerrySlope_c = FALSE, BallBerry0 = FALSE, Type = FALSE, kV = FALSE,
  Rdparam = FALSE, Kn0 = FALSE, Knalpha = FALSE, Knbeta = FALSE,
  Tyear = FALSE, beta = FALSE, kNPQs = FALSE, qLs = FALSE, stressfactor = FALSE, Fluorescence = FALSE,
  fqe = FALSE, spectrum = FALSE, rss = FALSE, rs_thermal = FALSE, cs = FALSE, rhos = FALSE, lambdas = FALSE,
  BSMBrightness_c = FALSE, BSMlat_c = FALSE, BSMlon_c = FALSE,
  SMC_c = FALSE, LAI_c = FALSE, hc_c = FALSE, Rin_c = FALSE, Ta_c = FALSE, Rli_c = FALSE, p_c = FALSE,
  ea_c = FALSE, u_c = FALSE, tts_c = FALSE, tto_c = FALSE, psi_c = FALSE, z_c = FALSE,
  LIDFa_c = FALSE, LIDFb_c = FALSE, leafwidth = FALSE, Cv = FALSE, crowndiameter = FALSE,
  Ca_c = FALSE, Oa = FALSE, zo = FALSE, d = FALSE,
  Cd = FALSE, rb =  FALSE, CR = FALSE, CD1 = FALSE, Psicor = FALSE, CSSOIL = FALSE,
  rbs = FALSE, rwc = FALSE, startDOY = TRUE, endDOY = TRUE, LAT = TRUE, LON = TRUE, timezn = TRUE,
  ### show model settings
  lite = TRUE, verify = FALSE, saveCSV = FALSE, mSCOPE = FALSE, simulation = FALSE, save_spectral = FALSE,
  calc_fluor = FALSE, calc_planck = FALSE,  calc_xanthophyllabs = FALSE, Fluorescence_model = FALSE,
  calc_directional = FALSE, calc_vert_profiles = FALSE,
  soilspectrum = TRUE, applTcorr = TRUE, soil_heat_method = TRUE, calc_rss_rbs = TRUE,  MoninObukhov = TRUE
){
  # SCOPE model inputs - variables
  Outputs_files_str <- list.files(paste0(path=grep(Simulation_Name,
                                              list.dirs(path=paste0(SCOPE_dir,"output"),
                                                        full.names = TRUE,
                                                        recursive = FALSE),
                                              value = TRUE), "/Parameters",
                                    collapse = NULL, recycle0 = FALSE),
                             pattern= "filenames",
                             full.names = TRUE)

  Inputs_files <- gtools::mixedsort(sort(Outputs_files_str))

  Inputs_list <- lapply(1:length(Inputs_files), function(i) invisible(readr::read_csv(Inputs_files[i], col_names = FALSE)))

  inputs_true <- data.frame(
    "col" = c(4,7, 35,36,37,38,39,40,41,42,43,44,45,
              47,48,49,50,51,52, 54,55,56,57,
              59,60,61,62, 64,65, 67,68),
    "check" = c(name_simulation, soil_file,   t, Rin, Rli, p, Ta, u, ea, RH, tts, tto, psi,
                Cab, Cca, Cdm, Cw, Cs, Cant,  SMC, BSMBrightnes, BSMlat, BSMlon,
                LAI, hc, LIDFa, LIDFb,  z, Ca,  Vcmax25, BallBerrySlope))

  Inputs <- lapply(1:length(Inputs_files),
                   function(i) Inputs_list[[i]][dplyr::filter(inputs_true, check == TRUE)$col,])

  # SCOPE model constants
  Constants_files_str <- list.files(paste0(path=grep(Simulation_Name,
                                                 list.dirs(path=paste0(SCOPE_dir,"output"),
                                                           full.names = TRUE,
                                                           recursive = FALSE),
                                                 value = TRUE), "/Parameters",
                                       collapse = NULL, recycle0 = FALSE),
                                pattern= "input_data",
                                full.names = TRUE)

  Constants_files <- gtools::mixedsort(sort(Constants_files_str))

  Constants_list <- lapply(1:length(Constants_files), function(i) invisible(readr::read_csv(Constants_files[i],
                                                                                  col_names = FALSE)))
  constants_true <- data.frame(
    "col" = c( 2,3,4,5,6,7,8,9,10,11,12  ,15,16,17,18,19,20,21,22,23, 26,27,28,29,30, 33,
               36,37,38,39,40,41,42,43,44,45, 48,49,50,51,52,53,54,  57,58,59,60,61,62,63,64,65,
               68,69,70,71,72,73,74,75,76,77,  80,81,82,83,84,  87,88,89),
    "check" = c(Cab_c, Cca_c, Cdm_c, Cw_c, Cs_c, Cant_c, Cp, Cbc ,N, rho_thermal, tau_thermal,
                Vcmax25_c, BallBerrySlope_c, BallBerry0, Type, kV, Rdparam, Kn0, Knalpha, Knbeta,
                Tyear, beta, kNPQs, qLs, stressfactor,   fqe,
                spectrum, rss, rs_thermal, cs, rhos, lambdas, SMC_c, BSMBrightness_c, BSMlat_c, BSMlon_c,
                LAI_c, hc_c, LIDFa_c, LIDFb_c, leafwidth, Cv, crowndiameter,
                z_c, Rin_c, Ta_c, Rli_c, p_c, ea_c, u_c, Ca_c, Oa,
                zo, d, Cd, rb, CR, CD1, Psicor, CSSOIL, rbs, rwc,
                startDOY, endDOY, LAT, LON, timezn,  tts_c, tto_c, psi_c))

  Constants <- lapply(1:length(Constants_files),
                      function(i) Constants_list[[i]][dplyr::filter(constants_true, check == TRUE)$col,])

  # SCOPE model settings
  Settings_files_str <- list.files(paste0(path=grep(Simulation_Name,
                                                list.dirs(path=paste0(SCOPE_dir,"output"),
                                                          full.names = TRUE,
                                                          recursive = FALSE),
                                                value = TRUE), "/Parameters",
                                      collapse = NULL, recycle0 = FALSE),
                               pattern= "setoptions",
                               full.names = TRUE)

  Settings_files <- gtools::mixedsort(sort(Settings_files_str))

  Settings_list <- lapply(1:length(Settings_files), function(i) invisible(readr::read_csv(Settings_files[i],
                                                                                col_names = FALSE)))
  settings_true <- data.frame(
    "col" = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17), #,18
    "check" = c(lite, calc_fluor, calc_planck, calc_xanthophyllabs, soilspectrum,
                Fluorescence_model, applTcorr, verify, saveCSV, mSCOPE, simulation, calc_directional,
                calc_vert_profiles, soil_heat_method, calc_rss_rbs, MoninObukhov, save_spectral)) #, calc_ebal

  Settings <- lapply(1:length(Settings_files),
                     function(i) Settings_list[[i]][dplyr::filter(settings_true, check == TRUE)$col,])

  if(per_simulation == TRUE){

    SCOPE_parameters <- NULL

    for (i in 1:length(Settings_list)) {
      SCOPE_parameters[[i]] <- data.frame(
        "Model_Parameter" = c("Simulation", "Folder_name",
                              Inputs[[i]][[1]][1:2],
                              "Model_Inputs (Variables)", Inputs[[i]][[1]][-1:-2],
                              "Model_Inputs (Constants)", Constants[[i]][[1]],
                              "Model_Settings", Settings[[i]][[2]]),
        "Values_and_Settings" = c("###################", stringr::str_split(Inputs_files, "/")[[i]][4],
                                  Inputs[[i]][[2]][1:2],
                                  "###################", Inputs[[i]][[2]][-1:-2],
                                  "###################", Constants[[i]][[2]],
                                  "###################", Settings[[i]][[1]]))
    }

    }else{

  SCOPE_parameters <- tibble::tibble(data.frame(t(sapply(1:length(Settings_list), function(i) unlist(
    c(t(Inputs[[i]][[2]]),
       t(Constants[[i]][[2]]),
        t(Settings[[i]][[1]])))))))

  colnames(SCOPE_parameters) <- as.character(c((Inputs[[1]][[1]]),
                                  (Constants[[1]][[1]]),
                                  (Settings[[1]][[2]])))

  }

  return(SCOPE_parameters)
}

