### Code adapted from karthik/gbifmap2.R:
### https://gist.github.com/karthik/4254076

#' Plot distribution data on map
#'
#' @param x an object of class "\code{mycodist}", see \link{records}
#' @param mapdatabase The map database to use in mapping. What you choose here
#' 		determines what you can choose in the region parameter. One of: county,
#' 		state, usa, world, world2, france, italy, or nz.
#' @param region The region of the world to map. From the maps package, run
#' 		\code{sort(unique(map_data("world")$region))} to see region names for the
#' 		world database layer, or e.g., \code{sort(unique(map_data("state")$region))}
#' 		for the state layer.
#' @param legend logical
#' @param interactive logical, if TRUE map will be plotted using function \code{mapview::mapview}
#' @param panel plots panels for each species for species above threshold supplied to \code{panel}, e.g., 1000
#' @param jitter If you use jitter, the amount by which to jitter
#' 		points in width, height, or both.
#' @return Map (using \link{ggplot2} package) of points or tiles on a world map.
#' @import ggplot2 mapview sf sp
#' @examples
#' \dontrun{
#' am.dist <- records_ext(taxon = "Amanita muscaria")
#' plot_distmap(am.dist, mapdatabase = "state")
#' }
#' @export

plot_distmap <- function(x,
                       mapdatabase = "world",
                       region = ".",
                       legend = FALSE,
                       panel = FALSE,
                       interactive = TRUE,
                       jitter = position_jitter(width = 0, height = 0)) {

  if(!interactive){
  ipt <- x@records

  tomap <- ipt[complete.cases(ipt$lat, ipt$lon), ]
  tomap <- tomap[-(which(tomap$lat <=90 || tomap$lon <=180)), ]
  world <- map_data(map=mapdatabase, region=region) # get world map data

  tomap <- tomap[(tomap$lat >= min(world$lat) & tomap$lat <= max(world$lat)) &
                   (tomap$lon >= min(world$long) & tomap$lon <= max(world$long)),]

  message(paste("Rendering map...plotting ", nrow(tomap), " points. Not all records have coordinates.", sep=""))

  if(panel){
    nr.rec <- table(tomap$spec)
    nr.rec <- names(nr.rec)[nr.rec>panel]
    tomap <- tomap[tomap$spec %in% nr.rec, ]
    }

  p <- ggplot(world, aes(long, lat)) + # make the plot
    geom_polygon(aes(group=group), fill="white", color="gray40", size=0.2) +
    geom_point(data=tomap, aes(lon, lat, color = spec),
               alpha = 0.4, size = 3, position = jitter) +
    labs(x="", y="") + theme_bw(base_size = 14) +
    ggtitle(paste("Distribution map for", x@query$taxon)) +
    coord_fixed(1.3)

  if(!legend)
    p <- p + theme(legend.position = "none")

  if(panel){
    p <- p + facet_wrap(~spec)
  }
  plot(p)
  return(p)
  }
  if(interactive){
    x@records <- x@records[!is.na(x@records$lat), ]
    x@records <- x@records[!is.na(x@records$lon), ]
    my.sf.point <- st_as_sf(x = x@records,
                            coords = c("lon", "lat"),
                            crs = "+proj=longlat +datum=WGS84")
    mapview(my.sf.point)
  }
}
