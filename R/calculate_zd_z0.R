#' calculate_zd_z0
#'
#' This is a function calculate Zd and Zo using Kanda.
#' @param wind_direction wind direction
#' @param timestamp timestamp
#' @param lambda_building_pai building pai
#' @param lambda_vegetaion_pai vegetation pai
#' @param P3D_summer constant = 0.2
#' @param P3D_winter constant = 0.6
#' @param P3D_intermediate constant = 0.4
#' @param lambda_building_fai building fai
#' @param lambda_vegetaion_fai vegetation fai
#' @param lambda_combined_zHstd combined vegetation and building
#' @param lambda_combined_zH combined vegetation and building
#' @param lambda_combined_zHmax combined vegetation and building
#' @param Cdb constant = 1.2
#' @param Kotthaus = F
#' @param wind_v = NULL
#' @return the result is a data.frame with the calculater Zd and Zo.
#' @examples
#' # zo and zd calculation
#' ROTH_zd_z0 <- calculate_zd_z0(lambda_building_pai = Lambda_B_1deg$pai,
#'                             lambda_vegetaion_pai = Lambda_V_1deg$pai,
#'                             P3D_summer = 0.2,
#'                             P3D_winter = 0.6,
#'                             P3D_intermediate = 0.4,
#'                             lambda_building_fai = Lambda_B_1deg$fai,
#'                             lambda_vegetaion_fai = Lambda_V_1deg$fai,
#'                             Cdb = 1.2,
#'                             lambda_combined_zHstd = Lambda_C_1deg$zHstd,
#'                             lambda_combined_zH = Lambda_C_1deg$zH,
#'                             lambda_combined_zHmax = Lambda_C_1deg$zHmax,
#'                             timestamp = EC_ROTH$timestamp,
#'                             Kotthaus = F,
#'                             wind_direction = EC_ROTH$wd,
#'                             wind_v = NULL)
#'
#' ROTH_zd_z0
#'
#' @export
calculate_zd_z0 <- function(lambda_building_pai,
                            lambda_vegetaion_pai,
                            P3D_summer = 0.2,
                            P3D_winter = 0.6,
                            P3D_intermediate = 0.4,
                            lambda_building_fai,
                            lambda_vegetaion_fai,
                            Cdb = 1.2,
                            lambda_combined_zHstd,
                            lambda_combined_zH,
                            lambda_combined_zHmax,
                            timestamp,
                            Kotthaus = F,
                            wind_direction,
                            wind_v = NULL
                        ){

Lambda_V_summer <- (1-P3D_summer)*lambda_vegetaion_pai
pai_deg_summer <- (Lambda_V_summer + lambda_building_pai)

Lambda_V_winter <- (1-P3D_winter)*lambda_vegetaion_pai
pai_deg_winter <- (Lambda_V_winter + lambda_building_pai)

Lambda_V_intermediate <- (1-P3D_intermediate)*lambda_vegetaion_pai
pai_deg_intermediate <- (Lambda_V_intermediate + lambda_building_pai)

Pv_summer <- ((-1.251*(P3D_summer^2) + 0.489*(P3D_summer) + 0.803)/1*Cdb)
fai_deg_summer  <- lambda_building_fai + (Pv_summer*lambda_vegetaion_fai)

Pv_winter <- ((-1.251*(P3D_winter^2) + 0.489*(P3D_winter) + 0.803)/1*Cdb)
fai_deg_winter  <- lambda_building_fai + (Pv_winter*lambda_vegetaion_fai)

Pv_intermediate <- ((-1.251*(P3D_intermediate^2) + 0.489*(P3D_intermediate) + 0.803)/1*Cdb)
fai_deg_intermediate <- lambda_building_fai + (Pv_intermediate*lambda_vegetaion_fai)

Zd_deg_summer <- c()
Zd_deg_winter <- c()
Zd_deg_intermediate <- c()

for(i in 1:360){
  Zd_deg_summer[i] <- Kanda_zd(pai = pai_deg_summer[i], fai = fai_deg_summer[i],
                               zH = lambda_combined_zH[i], zstd = lambda_combined_zHstd[i],
                               zHmax = lambda_combined_zHmax[i])

  Zd_deg_winter[i] <- Kanda_zd(pai = pai_deg_winter[i], fai = fai_deg_winter[i],
                               zH = lambda_combined_zH[i], zstd = lambda_combined_zHstd[i],
                               zHmax = lambda_combined_zHmax[i])

  Zd_deg_intermediate[i] <- Kanda_zd(pai = pai_deg_intermediate[i],
                                     fai = fai_deg_intermediate[i],
                                     zH = lambda_combined_zH[i],
                                     zstd = lambda_combined_zHstd[i],
                                     zHmax = lambda_combined_zHmax[i])
}

Z0_deg_summer <- c()
Z0_deg_winter <- c()
Z0_deg_intermediate <- c()

for(i in 1:360){
  Z0_deg_summer[i] <- Kanda_z0(fai = fai_deg_summer[i], pai = pai_deg_summer[i],
                               zstd = lambda_combined_zHstd[i], zH = lambda_combined_zH[i],
                               zHmax = lambda_combined_zHmax[i])
  Z0_deg_winter[i] <- Kanda_z0(fai = fai_deg_winter[i], pai = pai_deg_winter[i],
                               zstd = lambda_combined_zHstd[i], zH = lambda_combined_zH[i],
                               zHmax = lambda_combined_zHmax[i])
  Z0_deg_intermediate[i] <- Kanda_z0(fai = fai_deg_intermediate[i], pai = pai_deg_intermediate[i],
                                     zstd = lambda_combined_zHstd[i], zH = lambda_combined_zH[i],
                                     zHmax = lambda_combined_zHmax[i])
}

summer_1deg <- data.table::data.table(cbind(c(0:359),
                                            pai_deg_summer,
                                            fai_deg_summer,
                                            Zd_deg_summer,
                                            Z0_deg_summer))
names(summer_1deg)[1] <- "Wd"

winter_1deg <- data.table::data.table(cbind(c(0:359),
                                            pai_deg_winter,
                                            fai_deg_winter,
                                            Zd_deg_winter,
                                            Z0_deg_winter))
names(winter_1deg)[1] <- "Wd"

intermediate_1deg <- data.table::data.table(cbind(c(0:359),
                                                  pai_deg_intermediate,
                                                  fai_deg_intermediate,
                                                  Zd_deg_intermediate,
                                                  Z0_deg_intermediate))
names(intermediate_1deg)[1] <- "Wd"

summer_1deg_running <- running_mean(data = summer_1deg)
winter_1_deg_running <- running_mean(data = winter_1deg)
intermediate_1_deg_running <- running_mean(data = intermediate_1deg)

z_winter <- data.table::data.table("deg" = c(1:360),
                                   "zd" = winter_1_deg_running$Zd_deg_winter,
                                   "z0" = winter_1_deg_running$Z0_deg_winter)

z_intermediate <- data.table::data.table("deg" = c(1:360),
                                         "zd" = intermediate_1_deg_running$Zd_deg_intermediate,
                                         "z0" = intermediate_1_deg_running$Z0_deg_intermediate)

z_summer <- data.table::data.table("deg" = c(1:360),
                                   "zd" = summer_1deg_running$Zd_deg_summer,
                                   "z0" = summer_1deg_running$Z0_deg_summer)

z_result <- data.table::data.table(timestamp = timestamp,
                                   zd = rep(as.numeric(NA), length(wind_direction)),
                                   z0 = rep(as.numeric(NA), length(wind_direction)))

if(Kotthaus == F){
    for(i in 1:nrow(z_result)){
      if(is.na(wind_direction[i])){
        z_result$zd[i] <- NA
        z_result$z0[i] <- NA
      }else{
        if(substr(timestamp[i],6,7) %in% c("12","01","02")){
          res <- average_z_by_wd(wd = wind_direction[i],
                                 z_data = z_winter,
                                 deg_column = "deg")

          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }else if(substr(timestamp[i],6,7) %in% c("06","07","08")){
          res <- average_z_by_wd(wd = wind_direction[i],
                                 z_data = z_summer,
                                 deg_column = "deg")
          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }else{
          res <- average_z_by_wd(wd = wind_direction[i],
                                 z_data = z_intermediate,
                                 deg_column = "deg")
          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }
      }
    }
  }else{
    for(i in 1:nrow(z_result)){
      if(is.na(wind_direction[i])){
        z_result$zd[i] <- NA
        z_result$z0[i] <- NA
      }else{
        if(substr(timestamp[i],6,7) %in% c("12","01","02")){
          res <- average_z_by_wd(wd = wind_direction[i],
                                 v_sd = wind_v[i],
                                 z_data = z_winter,
                                 deg_column = "deg",
                                 Kotthaus = T)
          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }else if(substr(timestamp[i],6,7) %in% c("06","07","08")){
          res <- average_z_by_wd(wd = wind_direction[i],
                                 v_sd = wind_v[i],
                                 z_data = z_summer,
                                 deg_column = "deg",
                                 Kotthaus = T)
          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }else{
          res <- average_z_by_wd(wd = wind_direction[i],
                                 v_sd = wind_v[i],
                                 z_data = z_intermediate,
                                 deg_column = "deg",
                                 Kotthaus = T)
          z_result$zd[i] <- res[1]
          z_result$z0[i] <- res[2]
        }
      }
    }
  }

return(z_result)

}
