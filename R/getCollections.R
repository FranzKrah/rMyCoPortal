#' List of available collections
#' @import XML
#' @export

getCollections <- function(){

  ## Websites with collection picker
  coll <- htmlParse("http://mycoportal.org/portal/collections/index.php")

  ## xPath to collection names
  coll2 <- xpathSApply(coll, "//*[@id='specobsdiv']//form//div[2]//table/..//a")
  coll3 <- xpathSApply(coll, "//*[@id='specobsdiv']//form//div[3]//table/..//a")
  coll2 <- c(coll2, coll3)

  ## Extract names
  coll2 <- lapply(coll2, function(x) as(x, "character"))
  coll2 <- str_split(coll2, "\t\t\t\t")
  coll2 <- unlist(coll2)
  coll2 <- coll2[-grep("href|</a>|\tmore", coll2)]
  coll2 <- coll2[lapply(coll2, nchar) > 0]
  coll2 <- gsub("\t", "", coll2)

  return(coll2)
}
