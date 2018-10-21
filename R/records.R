#' @title Create Objects of Class "records"
#' @description Create objects of class
#'   \code{"\link[=records-class]{mycodist}"} from meta data
#'   and a data.frame derived from \code{\link{mycoportal}}.
#'
#' @param nr.records A numeric giving the number of records retrieved
#' @param citation A character string with the recommended citation from the website
#' @param query A list of the user arguments used
#' @param records A data.frame with the query records results
#' @param db A character string specifying the database (currently only MyCoPortal)
#' @include records-class.R
#'
#' @author Franz-Sebastian Krah
#'
#' @importFrom methods new
#' @export

"records" <- function(nr.records, citation, query, records, db){

  new("records",
      nr.records = nr.records,
      citation = citation,
      query = query,
      records = records,
      db = db
  )
}

## setMethod: indexing, extracting scores,

setMethod("show", signature = "records",
          function(object){
            cat("Distribution table with", object@nr.records, "records")
          })
