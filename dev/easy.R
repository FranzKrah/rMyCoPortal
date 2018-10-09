library(RSelenium)
library(httr)
out <- ssh.utils::run.remote(
  cmd = "docker pull selenium/standalone-chrome",
  verbose = FALSE,
  intern = TRUE
)
out <- ssh.utils::run.remote(
  cmd = "docker run -d -p 4445:4444 selenium/standalone-chrome",
  verbose = FALSE,
  intern = TRUE
)

ssh.utils::run.remote("docker-machine ip")


cprof <- getChromeProfile("/Users/krah/Downloads", "Profile 1")
dr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L, browserName = "chrome")

dr$open(silent = FALSE)

dr$navigate("http://mycoportal.org/portal/collections/harvestparams.php")
Sys.sleep(2)

button <- dr$findElement('xpath', "//*[@id='showtable']")
button$clickElement()

webElem <- dr$findElement(using = 'xpath', paste0("//*[@id='taxontype']/option[", 1 ,"]"))
webElem$clickElement()

## Taxon

webElem <- dr$findElement(using = 'xpath', paste0("//*[@id='taxontype']/option[", 4 ,"]"))
webElem$clickElement()

webElem <- dr$findElement('id', "taxa")
webElem$sendKeysToElement(list("Polyporales"))


webElem$sendKeysToElement(list(key = "enter"))
Sys.sleep(3)
dr$screenshot(display = TRUE, useViewer = TRUE)

# nr.p <- nr_pages(dr)
#
# tabs <- list()
# for(i in 0:nr.p$page.nr) {
#
#   tabs[[i+1]] <- retry_next_page_download(z = i, remdriver = dr, max_attempts = 10,
#                                           wait_seconds = 2)
#
# }

## Close Website
dr$close()
dr$closeServer()

## Stop docker
system(
  "docker stop $(docker ps -a -q)",
  ignore.stdout = TRUE,
  ignore.stderr = TRUE
)

