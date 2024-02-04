.onAttach <- function(...) {
  attached <- sigverse_attach()
  if (!is_loading_for_tests()) {
    inform_startup(sigverse_attach_message(attached))
  }

  if (!is_attached("conflicted") && !is_loading_for_tests()) {
    conflicts <- sigverse_conflicts()
    inform_startup(sigverse_conflict_message(conflicts))
  }
}

is_attached <- function(x) {
  paste0("package:", x) %in% search()
}

is_loading_for_tests <- function() {
  !interactive() && identical(Sys.getenv("DEVTOOLS_LOAD"), "tidyverse")
}
