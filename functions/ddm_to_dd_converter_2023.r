dm_to_dd_fn <- function(dat) {
  # Check if dat is character, and convert if necessary
  dat <- as.character(dat)

  # Use str_extract to extract degrees and minutes
  degrees <- stringr::str_extract(dat, "\\d+")
  minutes <- stringr::str_extract(dat, "\\d+\\.\\d+")

  # Check if degrees and minutes are not NULL
  if (is.null(degrees) | is.null(minutes)) {
    stop("Invalid input format. Please provide coordinates in the format 'ddmm.ss'")
  }

  # Convert degrees and minutes to numeric
  degrees <- as.numeric(degrees)
  minutes <- as.numeric(minutes)

  # Convert degrees and minutes to decimal degrees
  decimal_degrees <- degrees + minutes / 60

  return(decimal_degrees)
}

# Example usage:
# dat <- "51d24.326"
# result <- dm_to_dd_fn(dat)
# cat("Example", dat, "becomes: ", result, "\n")
