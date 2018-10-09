library(rMyCoPortal)



## Test for species
spec.dist <- records(taxon = "Amanita muscaria")
save(spec.dist, file ="dev/amanita.test.data.rda")

## Test for Family
am.dist <- records(taxon = "Amanitaceae", taxon_type = 2)
save(am.dist, file ="dev/amanitaceae.test.data.rda")

## Test for order
ord.dist <- records(taxon = "Thelephorales", taxon_type = 4)
save(ord.dist, file ="dev/thelephorales.test.data.rda")

boletales.dist <- records_hightax(taxon = "boletales", sleep = 2)
save(boletales.dist, file ="dev/boletales_mycoportal.rda")

russulales.dist <- records_hightax(taxon = "russulales", sleep = 2)
save(russulales.dist, file ="dev/russulales_mycoportal.rda")

cantharellales.dist <- records_hightax(taxon = "cantharellales", sleep = 2)
save(cantharellales.dist, file ="dev/cantharellales_mycoportal.rda")

agaricales.dist <- records_hightax(taxon = "agaricales", sleep = 2)
save(agaricales.dist, file ="dev/agaricales_mycoportal.rda")

## Test radius
spec.rad <- records(
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

x <- boletales.dist
plot_distmap(x = x, mapdatabase = "world")
plot_recordstreemap(x = x, groupvar = "country", log = FALSE)
plot_datamap(x = x, mapdatabase = "world")
plot_datamap(x = x, mapdatabase = "world",
             area = list(min_long = -10, max_long = 30, min_lat = 14, max_lat = 70))


plot_distmap(x = ord.dist, mapdatabase = "world", panel = FALSE)
plot_recordstreemap(x = ord.dist, log = FALSE)
plot_datamap(x = ord.dist, mapdatabase = "world")

