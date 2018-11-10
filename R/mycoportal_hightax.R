#' Retrieve higher taxon records from the MyCoPortal
#' @param taxon character string specifying the taxon name (here usually higher taxon, e.g., order level)
#' @param port default is 4445L
#' @param remoteServerAddr default is "localhost
#' @param verbose logical
#' @param wait set time to wait till page is loaded, default: 2 (don't go lower than that)
#' @param screenshot logical, whether screenshot of results should be displayed in Viewer
#' @param browserName character string specifying the browser to use, recommended: "chrome"
#' @param wait numberic specifying the seconds to wait for website to load, recommended 2 for good internet connections;
#' higher otherwise. It would be good to first look up the number of pages for a species and to compare it with the function output to see whether loading times are sufficient.
#'
#' @return x an object of class "\code{records}" with the following components:
#' \item{nr.records}{A numeric giving the number of records retrieved}
#' \item{citation}{A character string with the recommended citation from the website}
#' \item{query}{A list of the user arguments used}
#' \item{records}{A data.frame with the query records results}
#' \item{db}{A character string specifying the database (currently only MyCoPortal)}
#'
#' @details Interface to the web database MyCoPortal for higher taxonomic queries, e.g., order level. Here only full query results can be retrieved. If you want to make more specific queries please try \code{\link{mycoportal}}.
#' @references see \code{\link{mycoportal}}
#'
#' @import RSelenium
#' @importFrom crayon red
#'
#' @author Franz-Sebastian Krah
#'
#' @examples
#' \dontrun{
#' ## Query Amanitacae and plot on world map or USA map
#' poly.dist <- mycoportal_hightax(taxon = "polyporales", taxon_type = 2)
#' recordsmap(poly.dist, mapdatabase = "world", legend = FALSE)
#' recordsmap(poly.dist, mapdatabase = "state",legend = FALSE)
#' }
#' @export
#'

mycoportal_hightax <- function(taxon = "Polyporales",
                        verbose = TRUE,
                        screenshot = TRUE,
                        port = 4445L,
                        browserName = "chrome",
                        remoteServerAddr = "localhost",
                        wait = 2){


  ## test
  if(!url.exists("r-project.org") == TRUE)
    stop( "Not connected to the internet. Please create a stable connection and try again." )
  if(!is.character(getURL("http://mycoportal.org/portal/index.php")))
    stop(" Database is not available : http://mycoportal.org/portal/index.php")

  if(missing(taxon))
    stop("At least a species name has to be specified")

  wait <- ifelse(wait<=2, 2, wait)

  ## Allocate port
  start_docker(verbose = verbose, sleep = wait)

  ## Set up remote
  dr <- RSelenium::remoteDriver(remoteServerAddr = "localhost", port = port, browserName = browserName)
  Sys.sleep(wait)

  ## Open connection; run server
  out <- capture.output(dr$open(silent = FALSE))
  Sys.sleep(wait)
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

  cat(ifelse(verbose, "Open website\n", ""))
  url <- makeURL(taxon, 1)
  dr$navigate(url)
  Sys.sleep(wait+1)

  if(screenshot)
    dr$screenshot(display = TRUE)

  # Download tables -------------------------------------------------

  nr.p <- nr_pages(dr)

  cat(ifelse(verbose, paste("Downloading", nr.p, "pages\n"), ""))
  cat(red("Make sure you have a stable internet connection!\n"))

  tabs <- list()
  for(i in 1:nr.p){
    cat("page (", i, ") ...download ")
    dr$navigate(makeURL(taxon = taxon, i = i))
    Sys.sleep(wait)
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
  stop_docker()

  cit <-
    paste0(
      "Biodiversity occurrence data published by: <all> (Accessed through MyCoPortal Data Portal, http//:mycoportal.org/portal/index.php, ",
      Sys.Date(),
      ")"
    )

  records(
    nr.records = nrow(tabs),
    citation = cit,
    query = list(taxon = taxon, taxon_type = 4),
    records = tabs,
    db = "MyCoPortal"
  )

}
