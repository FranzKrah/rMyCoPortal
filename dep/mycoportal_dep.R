#' Retrieve records from the MyCoPortal
#' @param taxon character string specifying the taxon name (e.g., species name, family name or higher taxon). To query higher taxa, e.g. on order level, I recommend using \code{\link{mycoportal_hightax}}
#' @param country character string specifying country, e.g., "USA"
#' @param state character string specifying state, e.g., "Massachusetts"
#' @param county character string specifying county, e.g., "Worcester"
#' @param locality character string specifying locality, e.g., "Harvard Forest"
#' @param elevation_from character string, meter, e.g., "1000"
#' @param elevation_to character string, meter
#' @param host character string specifying host species, e.g., "Betula alba"
#' @param collection either "all" or a vector or integers with number corresponding to collection. For a list of collections use function \code{getCollections()}
#' @param taxon_type integer, one of 1 to 5 representing "Family or Scientific Name", "Scientific Name only", "Family Only", "Higher Taxonomy", Common Name"
#' @param north_lat character string, coordinate e.g., "45"
#' @param south_lat character string, coordinate
#' @param west_lon character string, coordinate, e.g., "-72"
#' @param east_lon character string, coordinate
#' @param point_lat character string, coordinate
#' @param point_lon character string, coordinate
#' @param radius character string, km, e.g., "50"
#' @param collector character string specifying collector name
#' @param collector_num character string specifying collector number
#' @param coll_date1 character string specifying collection data from, e.g., "19 August 1926"
#' @param coll_date2 character string specifying collection data from, e.g., "19 August 2018"
#' @param syns logical, if TRUE synonyms from MycoBank and IndexFungorum are searched
#' @param port default is 4445L
#' @param remoteServerAddr default is "localhost
#' @param verbose logical
#' @param screenshot logical, whether screenshot of results should be displayed in Viewer
#' @param browserName character string specifying the browser to use, recommended: "chrome"
#'
#' @return x an object of class "\code{\link{records}}" with the following components:
#' \item{nr.records}{A numeric giving the number of records retrieved}
#' \item{citation}{A character string with the recommended citation from the website}
#' \item{query}{A list of the user arguments used}
#' \item{records}{A data.frame with the query records results}
#' \item{db}{A character string specifying the database (currently only MyCoPortal)}
#'
#' @details Interface to the web database MyCoPortal. Query records available by various user specifications.
#' @references \url{http://mycoportal.org/portal/index.php}
#' @references A. N. Miller and S. T. Bates The Mycology Collections Portal (MyCoPortal) (2017) Cryptogamie Mycologie, 37:15-36.
#'
#' @import RSelenium httr RCurl
#' @importFrom XML htmlParse xpathApply xmlValue
#' @importFrom crayon red
#'
#' @author Franz-Sebastian Krah
#'
#' @examples
#' \dontrun{
#' ## Download Amanita muscaria observations and plot visualize data
#' am.dist <- mycoportal(taxon = "Amanita muscaria")
#' plot_distmap(x = am.dist, mapdatabase = "world", interactive = FALSE)
#' plot_distmap(x = am.dist, mapdatabase = "state", interactive = FALSE)
#' plot_distmap(x = am.dist, mapdatabase = "world", interactive = TRUE)
#' plot_datamap(x = am.dist, mapdatabase = "world")
#' plot_recordstreemap(x = am.dist, log = FALSE)
#' }
#' @export


