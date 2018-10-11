# retry
retry_next_page_download <- function(z, remdriver, max_attempts = 5,
                                     wait_seconds = 1) {


  k <- 0
  next_page_download <- function(z, remdriver){
    if(z == 0){
      tab <- remote_table(remdriver)
    }else{
      if(k == 0){
        if(z == 1){
          webElem <-  remdriver$findElement("xpath", "//*[@id='tablediv']/div[1]/div[2]/a")
          cat("next page (", z, ")")
          webElem$clickElement()
          Sys.sleep(3)
        }
        if(z > 1){
          webElem <- remdriver$findElement("xpath", "//*[@id='tablediv']/div[1]/div[2]/a[2]")
          cat("next page (", z, ")")
          webElem$clickElement()
          Sys.sleep(3)
        }
      }
      cat("... done\n")
      cat("download")
      tab <- remote_table(remdriver)
      cat("... done\n")
    }
    return(tab)
  }

  for (j in seq_len(max_attempts)) {

    out <- tryCatch(next_page_download(z, remdriver),
                    message = function(n) {print("Unstable")},
                    warning = function(w) {print(paste("Unstable"));},
                    error = function(e) {print(paste("Unstable"));})

    if (is.data.frame(out)) {
      return(out)
    }
    if(out == FALSE){
      if (wait_seconds > 0) {
        message("Retrying")
        Sys.sleep(wait_seconds)
        if(j == 5)
          remdriver$refresh()
      }
    }
    k <- k + 1
  }
}

retry_remote_table <- function(remdriver, max_attempts = 5,
                               wait_seconds = 1) {


  remote_table <- function(remdriver){

    x <- remdriver$findElement('class', 'styledtable')
    x <- x$getPageSource()[[1]]
    x <- xml2::read_html(x)
    x <- rvest::html_table(x)[[1]]
    # x <- retry_getHTML(remdriver, max_attempts = 10, wait_seconds = 1)

    return(x)
  }


  for (j in seq_len(max_attempts)) {

    out <- tryCatch(remote_table(remdriver),
                    message = function(n) {print("Unstable")},
                    warning = function(w) {print(paste("Unstable"));},
                    error = function(e) {print(paste("Unstable"));})

    if (is.data.frame(out)) {
      return(out)
    }
    if(out == FALSE){
      if (wait_seconds > 0) {
        message("Retrying")
        Sys.sleep(wait_seconds)
        if(j == floor(max_attempts/2))
          remdriver$refresh()
      }
    }
  }
}

