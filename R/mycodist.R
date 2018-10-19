#' @title Create Objects of Class "mycodist"
#' @description Create objects of class
#'   \code{"\link[=mycodist-class]{mycodist}"} from meta data
#'   and a data.frame derived from \code{\link{records}}.
#'
#' @param nr.records A numeric giving the number of records retrieved
#' @param citation A character string with the recommended citation from the website
#' @param query A list of the user arguments used
#' @param records A data.frame with the query records results
#' @include mycodist-class.R
#'
#' @author Franz-Sebastian Krah
#'
#' @importFrom methods new
#' @export

"mycodist" <- function(nr.records, citation, query, records){

  new("mycodist",
      nr.records = nr.records,
      citation = citation,
      query = query,
      records = records
  )
}

## setMethod: indexing, extracting scores,

setMethod("show", signature = "mycodist",
          function(object){
            cat("Fungal distribution table with", object@nr.records, "records")
          })
