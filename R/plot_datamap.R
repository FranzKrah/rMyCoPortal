#' Plot data heatmap on geographic map
#'
#' @param x an object of class "\code{mycodist}", see \link{mycoportal}
#' @param mapdatabase The map database to use in mapping, see \link{plot_distmap}
#' @param area list with four elements. Currently \code{mapdatabase} does not contain areas such as Europe,
#' however, this may be manually chosen like this:
#' area = list(min_long = -10, max_long = 24, min_lat = 14, max_lat = 70)
#' @param index character string, either "rec" (number of records) or "rich" (number of species)
#' @param plot logical
#' @import ggplot2 maps
#' @importFrom Hmisc capitalize
#' @importFrom dplyr left_join
#'
#' @author Franz-Sebastian Krah
#'
#' @examples
#' \dontrun{
#' am.dist <- mycoportal(taxon = "Amanita muscaria")
#' plot_datamap(am.dist, mapdatabase = "state")
#' }
#' @export


plot_datamap <- function(x, mapdatabase = "world", area = NULL, index = "rich", plot = TRUE){

  ipt <- x@records

  ## Initialize map
  if(!is.null(area)){
    mapdatabase <- "world" ## if area is provided, then mapdatabase needs to be set to "world"
  }
  world_map <- map_data(map = mapdatabase, region=".")

  ## Calculate number of records for each country or state

  if(index == "rich"){
    ipt <- data.frame(nr.spec = tapply(ipt$spec, ipt$Country, function(x) length(unique(x))))
    ipt <- data.frame(rownames(ipt), ipt)
    rownames(ipt) <- NULL


    tit <- paste(" Number of species for", x@query$taxon)

  }
  if(index == "rec"){
    ipt <- data.frame(table(ipt[,grep(capitalize(ifelse(mapdatabase == "world", "country", "state")),
                                      names(ipt))]))

    tit <- paste(" Number of records for", x@query$taxon)
  }

  names(ipt) <- c("Destination", "Count")
  ipt$Destination <- as.character(ipt$Destination)

  if(mapdatabase == "state")
    ipt$Destination <- tolower(ipt$Destination)


  ipt <- data.frame(rbind(ipt,
  cbind(Destination = setdiff(unique(world_map$region), unique(ipt$Destination)), Count = NA)))

  ## Add coordinates
  ipt <- left_join(ipt, world_map, by = c("Destination" = "region"))

  if(!is.null(area)){
    ipt <- ipt[(ipt$lat >= area$min_lat & ipt$lat <= area$max_lat) &
                 (ipt$lon >= area$min_long & ipt$lon <= area$max_long),]
  }

  ipt$Count <- as.numeric(ipt$Count)
  l.scale <- round(range(log10(ipt$Count), na.rm = TRUE))
  l.scale <- seq(l.scale[1], l.scale[2], 1)

  ## Plot

  p <- ggplot(ipt, aes(x = ipt$long, y = ipt$lat, group = ipt$group))+
    geom_polygon(aes(fill = ipt$Count), color = "gray65") +
    scale_fill_gradientn(colours =c("lightgray", "yellow", "red"),
                         trans = "log10", na.value = "white") +
    coord_fixed(1.3) +
    theme_bw() +
    xlab("Longitude") + ylab("Latitude") +
    theme(legend.position = "right", axis.text=element_text(size=12),
          axis.title=element_text(size=12),
          legend.text=element_text(size=12),
          plot.title = element_text(hjust = 0.5)) +
    ggtitle(paste(expression(Log[10]), tit)) +
    labs(fill = "")

  if(plot)
    plot(p)
  return(p)

}
