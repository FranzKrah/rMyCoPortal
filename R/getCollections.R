#' List of available collections
#'
#' @details Get list of avaible collections from the MyCoPortal. For details also see \url{http://mycoportal.org/portal/collections/index.php}
#'
#' @author Franz-Sebastian Krah
#'
#' @importFrom XML xpathSApply htmlParse
#' @export

getCollections <- function(){

  ## Websites with collection picker
  coll <- htmlParse("http://mycoportal.org/portal/collections/index.php")

  ## xPath to collection names
  coll2 <- xpathSApply(coll, "//*[@id='specobsdiv']//form//div[2]//table/..//a")
  coll3 <- xpathSApply(coll, "//*[@id='specobsdiv']//form//div[3]//table/..//a")
  coll <- c(coll2, coll3)

  ## Extract names
  coll <- lapply(coll, function(x) as(x, "character"))
  coll <- str_split(coll, "\t\t\t\t")
  coll <- unlist(coll)
  coll <- coll[-grep("href|</a>|\tmore", coll2)]
  coll <- coll[lapply(coll, nchar) > 0]
  coll <- gsub("\t", "", coll)

  return(coll)
}
