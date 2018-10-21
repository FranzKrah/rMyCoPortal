#' Retrieve higher taxon records from the MyCoPortal
#' @param taxon character string specifying the taxon name (here usually higher taxon, e.g., order level)
#' @param port default is 4445L
#' @param remoteServerAddr default is "localhost
#' @param verbose logical
#' @param sleep set time to wait till page is loaded, default: 2 (don't go lower than that)
#' @param screenshot logical, whether screenshot of results should be displayed in Viewer
#' @param browserName character string specifying the browser to use, recommended: "chrome"
#'
#' @return x an object of class "\code{mycodist}" with the following components:
#' \item{nr.records}{A numeric giving the number of records retrieved}
#' \item{citation}{A character string with the recommended citation from the website}
#' \item{query}{A list of the user arguments used}
#' \item{records}{A data.frame with the query records results}
#'
#' @details Interface to the web database MyCoPortal for higher taxonomic queries, e.g., order level. Here only full query results can be retrieved. If you want to make more specific queries please try \code{\link{records}}.
#' @references see \code{\link{records}}
#'
#' @import RSelenium XML httr
#' @importFrom crayon red
#'
#' @author Franz-Sebastian Krah
#'
#' @examples
#' \dontrun{
#' ## Query Amanitacae and plot on world map or USA map
#' poly.dist <- records_hightax(taxon = "polyporales", taxon_type = 2)
#' recordsmap(poly.dist, mapdatabase = "world", legend = FALSE)
#' recordsmap(poly.dist, mapdatabase = "state",legend = FALSE)
#' }
#' @export
#'

records_hightax <- function(taxon = "Polyporales",
                        verbose = TRUE,
                        screenshot = TRUE,
                        port = 4445L,
                        browserName = "chrome",
                        remoteServerAddr = "localhost",
                        sleep = 2){

  ## Allocate port
  out <- ssh.utils::run.remote(
    cmd = "docker run -d -p 4445:4444 selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    if(is.na(out$cmd.out[2])){
      cat("Port is allocated \n")
    }else{print(out$cmd.out[2])}
  if(verbose > 1)
    cat(out)

  ## Set up remote
  dr <- RSelenium::remoteDriver(remoteServerAddr = "localhost", port = port, browserName = browserName)
  Sys.sleep(sleep)

  ## Open connection; run server
  out <- capture.output(dr$open(silent = FALSE))
  Sys.sleep(1)
  if(verbose > 1)
    cat(out)

  if(dr$getStatus()$ready)
    cat(dr$getStatus()$message[1], "\n")
  if(!dr$getStatus()$ready)
    stop("Remote server is not running \n Please check if Docker is installed!")

  makeURL <- function(taxon, i){
    paste0("http://mycoportal.org/portal/collections/listtabledisplay.php?",
          "taxa=", taxon,
          "&thes=1&type=4&db=all",
          "&occindex=", i,
          "&sortfield1=Catalog%20Number&sortfield2=&sortorder=asc")
  }

  cat("Navitage to page\n")
  url <- makeURL(taxon, 1)
  dr$navigate(url)
  Sys.sleep(3)

  dr$screenshot(display = TRUE)

  # Download tables -------------------------------------------------

  nr.p <- nr_pages(dr)

  cat(ifelse(verbose, paste("Downloading", nr.p, "records\n"), ""))
  cat(red("Make sure you have a stable internet connection!\n"))

  tabs <- list()
  for(i in 1:nr.p){
    cat("page (", i, ") ...download ")
    dr$navigate(makeURL(taxon = taxon, i = i))
    Sys.sleep(sleep)
    tabs[[i]] <- retry_remote_table(dr,
                                    max_attempts = 10,
                                    wait_seconds = 2)
    cat("...done\n")
  }

  ## Rbind all tables
  tabs <- do.call(rbind, tabs)
  cat(nrow(tabs), "records were downloaded \n")

  ## Add coordinates as lon lat column
  tabs$coord <- stringr::str_extract(tabs$Locality, "-?\\d*\\.\\d*\\s\\-?\\d*\\.\\d*")
  coords <- data.frame(do.call(rbind, strsplit(tabs$coord , " ")))
  names(coords) <- c("lat", "lon")
  coords <- suppressWarnings(apply(coords, 2, function(x) as.numeric(as.character(x))))
  tabs <- data.frame(tabs, coords)
  tabs$spec <- stringr::word(tabs$Scientific.Name, 1,2)



  # Close Website and Server ------------------------------------------------
  cat(ifelse(verbose, "Close website and quit server\n", ""))

  ## Close Website
  dr$close()

  ## Stop docker
  system(
    "docker stop $(docker ps -a -q)",
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )

  cit <- paste0("Biodiversity occurrence data published by: <all> (Accessed through MyCoPortal Data Portal, http//:mycoportal.org/portal/index.php, ", Sys.Date(), ")")
  mycodist(nr.records = nrow(tabs), citation = cit, query = list(taxon = taxon, taxon_type = 4), records = tabs)

}
