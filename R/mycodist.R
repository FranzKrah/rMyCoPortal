#' @title Create Objects of Class "mycodist"
#' @description Create objects of class
#'   \code{"\link[=mycodist-class]{mycodist}"} from meta data
#'   and a data.frame derived from \code{\link{records}}.
#' @param nr.records numeric of number of records found
#' @param citation character string with recommended citation
#' @param query list with user-specified query arguments
#' @param records data.frame displaying results from MyCoPortal
#' @include mycodist-class.R
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
