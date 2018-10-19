#' Retrieve images and meta-data for a specific record (specimen)
#' @param Symbiota.ID, as found in output of \code{records}
#' @param verbose logical
#'
#' @import magick rvest
#'
#' @author Franz-Sebastian Krah
#'
#' @examples
#' \dontrun{
#' # use function records to download records; then use one of the IDs:
#' pic <- details(4531213)
#' # show screenshot of details for this specimen
#' print(pic$screenshot) # in Viewer (RStudio)
#' plot(pic$screenshot) # as plot
#' # Look at one of the images in more detail
#' print(image_read(pic$urls[2])) # not all links are working in all instances
#' # Look at meta data; this specimen was collected in 2012 in Washington
#' pic$meta
#' }
#' @export

details <- function(Symbiota.ID = 4531213, verbose = TRUE){

  out <- ssh.utils::run.remote(
    cmd = "docker pull selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    print(out)

  if(out$cmd.error)
    stop("Docker not available")

  ## Allocate port
  out <- ssh.utils::run.remote(
    cmd = "docker run -d -p 4445:4444 selenium/standalone-chrome",
    verbose = FALSE,
    intern = TRUE
  )
  if(verbose)
    print(out)

  ## Set up remote
  dr <- RSelenium::remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "chrome")
  Sys.sleep(1)

  ## test if worked
  dr$open(silent = ifelse(verbose, FALSE, TRUE))
  Sys.sleep(1)

  if(!dr$getStatus()$ready)
    stop("Remote server is not ready. \n Something wrong with docker?")

  # navigate
  dr$navigate(paste0(
    "http://mycoportal.org/portal/collections/individual/index.php?occid=",
    Symbiota.ID,
    "&clid=0"))
  Sys.sleep(3)

  tmp <- tempdir()
  # dr$screenshot(display = TRUE, useViewer = TRUE)
  dr$screenshot(useViewer = TRUE, file = paste0(tmp, "screenshot.jpg"))
  pic <- image_read(paste0(tmp, "screenshot.jpg"))

  files <- list.files(tmp, full.names = TRUE)
  files <- files[-grep("rs-graphics", files)]
  unlink(files, force = TRUE, recursive = TRUE)


  x <- dr$findElement('id', 'occurtab')
  x <- x$getPageSource()[[1]]
  x <- read_html(x)

  ## Extract meta-data
  lab <- html_nodes(x, "div div b") %>% html_text()
  res <- html_nodes(x, "div div") %>% html_text()
  res <- gsub("\t", "", res)

  ocs <- grep(paste(lab, collapse = "|"), res)
  n <- unlist(lapply(res[ocs], nchar))
  res <- res[ocs]
  res <- res[n<150]
  res <- gsub("\n", "", res)
  res <- res[-duplicated(res)]
  res <- res[-grep("ImagesOpen|CommentLogin", res)]
  res <- gsub("#", "", res)
  res <- gsub(" :", ":", res)
  res <- do.call(rbind, str_split(res, ":", n = 2))
  res <- trimws(res)
  res <- data.frame(res)
  names(res) <- c("name", "value")

  ## Extract URLs
  x <- html_attr(html_nodes(x, "a"), "href")
  urls <- x[grep("https", x)]

  # close server
  dr$close()

  ## stop docker
  system(
    "docker stop $(docker ps -a -q)",
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )
  return(list(screenshot = pic, meta = res, urls = urls))
}
