# The MyCoPortal

The Mycology Collections data Portal (MyCoPortal) is a database of fungal diversity with records mainly from North America. For more - and detailled - information, please visit http://mycoportal.org/portal/index.php.

The rMyCoPortal R package is an interface to the content stored on the MyCoPoral website. It allows to download records from the database readily in R for further analysis. It further provides some basic plotting functions. Below I will show the basic usability and some further possibilites of using the data.

# Install rMyCoPortal
```{r setup, include=TRUE, eval=FALSE}

install.packages("devtools")
devtools::install_github("FranzKrah/rMyCoPortal")

```

## Docker

Before we start using rMyCoPortal, we need to install docker (https://docs.docker.com/install/). Docker performs  virtualization, also known as "containerization". rMyCoPortal interally uses the R package RSelenium to create a Selenium Server from which the MyCoPortal website is addressed. 
Docker needs to run before using the rMyCoPortal.

# Download records for *Amanita muscaria*, the fly agaric


```{r example1, include=TRUE, eval=TRUE, echo=TRUE}
## Load library
library("rMyCoPortal")

## Download records

am.rec <- records(taxon = "Amanita muscaria") # please run again if server doesn't respond immediatelly
am.rec

## The retrieved object stores a distribution table with 6570 records.

head(am.rec@records)
```

## Visualization
We can now use several plotting methods to visualize the data.

```{r plots, include=TRUE, eval=TRUE, echo=TRUE}

x <- am.rec

## plot_distmap can be used to plot interactive and static distribution maps
plot_distmap(x = x, mapdatabase = "world") # the default is interactive
plot_distmap(x = x, mapdatabase = "world", interactive = FALSE) # the default is interactive

## plot_recordstreemap can be used to visualize relative importance of aspects of the data
plot_recordstreemap(x = x, groupvar = "country", log = FALSE) # e.g., the country distribution

## plot_datamap can be used to get a quick overview of which countries are most records rich
plot_datamap(x = x, mapdatabase = "world")

## the same but cropped to Europe
plot_datamap(x = x, mapdatabase = "world",
             area = list(min_long = -10, max_long = 30, min_lat = 30, max_lat = 70))


```


We could now use the data to look at the range of suitable climatic conditions for A. muscaria. Let's use mean annual temperature and mean annual precipitation for now. 

```{r clim, include=TRUE, eval=TRUE, echo=TRUE}
library(sf)
library(raster)
rec <- am.rec@records
rec <- rec[!(is.na(rec$lat) | is.na(rec$lon)), ]

my.sf.point <- st_as_sf(x = rec, 
                        coords = c("lon", "lat"),
                        crs = "+proj=longlat +datum=WGS84")

## crop to USA
area = list(min_long = -130, max_long = -60, min_lat = 25, max_lat = 52)
my.sf.point <- st_crop(my.sf.point, xmin = area$min_long, ymin = area$min_lat, xmax = area$max_long, ymax = area$max_lat)
my.sf.point <- SpatialPointsDataFrame(coords = st_coordinates(my.sf.point), data = as.data.frame(my.sf.point))

## Retrieve WorldClim data
clim <- raster::getData(name = "worldclim", res = "2.5", var = "bio")
clim <- crop(clim, extent(-130, -60, 25, 52))
clim <- stack(clim)

climdat <- extract(clim, my.sf.point)
climdat[,1] <- climdat[,1]/10
dat <- data.frame(as.data.frame(my.sf.point), climdat)

library(ggplot2)
p.mat <- ggplot(dat, aes(x = bio1)) +
  geom_histogram() +
  labs(x ="Mean annual temperature", y = "Count") +
  theme_bw() +
  geom_vline(aes(xintercept = mean(bio1, na.rm = TRUE)), col='red',size=2)

p.map <- ggplot(dat, aes(x = bio12)) +
  geom_histogram() +
  labs(x ="Mean annual precipitation sums", y = "Count") +
  theme_bw() +
  geom_vline(aes(xintercept = mean(bio12, na.rm = TRUE)), col='red',size=2)


library(cowplot )
plot_grid(p.mat, p.map, ncol = 2)

```

