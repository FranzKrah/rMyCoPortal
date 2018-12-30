## ----setup, include=TRUE, eval=FALSE-------------------------------------
#  
#  install.packages("devtools")
#  devtools::install_github("FranzKrah/rMyCoPortal")
#  

## ----example1, include=TRUE, eval=FALSE, echo=TRUE-----------------------
#  ## Load library
#  library("rMyCoPortal")
#  
#  ## Download records
#  
#  am.rec <- mycoportal(taxon = "Amanita muscaria")
#  am.rec
#  
#  head(am.rec@records)

## ----plots, include=TRUE, eval=FALSE, echo=TRUE--------------------------
#  
#  x <- am.rec
#  
#  ## plot_recordstreemap can be used to visualize relative importance of aspects of the data
#  plot_recordstreemap(x = x, groupvar = "country", log = FALSE) # e.g., the country distribution
#  
#  ## plot_distmap can be used to plot interactive and static distribution maps
#  p1 <- plot_distmap(x = x, mapdatabase = "world", interactive = FALSE, plot = FALSE) # the default is interactive
#  
#  # same for states
#  p2 <- plot_distmap(x = x, mapdatabase = "state", interactive = FALSE, plot = FALSE)
#  
#  cowplot::plot_grid(p1, p2, ncol = 1, align = T)
#  
#  ## plot_datamap can be used to plot heatmaps for either records or species richness (index = "rich")
#  p3 <- plot_datamap(x = x, mapdatabase = "world", index = "rec", plot = FALSE)
#  
#  ## the same but cropped to Europe
#  p4 <- plot_datamap(x = x, mapdatabase = "state", index = "rec", plot = FALSE)
#  
#  cowplot::plot_grid(p3, p4, ncol = 1, align = TRUE)
#  
#  ## And we can look up details for specific specimens
#  library(magick)
#  det <- details(x@records$Symbiota.ID[1])
#  length(det$urls)
#  par(mfrow = c(1,2), mar = c(0,0,0,0))
#  plot(image_read(det$urls[1]))
#  plot(image_read(det$urls[3]))
#  

