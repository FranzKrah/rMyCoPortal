#' Read a folder downloaded from MyCoPortal
#' @param dir character string, specifying the path to the local CSV file after manual download
#'
#' @return x an object of class "\code{records}" with the following components:
#' \item{nr.records}{A numeric giving the number of records retrieved}
#' \item{citation}{A character string with the recommended citation from the website}
#' \item{query}{A list of the user arguments used}
#' \item{records}{A data.frame with the query records results}
#'
#' @importFrom utils read.csv
#'
#' @author Franz-Sebastian Krah
#'
#' @export

read_mycoportal_csv <- function(dir) {

  tabs <- read.csv(paste0(dir, "/occurrences.csv"),
                   sep = ";",
                   header = TRUE)

  nr.rec <- nrow(tabs)

  cit = "Please check http://mycoportal.org/portal/misc/usagepolicy.php"
  query = list("Data was downloaded manually.")

  records(
    nr.records = nr.rec,
    citation = cit,
    query = query,
    records = tabs,
    db = "MyCoPortal"
  )
}
