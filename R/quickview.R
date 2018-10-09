#' Quickview on images of a record
#' @param Symbiota.ID, as found in output of \code{records}
#' @param verbose logical
#'
#' @import magick
#'
#' @examples
#' \dontrun{
#' pic <- quickview(4531213)
#' print(pic) # in Viewer (RStudio)
#' plot(pic) # as plot
#' }
#' @export

quickview <- function(Symbiota.ID = 4531213, verbose = TRUE){

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

  # close server
  dr$close()

  ## stop docker
  system(
    "docker stop $(docker ps -a -q)",
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )
  return(pic)
}
