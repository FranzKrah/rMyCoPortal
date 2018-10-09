#' @title An S4 Class to represent query result from the function \link{records}
#' @description \code{mycodist} holds a records table together with the query meta data and recommended citation
#' @slot nr.records A nuneric of the number of records found
#' @slot query A list giving the user arguments used in the function
#' @slot citation A character string with the recommended citation from the website
#' @slot records A data.frame with the query records results
#' @seealso \code{"\link[=mycodist-class]{mycodist}"}

setClass("mycodist",
         representation = list(
           nr.records = "numeric",
           citation = "character",
           query = "list",
           records = "data.frame")
)
