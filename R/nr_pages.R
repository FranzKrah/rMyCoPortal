# Helper function nr_pages
# @importFrom XML htmlTreeParse xpathApply xmlValue

nr_pages <- function(remdriver){
  nr <- remdriver$getPageSource()
  nr <- htmlTreeParse(nr[[1]], useInternalNodes = TRUE)
  nr <- xpathApply(nr, "//div//div", xmlValue)
  nr <- unlist(nr)
  nr <- nr[grep("records", nr)]
  nr <- stringr::str_extract_all(nr, "\\d*-\\d* of \\d*")
  nr <- Reduce(union, nr)
  count <- as.numeric(trimws(gsub("1-", "", strsplit(nr, "of")[[1]])))
  nr <- ceiling(count[2]/count[1])
  return(list(page.count = count, page.nr = nr))
}
