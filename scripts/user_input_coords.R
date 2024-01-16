# User to provide file
library(tidyverse)

print("Select your data file. At the moment it expects csv format. Options to read in Excel or otehr formats can seasily be added, by adjustingthe code. Plewase ensure that you have a column that contains a heading like longitude and latitute")

# Examples and past uses:
#input_data <- file.choose("C:/") # generic - user selects a file
#input_data <- read_csv("C:/Users/philip.haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/GIS/gis_data/FSA shellfish classification zones/Oyster__fishing_Area_nominated/Ilse_of_Sheppey_classification_put_fwd_Jackie_Serioka.txt")
#input_data <- read_csv("C:/Users/philip.haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/GIS/gis_data/SUSTAINABLE FISHERIES/Prospecting/Jason_Gilson_Mactra_stultorum_rayed_trough_shell_20231212.csv")
# Most recent:
input_data <- read_csv("C:/Users/philip.haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/GIS/gis_data/SUSTAINABLE FISHERIES/Prospecting/Razor_clams_Ensis_sp_classification zone_coordinates_16012024.csv") #read_csv("./data/locations.csv")


input_data <- select(input_data, 
                     long = longitude, # you may need to alter teh "longitude" and "latitude" according to the names in your csv file.
                     lat = latitude)#
