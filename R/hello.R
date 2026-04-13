#' Return a starter greeting
#'
#' A simple example function for onboarding.
#'
#' @param name Character scalar. Name to greet.
#'
#' @return A character scalar.
#' @export
hello_pas <- function(name = "world") {
  stopifnot(is.character(name), length(name) == 1)
  sprintf("Hello, %s!", name)
}
