% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mycoportal_hightax.R
\name{mycoportal_hightax}
\alias{mycoportal_hightax}
\title{Retrieve higher taxon records from the MyCoPortal}
\usage{
mycoportal_hightax(taxon = "Polyporales", verbose = TRUE,
  screenshot = TRUE, port = 4445L, browserName = "chrome",
  remoteServerAddr = "localhost", wait = 2)
}
\arguments{
\item{taxon}{character string specifying the taxon name (here usually higher taxon, e.g., order level)}

\item{verbose}{logical}

\item{screenshot}{logical, whether screenshot of results should be displayed in Viewer}

\item{port}{default is 4445L}

\item{browserName}{character string specifying the browser to use, recommended: "chrome"}

\item{remoteServerAddr}{default is "localhost"}

\item{wait}{numeric specifying the seconds to wait for website to load, recommended 2 for good internet connections, higher otherwise.}
}
\value{
x an object of class "\code{records}" with the following components:
\item{nr.records}{A numeric giving the number of records retrieved}
\item{citation}{A character string with the recommended citation from the website}
\item{query}{A list of the user arguments used}
\item{records}{A data.frame with the query records results}
\item{db}{A character string specifying the database (currently only MyCoPortal)}
}
\description{
Retrieve higher taxon records from the MyCoPortal
}
\details{
Interface to the web database MyCoPortal for higher taxonomic queries, e.g., order level. Here only full query results can be retrieved. If you want to make more specific queries please try \code{\link{mycoportal}}.
}
\examples{
\dontrun{
## Query Amanitacae and plot on world map or USA map
poly.dist <- mycoportal_hightax(taxon = "polyporales", taxon_type = 2)
recordsmap(poly.dist, mapdatabase = "world", legend = FALSE)
recordsmap(poly.dist, mapdatabase = "state", legend = FALSE)
}
}
\references{
see \code{\link{mycoportal}}
}
\author{
Franz-Sebastian Krah
}
