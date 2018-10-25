#' Start Docker
#' @param verbose logical
#' @import sys
#' @details This should run for Unix platforms (e.g., Mac) and Windows. Docker available for download at: https://www.docker.com
#' @export
start_docker <- function(verbose = TRUE){

  cmd = "docker"

  out <- exec_internal(cmd, args = c("pull", "selenium/standalone-chrome"))
  if(out$status != 0)
    stop("Docker not available. Please start Docker app.")

  out <- exec_internal(cmd, args = c("run", "-d", "-p", "4445:4444", "selenium/standalone-chrome"),
                       error = FALSE)
  if (verbose)
    if (out$status == 0) {
      cat("Port is allocated \n")
    } else {
      stop_docker()
      stop("Port is not allocated. Run *stop_docker* and try again\n")
    }
  Sys.sleep(2)
}

#' Stop Docker
#' @details This should run for Unix platforms (e.g., Mac) and Windows. Docker available for download at: https://www.docker.com
#' @export
stop_docker <- function(){

  system(
    "docker stop $(docker ps -a -q)",
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )
  Sys.sleep(1)
}


