# Helper function remote_table
remote_table <- function(remdriver){

  x <- remdriver$findElement('class', 'styledtable')
  x <- x$getPageSource()[[1]]
  x <- xml2::read_html(x)
  x <- rvest::html_table(x)[[1]]
  # x <- retry_getHTML(remdriver, max_attempts = 10, wait_seconds = 1)

  return(x)
}
