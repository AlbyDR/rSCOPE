#' run_SCOPE
#'
#' This is a function to run SCOPE/Matlab simulations from r changing model inputs and setting.
#' It will open automatic Matlab, run SCOPE and close when the simulation finish.
#' @param csv_inputs a data.frame with a datetime variable required to SCOPE (BerkeleyJulianDate) and all the model input variables.
#' @param SCOPE_dir the patch to the SCOPE directory.
#' @param Simulation_Name the name of the files start with
#' @param t the variable name in the df for the BerkeleyJulianDate, e.g. "t".
#' @param Rin,Rin the variables Rin (shortwave solar radiation), Rli (longwave radiation).
#' @param p,Ta,RH,ea the variables p (air pressure), Ta (air temperature), RH (relative humidity), ea (vapour pressure).
#' @param u the variable (wind speed).
#' @param psi the variables psi (relative angle), tts (zenith solar angle), tto (observed angle).
#' @param SMC,LAI,hc the variables (soil moisture content at the root deep), LAI (Leaf Area Index), hc (canopy height).
#' @param z_c the tower height. Al the constant from a SCOPE can be changed from the default values,
#' @param hc_c,LAI_c,Cab_c e.g. default hc is 2 but it can be changed by including in the formula hc_c = 10 or other value.
#' @param simulation = 1 as default, but any SCOPE model setting can be changed by inform the name and the value,
#' @param soilspectrum e.g. instance, soilspectrum = 1 to use a spectra file for the soil model.
#' @param split default = FALSE
#' @param col_split  for instance "week_" dataset_for_verification
#' @param split_values split_pixels[i] or split_week[i] from 1:53 then the result is like "week_52"
#' @return It return a message "done!". A set of files from the simulation will be save on the SCOPE directory/output/simulation_name
#' @examples
#' Examples of uses of the run_SCOPE function
#' #########
#' run one file in the environment that will be saved on the SCOPE directory
#'
#' run_SCOPE(SCOPE_dir = "D:/SCOPE-master/", # SCOPE directory patch
#'          csv_inputs = Inputs_pixels_ROTH, # file name with all inputs (variables)
#'          Simulation_Name = "ROTH",
#'          # variables
#'          t = "t", # time BerkeleyJulianDate
#'          Rin = "Rin", Rli = "Rli",
#'          p = "p", Ta = "Ta", RH = "RH", ea = "ea",
#'          u = "ws",
#'          tts = "tts", tto = NA, psi = "psi", # geometry
#'          SMC = "SMC_40", # soil
#'          LAI = "LAI", hc = "hc",# vegetation
#'          # constants values (non-default)
#'          hc_c = 20,
#'          z_c = 40,
#'          startDOY = 20190101, endDOY =20191231,  # timestamp preiod
#'          LAT = 52.00, LON = 13.00, timezn = 0,   # Lat/long and time zone
#'          # settings values (non-default)
#'          soilspectrum = 1,
#'          soil_file = "soilROTH.txt", # soil spectrum file (save at "D:\SCOPE-master\input\soil_spectra")
#'          applTcorr = 1,
#'          soil_heat_method = 2,
#'          MoninObukhov = 1)
#'
#' run divided/spit by pixel
#'
#' run_SCOPE(csv_inputs = Inputs_Berlin_masked,
#'          Simulation_Name = "Pixel_",
#'          split = TRUE,
#'          col_split = "id_pixel",
#'          split_values = c(1169),
#'          # variable names
#'          SMC = "SMC_60",
#'          LAI = "LAI",
#'          hc = "hc_1m",
#'          # constants values (non-default)
#'          hc_c = 19,
#'         z_c = 40, # measurements height
#'          # settings values (non-default)
#'          soilspectrum = 1,
#'          applTcorr = 1,
#'          soil_heat_method = 2,
#'          MoninObukhov = 1)
#'
#' split by pixel and with time delay in seconds
#' library("svMisc")
#'
#' split_pixels <- c(1169, 882)
#' zm_pixels <- c(40,56)
#' n = 2
#'
#' for (i in 1:n) {
#'  run_SCOPE(csv_inputs = Inputs_Berlin_masked,
#'            Simulation_Name = paste0("pixel_", i),
#'            split = TRUE,
#'            col_split = "id_pixel", #dataset_for_verification
#'            split_values = split_pixels[i],
#'           # variable names
#'            t = "t", # time BerkeleyJulianDate
#'            Rin = "Rin", Rli = "Rli",
#'            p = "p", Ta = "Ta", RH = "RH", ea = "ea", u = "ws",
#'            tts = "tts", tto = NA, psi = "psi",
#'            SMC = "SMC60",
#'            LAI = "LAI",
#'            hc = "hc_1m",
#'            # constants values (non-default)
#'            hc_c = 20,
#'           z_c = zm_pixels[i],
#'            # settings values (non-default)
#'            soilspectrum = 1,
#'            applTcorr = 1,
#'            soil_heat_method = 2,
#'            MoninObukhov = 0)
#'  # time delay
#'  progress(i, n, progress.bar = TRUE, init = T)
#'  Sys.sleep(360) #time delay in seconds
#'  if (i == n) message("Done!")
#' }
#'
#' split by pixel and with time delay in seconds
#' library("svMisc")
#'
#' SMC_i <- c("SMC60","SMC60","SMC60","SMC60", "SMC60","SMC60","SMC60","SMC60",
#'           "SMC40","SMC40","SMC40","SMC40", "SMC60","SMC60","SMC60","SMC60",
#'           "SMC20","SMC20","SMC20","SMC20", "SMC60","SMC60","SMC60","SMC60")
#' LAI_i <- c("LAI","LAI_mean","LAI_max",NA, "LAI","LAI_mean","LAI_max",NA,
#'           "LAI","LAI_mean","LAI_max",NA, "LAI","LAI_mean","LAI_max",NA,
#'          "LAI","LAI_mean","LAI_max",NA, "LAI","LAI_mean","LAI_max",NA)
#' hc_i <- c("hc_1m","hc_1m","hc_1m","hc_1m", "hc_vh","hc_vh","hc_vh","hc_vh",
#'          "hc_1m","hc_1m","hc_1m","hc_1m", "hc_bf","hc_bf","hc_bf","hc_bf",
#'          "hc_1m","hc_1m","hc_1m","hc_1m",  NA,     NA,    NA,    NA)
#' hc_c_i <- c(NA,     NA,    NA,    NA,       NA,     NA,    NA,    NA,
#'            NA,     NA,    NA,    NA,       NA,     NA,    NA,    NA,
#'            NA,     NA,    NA,    NA,       10,     2,    10,    10)
#'
#'for (i in 1:length(SMC_i)) {
#'  run_SCOPE(csv_inputs = Inputs_Berlin_masked,
#'            Simulation_Name = paste0("pixel_882_", i),
#'            split = TRUE,
#'            col_split = "id_pixel", #dataset_for_verification
#'            split_values = 882, #1169,
#'            # variable names
#'            t = "t", # time BerkeleyJulianDate
#'            Rin = "Rin", Rli = "Rli",
#'            p = "p", Ta = "Ta", RH = "RH", ea = "ea", u = "ws",
#'            tts = "tts", tto = NA, psi = "psi", # geometry
#'            # variables calibration
#'            SMC = SMC_i[i], # soil
#'            LAI = LAI_i[i],
#'            hc = hc_i[i], # vegetation
#'            # constants values (non-default)
#'            hc_c = hc_c_i[i],
#'            z_c =  56, #40,
#'            startDOY = 20181201, endDOY =20200130,  # timestamp period
#'            LAT = 52.00, LON = 13.00, timezn = 0,   # Lat/long and time zone
#'            # settings values (non-default)
#'            soilspectrum = 1,
#'            soil_file = "soilROTH.txt", # soil spectrum file (save at "D:\SCOPE-master\input\soil_spectra")
#'            applTcorr = 1,
#'            soil_heat_method = 2,
#'           MoninObukhov = 1)
#' # time delay
#'  progress(i, length(SMC_i), progress.bar = TRUE, init = T)
#'  Sys.sleep(360) #time delay in seconds
#'  if (i == length(SMC_i)) message("Done!")
#'}
#'
#' split by week and with time delay in seconds
#'
#' split_week <- 1:53
#' n2 = 12

