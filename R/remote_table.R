## This code is part of the rMyCoPortal R package ##
## ©Franz-Sebastian Krah, 10-19-2018              ##

# Helper function remote_table; scrapes the observation records
#' @importFrom xml2 read_html
#' @importFrom rvest html_table

remote_table <- function(remdriver){

  x <- remdriver$findElement('class', 'styledtable')
  x <- x$getPageSource()[[1]]
  x <- read_html(x)
  x <- html_table(x)[[1]]
  # x <- retry_getHTML(remdriver, max_attempts = 10, wait_seconds = 1)

  return(x)
}
