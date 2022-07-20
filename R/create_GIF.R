#' create_GIF
#'
#' This function animate the maps of Urban ET or cooling services according to a selected period.
#' @param map sf map with with Urban ET per month derived from the map_urbanET()
#' @param period animated by "month" or "24hours", default = "month"
#' @param gif_subtitle map title, e.g. "Predicted ET (mm/month) - Berlin 2020"
#' @param water_mask sf object with water bodies to mask
#' @param border sf object with the city border
#' @param limits_scale scale limits of the map's legend, e.g. c(0,100)
#' @param breaks_scale map's legend breaks, e.g. seq(0, 100, 20)
#' @param colors_pallete continuous colour pallete for the map
#' @param time_interval time between each map in the animation default = .8 sec,
#' @param loops number of loops, default = 1
#' @param movie_name = name of the GIF file, default = "Urban_ET.gif"
#' @return a GIF file saved in the R project directory.
#' @examples
#' A animate Urban ET map monthly
#'
#' Urban_ET_git <- create_GIF(map = Urban_ET_map_month[seq(3,25,2)],
#'                            period = "month",
#'                            gif_subtitle = "Predicted ET [mm/month] - Berlin 2020",
#'                            water_mask = water_polygons,
#'                            border = Berlin_border_utm,
#'                            limits_scale = c(0,100),
#'                            breaks_scale = seq(0, 100, 20),
#'                             colors_pallete = ETcolor,
#'                            time_interval = .8,
#'                            loops = 1,
#'                            movie_name = "Urban_ET.gif")
#'
#' summary(Urban_ET_git)
#'
#'
#' @export
create_GIF <- function(
    map,
    period = "month",
    gif_subtitle,
    water_mask,
    border,
    limits_scale = c(0,100),
    breaks_scale = seq(0, 100, 20),
    colors_pallete,
    time_interval = .8,
    loops = 1,
    movie_name = "Urban_ET.gif"
){

  if(period == "month"){

Urban_ET_monthly <- map[seq(3,25,2)]

names(Urban_ET_monthly) <- c(rep("Urban_ET", 12), "geometry")

names_m <- c("January","February","March","April",
             "May","June","July","August","September"
             ,"October","November","December")

animation::saveGIF({
  for (i in 1:12){
    a <- ggplot2::ggplot(Urban_ET_monthly[i]) +
      ggplot2::geom_sf(ggplot2::aes(fill = Urban_ET), colour = NA) +
      ggplot2::geom_sf(data = water_mask, fill = "white", size = 0, color = "transparent") +
      ggplot2::geom_sf(data = border, fill = "transparent", size = 1.2, color = "black") +
      ggplot2::labs(title = names_m[i], subtitle = gif_subtitle) +
      ggplot2::guides(linetype = ggplot2::guide_legend(title = NULL, order = 2),
                      color = ggplot2::guide_legend(order = 1)) +
      ggplot2::scale_fill_gradientn(breaks = breaks_scale, limits = limits_scale,
                           colors = colors_pallete,
                           name = "", na.value = NA,
                           guide = ggplot2::guide_colorbar(direction = "horizontal",
                                                  label.position = "bottom",
                                                  title.vjust = 0, label.vjust = 0,
                                                  frame.colour = "black",
                                                  frame.linewidth = 0.5,
                                                  frame.linetype = 1,
                                                  title.position = "left",
                                                  barwidth = 30, barheight = 1.5, nbin = 20,
                                                  label.theme = ggplot2::element_text(angle = 0, size = 14))) +
      ggspatial::annotation_scale(location = "bl", height = ggplot2::unit(0.4, "cm"),
                                  pad_x = ggplot2::unit(2,"cm"), pad_y = ggplot2::unit(1.2,"cm"),
                                  text_pad = ggplot2::unit(0.25, "cm"),
                                  text_cex = 1.5) +
      ggspatial::annotation_north_arrow(location = "tr", which_north = "true",
                                        height = ggplot2::unit(2, "cm"), width = ggplot2::unit(2, "cm"),
                                        pad_x = ggplot2::unit(1,"cm"), pad_y = ggplot2::unit(1.5,"cm")) +
      ggplot2::theme(axis.line = ggplot2::element_blank(),
            axis.text.x = ggplot2::element_blank(),
            axis.text.y = ggplot2::element_blank(),
            axis.ticks = ggplot2::element_blank(),
            axis.title.x = ggplot2::element_blank(),
            axis.title.y = ggplot2::element_blank(),
            plot.title = ggplot2::element_text(colour = "blue", size = 20),
            plot.subtitle = ggplot2::element_text(size = 15),
            legend.position = "bottom",
            legend.spacing.y = ggplot2::unit(0, "lines"),
            legend.box.spacing = ggplot2::unit(0, "lines"),
            panel.grid.major = ggplot2::element_blank(),
            panel.background = ggplot2::element_rect("white"))
    print(a)}
}, time_interval = .8, loop = loops, movie.name= movie_name)


  }else{

    Urban_ET_24hours <- map[seq(3,49,2)]

    names(Urban_ET_24hours) <- c(rep("Urban_ET", 24), "geometry")

    names_m <- paste0(seq(0,23,1), " o'clock")

    animation::saveGIF({
      for (i in 1:24){
        a <- ggplot2::ggplot(Urban_ET_24hours[i]) +
          ggplot2::geom_sf(ggplot2::aes(fill = Urban_ET), colour = NA) +
          ggplot2::geom_sf(data = water_mask, fill = "white", size = 0, color = "transparent") +
          ggplot2::geom_sf(data = border, fill = "transparent", size = 1.2, color = "black") +
          ggplot2::labs(title = names_m[i], subtitle = gif_subtitle) +
          ggplot2::guides(linetype = ggplot2::guide_legend(title = NULL, order = 2),
                          color = ggplot2::guide_legend(order = 1)) +
          ggplot2::scale_fill_gradientn(breaks = breaks_scale, limits = limits_scale,
                                        colors = colors_pallete,
                                        name = "", na.value = NA,
                                        guide = ggplot2::guide_colorbar(direction = "horizontal",
                                                                        label.position = "bottom",
                                                                        title.vjust = 0, label.vjust = 0,
                                                                        frame.colour = "black",
                                                                        frame.linewidth = 0.5,
                                                                        frame.linetype = 1,
                                                                        title.position = "left",
                                                                        barwidth = 30, barheight = 1.5, nbin = 20,
                                                                        label.theme = ggplot2::element_text(angle = 0, size = 14))) +
          ggspatial::annotation_scale(location = "bl", height = ggplot2::unit(0.4, "cm"),
                                      pad_x = ggplot2::unit(2,"cm"), pad_y = ggplot2::unit(1.2,"cm"),
                                      text_pad = ggplot2::unit(0.25, "cm"),
                                      text_cex = 1.5) +
          ggspatial::annotation_north_arrow(location = "tr", which_north = "true",
                                            height = ggplot2::unit(2, "cm"), width = ggplot2::unit(2, "cm"),
                                            pad_x = ggplot2::unit(1,"cm"), pad_y = ggplot2::unit(1.5,"cm")) +
          ggplot2::theme(axis.line = ggplot2::element_blank(),
                         axis.text.x = ggplot2::element_blank(),
                         axis.text.y = ggplot2::element_blank(),
                         axis.ticks = ggplot2::element_blank(),
                         axis.title.x = ggplot2::element_blank(),
                         axis.title.y = ggplot2::element_blank(),
                         plot.title = ggplot2::element_text(colour = "blue", size = 20),
                         plot.subtitle = ggplot2::element_text(size = 15),
                         legend.position = "bottom",
                         legend.spacing.y = ggplot2::unit(0, "lines"),
                         legend.box.spacing = ggplot2::unit(0, "lines"),
                         panel.grid.major = ggplot2::element_blank(),
                         panel.background = ggplot2::element_rect("white"))
        print(a)}
    }, interval = time_interval, loop = loops, movie.name= movie_name)

      }

  print("done!")

return()

}
