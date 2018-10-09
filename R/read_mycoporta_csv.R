#' Read a downloaded folder
#' @param path character string, specifying the path to the local CSV file after manual download
#' @export
read_mycoportal_csv <- function(path){

  tabs <- read.csv(paste0(path, "/occurrences.csv"), sep=";", header = TRUE)

  nr.rec <- nr.nrow(occ)

  cit = "Please check on website!"
  query = "Data was downloaded manually."

  mycodist(nr.records = nr.rec, citation = cit, query = query, records = tabs)

}
