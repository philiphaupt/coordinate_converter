# Main script

# call functions to convert coordinates
source("./scripts/load_converter_functions.R")

# user to supply file with coordinates
file.edit("./scripts/user_input_coords.R") # Here any user can amend the data read in. 

# convert coordinates
source("./scripts/run_conversion.R")

# write and output
file.edit("./write_csv_output.R")
