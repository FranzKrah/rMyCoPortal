## This code is part of the rMyCoPortal R package ##
## ©Franz-Sebastian Krah, 10-19-2018              ##

# Helper function nr_pages
#' @importFrom XML htmlTreeParse xpathApply xmlValue
#' @import stringr

nr_pages <- function(remdriver) {
  nr <- remdriver$getPageSource()
  nr <- htmlTreeParse(nr[[1]], useInternalNodes = TRUE)
  nr <- xpathApply(nr, "//div//div", xmlValue)
  nr <- unlist(nr)
  nr <- nr[grep("records", nr)]
  nr <- str_extract_all(nr, "\\d*-\\d* of \\d*")
  nr <- Reduce(union, nr)

  if (length(grep("of", nr)) > 0) {
    count <- as.numeric(trimws(gsub("1-", "", strsplit(nr, "of")[[1]])))
    nr <- ceiling(count[2] / count[1])
  } else{
    nr <- 1
  }
  return(nr)
}
