#' Conflicts between the sigverse and other packages
#'
#' This function lists all the conflicts between packages in the sigverse
#' and other packages that you have loaded.
#'
#'
#' @export
#' @param only Set this to a character vector to restrict to conflicts only
#'   with these packages.
#' @examples
#' sigverse_conflicts()
sigverse_conflicts <- function(only = NULL) {
  envs <- grep("^package:", search(), value = TRUE)
  names(envs) <- envs

  if (!is.null(only)) {
    only <- union(only, core)
    envs <- envs[names(envs) %in% paste0("package:", only)]
  }

  objs <- invert(lapply(envs, ls_env))

  conflicts <- objs[vapply(objs, function(.x) { length(.x) > 1 }, logical(1))]

  tidy_names <- paste0("package:", sigverse_packages())
  conflicts <- conflicts[vapply(conflicts, function(.x) { any(.x %in% tidy_names) }, logical(1))]

  conflict_funs <- Map(confirm_conflict, conflicts, names(conflicts))
  conflict_funs <- conflict_funs[vapply(conflict_funs, function(.f){ is.function(.f) && length(.f()) > 0}, FUN.VALUE = logical(1))]

  structure(conflict_funs, class = "sigverse_conflicts")
}

sigverse_conflict_message <- function(x) {
  header <- cli::rule(
    left = cli::style_bold("Conflicts"),
    right = "sigverse_conflicts()"
  )

  # Remove "package:" prefix from package names
  pkgs <- lapply(x, function(v) gsub("^package:", "", v))
  # Get all conflicting packages except the first one
  others <- lapply(pkgs, function(v) v[-1])

  # Create a character vector of other calls
  other_calls <- mapply(function(pkg_list, fun_name) {
    paste0(cli::col_blue(pkg_list), "::", fun_name, "()", collapse = ", ")
  }, others, names(others), USE.NAMES = FALSE)

  # Get the package that masks others
  winner <- sapply(pkgs, `[`, 1)
  funs <- format(paste0(cli::col_blue(winner), "::", cli::col_green(paste0(names(x), "()"))))

  if (length(winner) == 0) {
    return(NULL)
  }

  bullets <- paste0(
    cli::col_red(cli::symbol$cross), " ", funs, " masks ", other_calls,
    collapse = "\n"
  )

  conflicted <- paste0(
    cli::col_cyan(cli::symbol$info), " ",
    cli::format_inline("Use the {.href [conflicted package](http://conflicted.r-lib.org/)} to force all conflicts to become errors")
  )

  paste0(
    header, "\n",
    bullets, "\n",
    conflicted
  )
}


#' @export
print.sigverse_conflicts <- function(x, ..., startup = FALSE) {
  cli::cat_line(sigverse_conflict_message(x))
  invisible(x)
}


confirm_conflict <- function(packages, name) {
  # Get the objects named 'name' from each package
  objs <- lapply(packages, function(p) get(name, pos = p))

  # Keep only the objects that are functions
  is_func <- sapply(objs, is.function)
  objs <- objs[is_func]
  packages <- packages[is_func]

  if (length(objs) <= 1)
    return()

  # Remove identical functions
  unique_indices <- !duplicated(objs)
  objs <- objs[unique_indices]
  packages <- packages[unique_indices]

  if (length(objs) == 1)
    return()

  packages
}


ls_env <- function(env) {
  x <- ls(pos = env)


  x
}
