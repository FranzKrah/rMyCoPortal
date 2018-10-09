#' Treemap of records data
#'
#' @param x an object of class "\code{mycodist}", see \link{records}
#' @param groupvar character of grouping variable, e.g., Country
#' @param ... further arguments may be passed to \link{treemap}
#' @param log logical whether data should be log-transformed
#' @return Map (using treemap package)
#' @import treemap
#' @importFrom Hmisc capitalize
#'
#' @examples
#' \dontrun{
#' am.dist <- records_ext(taxon = "Amanitaceae", taxon_type ="2")
#' plot_recordstreemap(am.dist, log = FALSE)
#' }
#' @export

# load("dev/amanitaceae.test.data.rda")
# input <- am.dist
# plot_recordstreemap(am.dist, log = FALSE)

plot_recordstreemap <- function(x, groupvar = "country", log = TRUE, ...){


  ipt <- x@records
  ipt <- tolower(ipt[,grep(capitalize(groupvar), names(ipt))])

  if(groupvar == "country"){
    ipt <- gsub("united\\sstates|u\\.s\\.a\\.|usa of america|\\[usa\\]", "usa", ipt)
    ipt[ipt == ""] <- NA
  }

  ipt <- data.frame(table(ipt))
  names(ipt) <- c("Destination", "Count")
  ipt$Count.log <- log10(ipt$Count)


  treemap::treemap(
    ipt,
    index = "Destination",
    vSize = ifelse(log, "Count.log", "Count"),
    vColor = ifelse(log, "Count.log", "Count"),
    palette = "RdYlBu",
    title = paste("Log[10] Number of records for", x@query$taxon, ...)
  )

}
