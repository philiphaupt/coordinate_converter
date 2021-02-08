# Aim: Create a polygon from DMdS coordinates: 1) convert wgs84 DMdS coordinates to wgs84 DD decimal degrees, 2) save the output to a geopackage
# Author: Philip Haupt
# Date: 2021-02-08

# Method: Read in coodinates, split minutes decimal seconds into two columns, then divide the minutes by sixty and multiply by 100. Then add the decimal seconds to the output and append this to the decimal degrees. Write output to geopackage. 

# Disclaimer: It only works for this (DMdS - DD, WGS84) kind of conversion! The input data has to be degrees minutes(60) and decimal seconds.
# Expected outputs: a csv file in your working directory called output_dat.csv and a geopackage called output_polygon.gpkg, layer = polygon_from_converted_coordinates. It will be WGS84 -unproject: see comments where you can change the projection output. Make sure you have the neccessary R packages installed or this won't work

# Requirements

# Installed R version 4 or higher.
# Libraries (you have to have these packages installed, and then call them like this:) e.g. install.packages("sf")
library(tidyverse)
library(sf)
library(tmap)


# Step 1)  Read in the data
# Input data requirements:
# it has to ahve a column starting with lat* defining latitude and long* defining longitude
# the FORMAT is important. your data in each column needs to have a pnctuation mark or letter between numbers to allow the converson to work correctly, . 
# e.g. 51.25.772 or 51d25m772 # i wrote and tested the script using the latter example, and it worked.
# the order of lat and long does not matter! But it has to be called lat* or long starting with caps at this point - may improve this in due course.
# the data must finish with a number, not  a denomiator! e.g. do not put an s at the end of the coordiantes, for example, it will not work
# read in data, for example
dat_for_conversion <- read_csv("./EastMargateSands_test.csv")
dat_for_conversion %>% glimpse()

# or make it like this

dat_for_conversion <- tibble(
  lat = c("51d26.892", "51.26.892", "51.25.772", "51.25.28"),
  long = c("1d21.447", "1.26.946", "1.26.946", "1.21.447")
)


# Step 2) Load the function to convert the coordinates
# function: converts a column of latitude or longtiude degrees - minutes-decimal sceconeds into decimal degrees
conversion_fn <-  function(dat) { # feed in data
  
  stringr::str_split_fixed(string = as.character(dat), #make sure that the data is character format
                                     pattern =  "[[:punct:]|[:alpha:]]", # split the data wafter each punctuation mark or alphabet letter
                                     n = 3) %>% #into 3 column (d,m,ds)
  as_tibble() %>% #convert to tibble
  dplyr::rename(d = V1,#supply appropriate names (d = degrees)
                m60 = V2, #(minutes out of 60)
                ds = V3) %>% #decimal second 
  mutate(dm = as.numeric(m60)*100/60, # converts 60-mitues to decimal minutes: out of 100
         dds = as.numeric(paste0("0.",ds)),#stick a 0. infron t of the decimal seconds so that we can add it to the new decimal minutes
         dd_ms = dm+dds) %>% #add the latter two together
  mutate(dd_m = stringr::str_split_fixed(string = as.character(dd_ms), # split them again so taht we can paste them neatly into the correct decimal degree format i.e. we need to loose some punctuation as it only expects a point after the degrees
                                             pattern =  "[[:punct:]|[:alpha:]]",
                                             n = 2)[,1],
         dd_s = stringr::str_split_fixed(string = as.character(dd_ms),
                                             pattern =  "[[:punct:]|[:alpha:]]",
                                             n = 2)[,2],
         dd = as.numeric(paste0(d, ".", dd_m, dd_s))
  ) %>% select(dd) # drop all the workings and original data keeping only the converted decimal degrees.

}


# Step 3) Run the function for the data
# 3.1) convert names to lower caps
names(dat_for_conversion) <- tolower(names(dat_for_conversion))

# 3.2) run for column lat and lon
# Get the names for the columns so that we can add the correct x or y label to the output columns.
conversion_fn_output <- apply( dat_for_conversion[,grep("lat", colnames(dat_for_conversion))| grep("long", colnames(dat_for_conversion))] , 2 , conversion_fn )

# Step 4) Create outputs
# 4.1 R object: create  a new object as a tibble (not nested list)
output_data <- tibble(x = unlist(conversion_fn_output[grep("lon", names(conversion_fn_output))]),
                      y = unlist(conversion_fn_output[grep("lat", names(conversion_fn_output))]))


# csv file of point coordinates
write_csv(output_data, "./output_dat.csv")

# 4.2) R spatial object (sf) 
output_data$id_pt <- c(1,2,3,4) # id purely used ot check at this point
output_data %>% dplyr::arrange(id_pt) # see above

output_pts_sf <- st_as_sf(output_data, coords = c("x", "y"), crs = 4326) # Creates r spatial object (sf). Note, can change crs to 32631 to get utm31 output
output_pts_sf$grp <- 1 # Note, Can use this piece to change it to the name or idnetifier of different polygons, so that you can process multiple polygons a the same time.


# 4.3) convert points to polygon
output_poly_sf <- output_pts_sf %>%
  dplyr::select(grp) %>% 
  dplyr::group_by(grp) %>% # this can be used to specify multiple polygons
  dplyr::summarize() %>% # essential step required to convert points to polygons
  st_cast("POLYGON") %>% # here it is cast to polygon
  st_convex_hull() # this fixes the sequence in which the points are joined to make the polygon. It seems a bizarrre way of doing it when you can specify the sequence of the points...but it works.


#test output by plotting on a map # remove when no longer required.
tmap::tm_shape(output_poly_sf)+
  tmap::tm_polygons() +
  tmap::tm_markers(text = "grp", size = 2, col = "green") +
  tmap::tm_grid() +
  tmap::tm_shape(output_pts_sf)+
  tmap::tm_markers(text = "id_pt") 


# 
sf::write_sf(output_poly_sf, dsn = "./output_polygon.gpkg", layer = "polygon_from_converted_coordinates")
