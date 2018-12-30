# The MyCoPortal

The Mycology Collections data Portal (MyCoPortal) is a database of fungal diversity with records mainly from North America. For more - and detailed - information, please visit http://mycoportal.org/portal/index.php.

The rMyCoPortal R package is an interface to the content stored on the MyCoPoral website. It allows to download records from the database readily in R for further analysis. It further provides some basic plotting functions. Below I will show the basic usability and some further possibilities of using the data.


## Requirements
Under the new MacOS Mojave there have been problems with the sf and raster package. The introduction vignette works fine under Sierra, Mojave and Windows10. However, the vignette *application example* might create errors under Mojave.

R version 3.5.1 (2018-07-02)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS High Sierra 10.13.6


## Install rMyCoPortal
```{r setup, include=TRUE, eval=FALSE}

install.packages("devtools")
devtools::install_github("FranzKrah/rMyCoPortal")

```

### Docker

Before you start using rMyCoPortal, you need to install docker (https://docs.docker.com/install/). Docker performs  virtualization, also known as "containerization". rMyCoPortal internally uses the R package RSelenium to create a Selenium Server from which the MyCoPortal website is addressed. 
Docker needs to run before using the rMyCoPortal.

## How to use rMyCoPortal
[Vignette 1: Introduction](https://github.com/FranzKrah/rMyCoPortal/blob/master/vignettes/introduction.html)

[Vignette 2: Example for Species Distribution modeling](https://github.com/FranzKrah/rMyCoPortal/blob/master/vignettes/application_sdm.html)

## Meta

Please note that this project is released with a Contributor [Code of Conduct](https://github.com/FranzKrah/rMyCoPortal/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

Please [report](https://github.com/FranzKrah/rMyCoPortal/issues) any issues or bugs.
 