mycoportal <- function(taxon = "Amanita muscaria",
           country = "",
           state = "",
           county = "",
           locality = "",
           elevation_from = "",
           elevation_to = "",
           host = "",
           taxon_type = 1,
           collection = "all",
           north_lat = "",
           south_lat = "",
           west_lon = "",
           east_lon = "",
           point_lat = "",
           point_lon = "",
           radius = "",
           collector = "",
           collector_num = "",
           coll_date1 = "",
           coll_date2 = "",
           syns = TRUE,
           verbose = TRUE,
           screenshot = TRUE,
           port = 4445L,
           browserName = "chrome",
           remoteServerAddr = "localhost") {


  # test internet conectivity
  if(!url.exists("r-project.org") == TRUE)
    stop( "Not connected to the internet. Please create a stable connection and try again." )
  if(!is.character(getURL("http://mycoportal.org/portal/index.php")))
    stop(" Database is not available : http://mycoportal.org/portal/index.php")

  if(taxon_type == "4"){
    cat(red("*mycoportal* may be unstable for higher taxon queries.","\n",
            "If you encounter stabilitiy issues, try *mycoportal_hightax*"))

    ent <- readline(prompt="Continue? [y/n]")
    if(ent == "n")
      stop("Aborted by user")
  }

  if(missing(taxon))
    stop("At least a species name has to be specified")


  # Initialize session ------------------------------------------------------

  ## Set up Docker image
  out <- ssh.utils::run.remote(
    cmd = "docker pull selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    out$cmd.out[4]
  if(verbose > 1)
    print(out)

  if(out$cmd.error)
    stop("Docker not available. Please start Docker app.")

  ## Allocate port
  out <- ssh.utils::run.remote(
    cmd = "docker run -d -p 4445:4444 selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  Sys.sleep(1)
  if(verbose)
    if(is.na(out$cmd.out[2])){
      cat("Port is allocated \n")
    }else{print(out$cmd.out[2])}
  if(verbose > 1)
    cat(out)

  ## Set up remote
  dr <- remoteDriver(remoteServerAddr = "localhost", port = port, browserName = browserName)
  Sys.sleep(1)

  ## Open connection; run server
  out <- capture.output(dr$open(silent = FALSE))
  Sys.sleep(2)
  if(verbose > 1)
    cat(out)

  if(dr$getStatus()$ready)
    cat(dr$getStatus()$message[1], "\n")
  if(!dr$getStatus()$ready)
    stop("Remote server is not running \n Please check if Docker is installed!")


  # Open Website -----------------------------------------------------------
  cat(ifelse(verbose, "Open website\n", ""))
  ## Navigate to website

  if(collection == "all"){ #usually it is convenient to query all collections
    dr$navigate("http://mycoportal.org/portal/collections/harvestparams.php")
    Sys.sleep(3)
  }else{ ## however, user may want specific collections
    dr$navigate("http://mycoportal.org/portal/collections/index.php")
    Sys.sleep(3)

    ## uncheck all collections
    button <- dr$findElement('xpath', "//*[@id='dballcb']")
    button$clickElement()

    ctn <- getCollections()
    nonus <- grep("Addis", ctn)

    ## check the desired ones
    for(i in collection){
        button <- dr$findElement('xpath', paste0("//*[@id='specobsdiv']/form/div[",
                                                 ifelse(i < nonus, 2,3),
                                                 "]/table/tbody/tr[",
                                                 i,
                                                 "]/td[2]/input"))
        button$clickElement()
        Sys.sleep(1)
    }
  }

  ## Enter user query ------------------------------------------------------------------
  cat(ifelse(verbose, "Send user query to website:\n", ""))

  # input arguments (will be exportet)
  argg <- do.call(c, as.list(match.call()))
  query <- argg <- argg[-1]
  argg <- do.call(c, argg)
  print(argg)

  ## Fill elements: user defined query input

  ## Checkbox: Show results in table view
  # [this has to be checked always, otherwise table download will not work]
  button <- dr$findElement('xpath', "//*[@id='showtable']")
  button$clickElement()


  ## Checkbox: Include Synonyms from Taxonomic Thesaurus
  if(syns){
    button <- dr$findElement('xpath', "//*[@id='harvestparams']/div[3]/span/input")
    button$clickElement()
  }

  ## Taxon type
  webElem <- dr$findElement(using = 'xpath', paste0("//*[@id='taxontype']/option[", taxon_type ,"]"))
  webElem$clickElement()

  ## Taxon
  webElem <- dr$findElement('id', "taxa")
  webElem$sendKeysToElement(list(taxon))

  ## Country
  webElem <- dr$findElement('id', "country")
  webElem$sendKeysToElement(list(country))

  ## State
  webElem <- dr$findElement('id', "state")
  webElem$sendKeysToElement(list(state))

  ## County
  webElem <- dr$findElement('id', "county")
  webElem$sendKeysToElement(list(county))

  ## Locality
  webElem <- dr$findElement('id', "locality")
  webElem$sendKeysToElement(list(locality))

  ## Elevation lower border
  webElem <- dr$findElement('id', "elevlow")
  webElem$sendKeysToElement(list(elevation_from))

  ## Elevation upper border
  webElem <- dr$findElement('id', "elevhigh")
  webElem$sendKeysToElement(list(elevation_to))

  ## Host (Plant species name)
  webElem <- dr$findElement('id', "assochost")
  webElem$sendKeysToElement(list(host))


  ##### Latitude and Longitude
  ## North latitude border
  webElem <- dr$findElement('id', "upperlat")
  webElem$sendKeysToElement(list(north_lat))

  ## South latitude border
  webElem <- dr$findElement('id', "bottomlat")
  webElem$sendKeysToElement(list(south_lat))

  ## West longitude border
  webElem <- dr$findElement('id', "leftlong")
  webElem$sendKeysToElement(list(west_lon))

  ## East longitude border
  webElem <- dr$findElement('id', "rightlong")
  webElem$sendKeysToElement(list(east_lon))

  ##### Point-Radius Search
  ## Latitude of point
  webElem <- dr$findElement('id', "pointlat")
  webElem$sendKeysToElement(list(point_lat))

  ## Longitude of point
  webElem <- dr$findElement('id', "pointlong")
  webElem$sendKeysToElement(list(point_lon))

  ## Radius in km
  webElem <- dr$findElement('id', "radiustemp")
  webElem$sendKeysToElement(list(radius))


  ##### Collector Criteria
  ## Collector name
  webElem <- dr$findElement('id', "collector")
  webElem$sendKeysToElement(list(collector))

  ## Collector numbner
  webElem <- dr$findElement('id', "collnum")
  webElem$sendKeysToElement(list(collector_num))

  ## Date record was found (from)
  webElem <- dr$findElement('id', "eventdate1")
  webElem$sendKeysToElement(list(coll_date1))

  ## Date record was found (to)
  webElem <- dr$findElement('id', "eventdate2")
  webElem$sendKeysToElement(list(coll_date2))



  # Press Enter -----------------------------------------------------
  webElem$sendKeysToElement(list(key = "enter"))
  Sys.sleep(3)

  if(screenshot)
    dr$screenshot(display = TRUE, useViewer = TRUE)


  # Test whether results were found --------------------------------
  res <- htmlParse(dr$getPageSource()[[1]])
  res <- xpathApply(res, "//div", xmlValue)
  res <- grep("No records found matching the query", res)

  if(length(res)>0){
    # close server
    dr$close()

    ## stop docker
    cat(ifelse(verbose, "Stop Docker\n", ""))
    system(
      "docker stop $(docker ps -a -q)",
      ignore.stdout = TRUE,
      ignore.stderr = TRUE
    )
    cat(red(paste0(paste(rep("#", 43), collapse = ""),
                    "\n### No records for this query ###\n",
                    paste(rep("#", 43), collapse = ""))))
    opt <- options(show.error.messages=FALSE)
    on.exit(options(opt))
    return(records(nr.records = 0,
                    citation = "Not applicable",
                    query = query,
                    records = data.frame(NULL),
                    db = "MyCoPortal"))
  }


  # Download tables -------------------------------------------------
  nr.p <- nr_pages(dr)
  cat(ifelse(verbose, paste("Downloading", nr.p, "pages\n"), ""))
  cat(red("Make sure you have a stable internet connection!\n"))

  ## Download tables in page-wise batches
  tabs <- list()
  for (i in 0:(nr.p-1)) {
    tabs[[i + 1]] <- retry_next_page_download(
        z = i,
        remdriver = dr,
        max_attempts = 5,
        wait_seconds = 2
      )

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

  ## Return downloaded query results as data.frame

  if(collection != "all"){
    ctn <- getCollections()
    collection <- ctn[collection]
    collection <- paste(collection, collapse = "; ")
  }else{
    collection <- "All available collections used"
  }

  cit <-
    paste0(
      "Biodiversity occurrence data published by: <",
      collection,
      "> (Accessed through MyCoPortal Data Portal, http//:mycoportal.org/portal/index.php, ",
      Sys.Date(),
      ")"
    )

  records(
    nr.records = nrow(tabs),
    citation = cit,
    query = query,
    records = tabs,
    db = "MyCoPortal"
  )
}
