library(data.table)

convert_coords_table <- function(data, long, lat) {
  # Check if the specified columns exist in the data frame
  if (!(long %in% names(data)) | !(lat %in% names(data))) {
    stop("Specified longitude or latitude column not found in the data frame.")
  }

  # Apply dm_to_dd_fn to longitude column
  data$xcoord <- dm_to_dd_fn(data[[long]])

  # Apply dm_to_dd_fn to latitude column
  data$ycoord <- dm_to_dd_fn(data[[lat]])

  return(data)
}
