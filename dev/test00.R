library(rMyCoPortal)

## Test for species

spec.dist <- mycoportal(taxon = "Amanita muscaria")
save(spec.dist, file ="dev/amanita.test.data.rda")

spec.dist <- mycoportal(taxon = "Biscogniauxia alnophila")

## Test for Family
am.dist <- mycoportal(taxon = "Amanitaceae", taxon_type = 2)
save(am.dist, file ="dev/amanitaceae.test.data.rda")

## Test for order
ord.dist <- mycoportal(taxon = "Thelephorales", taxon_type = 4)
save(ord.dist, file ="dev/thelephorales.test.data.rda")

boletales.dist <- mycoportal_hightax(taxon = "Thelephorales", sleep = 2)
save(boletales.dist, file ="dev/boletales_mycoportal.rda")

russulales.dist <- mycoportal_hightax(taxon = "russulales", sleep = 2)
save(russulales.dist, file ="dev/russulales_mycoportal.rda")

cantharellales.dist <- mycoportal_hightax(taxon = "cantharellales", sleep = 2)
save(cantharellales.dist, file ="dev/cantharellales_mycoportal.rda")

agaricales.dist <- mycoportal_hightax(taxon = "agaricales", sleep = 2)
save(agaricales.dist, file ="dev/agaricales_mycoportal.rda")

## Test radius
spec.rad <- mycoportal(
  taxon = "Pleurotus",
  point_lat = "42",
  point_lon = "-72",
  radius = "50",
  taxon_type = "1")

## Plotting
load(file ="dev/cagaricales_mycoportal.rda")
load(file ="dev/cantharellales_mycoportal.rda")
load(file ="dev/russulales_mycoportal.rda")
load(file ="dev/boletales_mycoportal.rda")

x <- spec.dist
plot_distmap(x = x, mapdatabase = "world")
plot_recordstreemap(x = x, groupvar = "country", log = FALSE)
plot_datamap(x = x, mapdatabase = "world")
plot_datamap(x = x, mapdatabase = "world", index = "rich",
             area = list(min_long = -10, max_long = 30, min_lat = 30, max_lat = 70))


plot_distmap(x = ord.dist, mapdatabase = "world", panel = FALSE)
plot_recordstreemap(x = ord.dist, log = FALSE)
plot_datamap(x = ord.dist, mapdatabase = "world")

details(4531213)
