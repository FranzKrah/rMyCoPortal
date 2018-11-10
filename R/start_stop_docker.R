#' Start Docker
#' @param verbose logical
#' @param sleep waiting time for system call to finish
#' @import sys
#' @details This should run for Unix platforms (e.g., Mac) and Windows. Docker available for download at: https://www.docker.com
#' @export
start_docker <- function(verbose = TRUE, sleep = 2){

  out <- exec_internal("docker", args = c("ps", "-q"))
  if(out$status != 0)
    stop("Docker not available. Please start Docker app.")

  if(verbose){
    out <- exec_wait("docker", args = c("pull", "selenium/standalone-chrome"))
  }else{
    out <- exec_internal("docker", args = c("pull", "selenium/standalone-chrome"))
  }
  Sys.sleep(sleep)

  # out <- exec_internal("docker", args = c("run", "-d", "-p", "4445:4444", "selenium/standalone-chrome"),
                         # error = FALSE)


  tmp <- tempdir()
  std.out <- paste0(tmp, "/out.txt")
  std.err <- paste0(tmp, "/err.txt")
  out <- exec_background("docker", args = c("run", "-d", "-p", "4445:4444", "selenium/standalone-chrome"),
                         std_out = std.out, std_err = std.err)

  Sys.sleep(1)
  if(out != 0){
    err <- readLines(std.err)
    cat(err)
  }
  unlink(std.out)
  unlink(std.err)
}

#' Stop Docker
#' @param sleep waiting time for system call to finish
#' @details This should run for Unix platforms (e.g., Mac) and Windows. Docker available for download at: https://www.docker.com
#' @export
stop_docker <- function(sleep = 2){

  out <- exec_internal("docker", args = c("ps", "-q"))

  stdo <- tempfile()
  out <- exec_wait("docker", "ps", std_out = stdo)
  out <- readLines(stdo)
  out[2] <- gsub("\\s+", " ", out[2])
  out[2] <- stringr::str_split(out[[2]], "\\s")
  nam <- out[[2]][length(out[[2]])]

  out <- exec_internal("docker", args = c("stop", nam))

  Sys.sleep(sleep)
}


