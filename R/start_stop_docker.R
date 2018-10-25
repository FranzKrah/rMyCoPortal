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

  out <- exec_internal("docker", args = c("ps", "-q"))


  stdo <- tempfile()
  out <- exec_wait("docker", "ps", std_out = stdo)
  out <- readLines(stdo)
  out[2] <- gsub("\\s+", " ", out[2])
  out[2] <- stringr::str_split(out[[2]], "\\s")
  nam <- out[[2]][length(out[[2]])]

  out <- exec_internal("docker", args = c("stop", nam))


  # system(
  #   "docker stop $(docker ps -a -q)",
  #   ignore.stdout = TRUE,
  #   ignore.stderr = TRUE
  # )
  Sys.sleep(1)
}


