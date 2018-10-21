## This code is part of the rMyCoPortal R package ##
## ©Franz-Sebastian Krah, 10-19-2018              ##

# Helper function; retry if internet connection temporatliy fluctuates

next_page_download <- function(z, remdriver, k) {

  if(z == 0){
    cat("page ( 1 ) ...download ")
    tab <- remote_table(remdriver)
    cat("...done \n")
  }else{
    if(k == 0){
      if(z == 1){
        webElem <-  remdriver$findElement("xpath", "//*[@id='tablediv']/div[1]/div[2]/a")
        cat("page (", z+1, ")")
        webElem$clickElement()
        Sys.sleep(3)
      }
      if(z > 1){
        webElem <- remdriver$findElement("xpath", "//*[@id='tablediv']/div[1]/div[2]/a[2]")
         cat("page (", z+1, ")")
        webElem$clickElement()
        Sys.sleep(3)
      }
    }
    cat(" ...download ")
    tab <- remote_table(remdriver)
    cat("...done\n")
  }
  return(tab)
}


retry_next_page_download <- function(z,
                                     remdriver,
                                     max_attempts = 5,
                                     wait_seconds = 1) {


  k <- 0

  for (j in seq_len(max_attempts)) {

    out <- tryCatch(next_page_download(z, remdriver, k),
                    message = function(n) {"Unstable"},
                    warning = function(w) {"Unstable";},
                    error = function(e) {"Unstable";})

    # print(out)
    if (is.data.frame(out)) {
      return(out)
    }
    if(out == "Unstable"){
      cat(red("\nLost connection\n"))
      if (wait_seconds > 0) {
        cat(red("Retrying..."))
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

    return(x)
  }


  for (j in seq_len(max_attempts)) {

    out <- tryCatch(remote_table(remdriver),
                    message = function(n) {"Unstable"},
                    warning = function(w) {"Unstable";},
                    error = function(e) {"Unstable";})

    if (is.data.frame(out)) {
      return(out)
    }
    if(out == "Unstable"){
      cat(red("\nLost connection\n"))
      if (wait_seconds > 0) {
        cat(red("Retrying..."))
        Sys.sleep(wait_seconds)
        if(j == floor(max_attempts/2))
          remdriver$refresh()
      }
    }
  }
}
