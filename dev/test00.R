library(rMyCoPortal)

## Test of functions

## no results
spec.dist <- mycoportal(taxon = "Biscogniauxia alnophila")
## results
spec.dist <- mycoportal(taxon = "Amanita muscaria")
## Test for Family
am.dist <- mycoportal(taxon = "Amanitaceae", taxon_type = 2)
## Test for order
thelephorales.dist <- mycoportal(taxon = "Thelephorales", taxon_type = 4)
## then switch to other function
thelephorales.dist <- mycoportal_hightax(taxon = "Thelephorales")

x <- spec.dist
plot_distmap(x = x, mapdatabase = "world")
plot_recordstreemap(x = x, groupvar = "country", log = FALSE)
plot_datamap(x = x, mapdatabase = "world")
plot_datamap(x = x, mapdatabase = "world", index = "rich",
             area = list(min_long = -10, max_long = 30, min_lat = 30, max_lat = 70))

details(x@records$Symbiota.ID[1])



### for debugging:

library("RSelenium")
library("XML")
library("httr")
library("stringr")
library("rvest")
library("xml2")
library("ssh.utils")


# taxon = "Amanita muscaria"
# country = "";
# state = "";
# county = "";
# locality = "";
# elevation_from = "";
# elevation_to = "";
# host = "";
# taxon_type = 4;
# north_lat = ""; south_lat = ""; west_lon = ""; east_lon = "";
# point_lat = ""; point_lon = ""; radius = "";
# collector = ""; collector_num = ""; coll_date1 = ""; coll_date2 = "";
# syns = TRUE;
# verbose = TRUE
# screenshot <- TRUE
# port = 4445L
# browserName = "chrome"
# remoteServerAddr = "localhost"
# radius <- "50"
# point_lat <- "42"
# point_lon <- "-72"
# collection <- "all"
