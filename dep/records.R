#' Retrieve records from the MyCoPortal
#' @param taxon character string specifying the taxon name (e.g., species name, family name or higher taxon)
#' @param type character, one of c("Scientific Name only", "Family Only", "Higher Taxonomy", Common Name")
#' @param port default is 4445L
#' @param browser default is "chrome"
#' @param remoteServerAddr default is "localhost
#' @param verbose logical
#'
#' @import RSelenium
#' @import httr
#' @import shh.utils
#'
#' @examples
#' \dontrun{
#' am.dist <- records(taxon = "Amanita muscaria", type ="Scientific Name only")
#' plot_records(am.dist, fancy = FALSE)
#' }
#' @export


# type = "Scientific Name only"
# port = 4445L
# browserName = "chrome"
# remoteServerAddr = "localhost"
# taxon <- "Fomes fomentarius"
# verbose = TRUE
# library("RSelenium")
# library("XML")
# library("httr")
# library("stringr")
# library("rvest")
# library("xml2")

records <- function(taxon,
                    type = "Scientific Name only",
                    port = 4445L,
                    browserName = "chrome",
                    remoteServerAddr = "localhost",
                    verbose = TRUE) {


  ## call docker to create a selenium image
  out <- run.remote(
    cmd = "docker pull selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    print(out)

  if(out$cmd.error)
    stop("Docker not available")

  ## Allocate port
  out <- run.remote(
    cmd = "docker run -d -p 4445:4444 selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    print(out)

  ## Set up remote
  dr <- RSelenium::remoteDriver(remoteServerAddr = "localhost", port = port, browserName = browserName)

  ## test if worked
  dr$open(silent = ifelse(verbose, TRUE, FALSE))

  if(!dr$getStatus()$ready)
    stop("Remote server is not ready. \n Something wrong with docker?")

  make.url <- function(type, taxon, page = 1){
    switch (type,
            "Family or Scientific Name" = {
              stop("Please specify one of 2:5")
            },
            "Family Only" = {
              paste0("http://mycoportal.org/portal/collections/listtabledisplay.php?",
                     "taxa=", taxon,
                     "&",
                     "thes=1&",
                     "type=", 2,
                     "&db=all&",
                     "occindex=", page,
                     "&sortfield1=Catalog Number&sortfield2=&sortorder=asc")
            },
            "Scientific Name only" = {
              paste0("http://mycoportal.org/portal/collections/listtabledisplay.php?",
                     "taxa=", stringr::word(taxon,1,1), "%20", stringr::word(taxon, 2,2),
                     "&",
                     "thes=1&",
                     "type=",3,
                     "occindex=", page,
                     "&sortfield1=Catalog Number&sortfield2=&sortorder=asc")
            },
            "Higher Taxonomy" = {
              paste0("http://mycoportal.org/portal/collections/listtabledisplay.php?",
                     "taxa=", taxon,
                     "&",
                     "thes=1&",
                     "type=", 4,
                     "occindex=", page,
                     "&sortfield1=Catalog Number&sortfield2=&sortorder=asc")
            },
            "Common Name" = {
              paste0("http://mycoportal.org/portal/collections/listtabledisplay.php?",
                     "taxa=", taxon,
                     "&",
                     "thes=1&",
                     "type=", 5,
                     "occindex=", page,
                     "&sortfield1=Catalog Number&sortfield2=&sortorder=asc")
            }
    )
  }

  ## Compose URL Mycoportal query
  url <- make.url(type = type, taxon = taxon)

  ## Navigate to initial query page for total page assessment

  # navigate
  dr$navigate(url)
  Sys.sleep(3)
  # print url
  # print(dr$getCurrentUrl()[[1]])


  ## Extract number of pages
  nr.p <- nr_pages(remdriver = dr)
  cat("The query yielded", nr.p[[1]][2], "records", "on", nr.p[[2]], "pages \n")

  tabs <- list()
  for(i in 1:nr.p$page.nr){

    ## load new page
    dr$navigate(make.url(type = type, taxon = taxon, page = i))
    # waiting time untill new page is loaded
    Sys.sleep(2)

    if(verbose)
      cat("Extract table for page", i, "\n")
    if(verbose == 2)
      print(url)

    # extract table
    tabs[[i]] <- remote_table(dr)

  }

  # close server
  dr$close()

  ## stop docker
  system(
    "docker stop $(docker ps -a -q)",
    ignore.stdout = ifelse(verbose, FALSE, TRUE),
    ignore.stderr = ifelse(verbose, FALSE, TRUE)
  )

  ## combine all tables to 1 large table
  tabs <- do.call(rbind, tabs)

  ## add coordinates as lon lat
  tabs$coord <- stringr::str_extract(tabs$Locality, "\\d*\\.\\d*\\s\\W?\\d*\\.\\d*")
  coords <- data.frame(do.call(rbind, strsplit(tabs$coord , " ")))
  names(coords) <- c("lat", "lon")
  coords <- suppressWarnings(apply(coords, 2, function(x) as.numeric(as.character(x))))
  tabs <- data.frame(tabs, coords)

  ## print query result
  if(verbose)
    cat(dim(tabs)[1], "of records were found")

  return(tabs)
}