#' for (i in 9:n2) {
#'   run_SCOPE(csv_inputs = Inputs_Berlin_masked,
#'             Simulation_Name = paste0("week_", i, "_SMC60_LAI_hc"),
#'             split = TRUE,
#'             col_split = "week", #dataset_for_verification
#'             split_values = split_week[i],
#'             t = "t", # time BerkeleyJulianDate
#'             Rin = "Rin", Rli = "Rli",
#'             p = "p", Ta = "Ta", RH = "RH", ea = "ea", u = "ws",
#'             tts = "tts", tto = NA, psi = "psi",
#'             SMC_var = "SMC60",
#'             LAI_var = "LAI",
#'             hc_var = "hc",
#'             hc_fix = 20,
#'             zm = 40,
#'             soilspectrum = 1,
#'             applTcorr = 1,
#'             soil_heat_method = 2,
#'             calc_rss_rbs = 0,
#'             MoninObukhov = 1)
#'   progress(i, n2, progress.bar = TRUE, init = T)
#'   Sys.sleep(3600) # time delay in seconds - 1 hour
#'   if (i == n2) message("Done!")
#' }
#'
#' @export
run_SCOPE <- function(
  csv_inputs,
  SCOPE_dir = "D:/SCOPE-master/",
  ### model inputs variables
  filenames = filenames,
  Simulation_Name,
  soil_file = "soilROTH.txt",
  # time BerkeleyJulianDate  # atmosphere conditions
  t = NA,  Rin = NA, Rli = NA, p = NA, Ta = NA, RH = NA, ea = NA, u = NA,
  # geometry                                #z          #CO2
  tts = NA, tto = NA, psi = NA, z = NA, Ca = NA,
  # soil
  SMC = NA, BSMBrightnes= NA, BSMlat= NA, BSMlon= NA,
  # vegetation
  LAI = NA, hc = NA, Cab = NA, Cca = NA, Cdm = NA, Cw = NA, Cs = NA,
  Cant = NA, LIDFa = NA, LIDFb = NA, Vcmax25 = NA, BallBerrySlope = NA,
  ### model inputs constant
  input_data_default = input_data_default,
  # fixed parameters
  PROSPECT = NA, Cab_c = 40,  Cca_c = 10 , Cdm_c = 0.012, Cw_c = 0.009, Cs_c = 0, Cant_c = 1,
  cp = 0, Cbc = 0, Cp = 0, N = 1.5, rho_thermal = 0.010, tau_thermal = 0.010,

    Leaf_Biochemical = NA, Vcmax25_c =  60, BallBerrySlope_c = 8, BallBerry0 = 0.010, Type = 0,
  kV = 0.640, Rdparam = 0.015, Kn0 = 2.480, Knalpha = 2.830, Knbeta = 0.114,

  Leaf_Biochemical_magnani = NA, Tyear = 15, beta = 0.510, kNPQs = 0, qLs = 1, stressfactor = 1,

  Fluorescence = NA, fqe = 0.010,

  Soil = NA, spectrum = 1, rss = 500, rs_thermal = 0.060, cs = 1180,
  rhos = 1800, lambdas = 1.550, SMC_c = 25.0, BSMBrightness_c = 0.50, BSMlat_c = 25.0, BSMlon_c = 45.0,

  Canopy = NA, LAI_c = 3, hc_c = 2, LIDFa_c = -0.350, LIDFb_c = -0.150, leafwidth = 0.1, Cv = 1.0,
  crowndiameter = 1.0,

  Meteo = NA, z_c = NA, Rin_c = 600, Ta_c = 20, Rli_c = 300,
  p_c = 970, ea_c = 15, u_c = 2, Ca_c = 410, Oa = 209,

  Aerodynamic = NA, zo = 0.250, d = 1.340, Cd = 0.30, rb =  10.00, CR = 0.35, CD1 = 20.60,
  Psicor = 0.20, CSSOIL = 0.01, rbs = 10.00, rwc = 0,

  timeseries = NA, startDOY = 20190101, endDOY =20191231, LAT = 52.00, LON = 13.00, timezn = 0,

  Angles = NA, tts_c = 30, tto_c = 0, psi_c = 0,
  ### model settings
  setoptions = setoptions,
  lite = 1, verify = 0, saveCSV = 1, mSCOPE = 0, simulation = 1, save_spectral = 0,
  calc_fluor = 0, calc_planck = 0,  calc_xanthophyllabs = 0, Fluorescence_model = 0,
  calc_directional = 0, calc_vert_profiles = 0,
  soilspectrum = 1, applTcorr = 1, soil_heat_method = 2, calc_rss_rbs = 0,  MoninObukhov = 1, #calc_ebal = 1,
  ### model run file instructions
  set_parameter_filenames = set_parameter_filenames,
  split = FALSE,
  col_split = "",
  split_values
){
  # If TRUE crop and reproject for the footprint resolution/extent
  if(split == TRUE){
    # filter values for a simple timestamp
    csv_inputs <- dplyr::filter(csv_inputs, csv_inputs[,col_split] == split_values)
    readr::write_csv(csv_inputs, file = paste0(SCOPE_dir, "input/dataset for_verification/", deparse(quote(csv_inputs)), ".csv"))
  }else{
    # extract the average (i.e. sum) of all the layers in the raster
    readr::write_csv(csv_inputs, file = paste0(SCOPE_dir, "input/dataset for_verification/", deparse(quote(csv_inputs)), ".csv"))
  }
  ###### set model inputs and settings
  ### model inputs to run with - name
  filenames_d <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                        deparse(quote(filenames)),".csv"), col_names = FALSE)

  filenames_d[c(4,7,16,35,36,37,38,39,40,41,42,43,44,45,47,48,49,
                50,51,52,54,55,56,57,59,60,61,62,64,65,67,68),2] <- c(Simulation_Name, soil_file,
                                                                      paste0("csv_inputs",".csv"), t, Rin, Rli, p, Ta, u, ea, RH, tts, tto, psi,
                                                                      Cab, Cca, Cdm, Cw, Cs, Cant, SMC, BSMBrightnes, BSMlat, BSMlon,
                                                                      LAI, hc, LIDFa, LIDFb, z, Ca, Vcmax25, BallBerrySlope)

  readr::write_csv(filenames_d, file = paste0(SCOPE_dir, "input/", deparse(quote(filenames)),
                                              ".csv"),  na = "", col_names = FALSE)

  input_data_d <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                         deparse(substitute(input_data_default)),".csv"), col_names = FALSE)

  input_data_d[,2] <- c(PROSPECT, Cab_c, Cca_c, Cdm_c, Cw_c, Cs_c, Cant_c, Cp, Cbc, N, rho_thermal, tau_thermal,
                        NA, Leaf_Biochemical, Vcmax25_c, BallBerrySlope_c, BallBerry0, Type, kV, Rdparam, Kn0, Knalpha, Knbeta,
                        NA, Leaf_Biochemical_magnani,Tyear, beta, kNPQs, qLs, stressfactor,
                        NA, Fluorescence, fqe,
                        NA, Soil, spectrum, rss, rs_thermal, cs, rhos, lambdas, SMC_c, BSMBrightness_c, BSMlat_c, BSMlon_c,
                        NA, Canopy, LAI_c, hc_c, LIDFa_c, LIDFb_c, leafwidth, Cv, crowndiameter,
                        NA, Meteo, z_c, Rin_c, Ta_c, Rli_c, p_c, ea_c, u_c , Ca_c, Oa,
                        NA, Aerodynamic, zo ,d, Cd, rb, CR, CD1 , Psicor, CSSOIL, rbs, rwc,
                        NA, timeseries, startDOY, endDOY, LAT, LON, timezn,
                        NA, Angles, tts_c, tto_c, psi_c)

  readr::write_csv(input_data_d, file = paste0(SCOPE_dir, "input/", deparse(quote(input_data_default)),
                                               ".csv"), na = "", col_names = FALSE)

  setoptions_d <- readr::read_csv(paste0(SCOPE_dir, "input/",
                                         deparse(quote(setoptions)),".csv"), col_names = FALSE)

  setoptions_d[,1] <- c(lite, calc_fluor, calc_planck, calc_xanthophyllabs, soilspectrum,
                        Fluorescence_model, applTcorr, verify, saveCSV, mSCOPE, simulation,
                        calc_directional, calc_vert_profiles, soil_heat_method, calc_rss_rbs,
                        MoninObukhov, save_spectral) #, calc_ebal

  readr::write_csv(setoptions_d, file = paste0(SCOPE_dir, "input/", deparse(quote(setoptions)),
                                               ".csv"), col_names = FALSE)

  set_parameter_filenames_d <- readr::read_csv(paste0(SCOPE_dir,
                                                      deparse(quote(set_parameter_filenames)),".csv"), col_names = FALSE)

  set_parameter_filenames_d[,1] <- paste0(deparse(quote(setoptions)),  ".csv")[1]
  set_parameter_filenames_d[,2] <- paste0(deparse(quote(filenames)), ".csv")[1]
  set_parameter_filenames_d[,3] <- paste0(deparse(quote(input_data_default)),  ".csv")[1]

  readr::write_csv(set_parameter_filenames_d,
                   file = paste0(SCOPE_dir, deparse(quote(set_parameter_filenames)), ".csv"),
                   col_names = FALSE)

  system('matlab -useStartupFolderPref -r "SCOPE; exit"')
}

