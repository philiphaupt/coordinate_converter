# FUNCTION TO CONVERT COORDINATES FROM DDM to DD, e.g., 51.26.892 to 51.44820
# Required for byelaws, vessel sightings, survey planning etc.

# Method:

# 1. isolate the degrees (D) - they are correct and carried through
# 2. take the decimal part (DM) (which represents minutes decimal seconds) and divide by 60. 
# 3. Add the D and converted DM from step 2 together.
#---------------------------
# Requirements
# columns to be labbled lat or long
# data in vector format
# Help on the input to supply - the function expects a vector of data, so you need to supply the data as separate column of lat or long, like this for e.g.
# E.g.: conversion_fn_output <- apply( dat_for_conversion[,grep("lat", colnames(dat_for_conversion))| grep("long", colnames(dat_for_conversion))] , 2 , conversion_fn )
# this will apply the function to any column lablled lat or lon
# to unlist your data from the above do this: 
# output_data <- tibble(x = unlist(conversion_fn_output[grep("lon", names(conversion_fn_output))]),
#                       y = unlist(conversion_fn_output[grep("lat", names(conversion_fn_output))]))
#libraries
require(tidyverse)

conversion_fn <-  function(dat) {
  # feed in data
  
  stringr::str_split_fixed(string = as.character(dat),
                           #make sure that the data is character format
                           pattern =  "[[:punct:]|[:alpha:]]",
                           # split the data wafter each punctuation mark or alphabet letter
                           n = 2) %>% #into 3 column (d,m,ds)
    as_tibble() %>% #convert to tibble
    dplyr::rename(ddm_d = V1,
                  ddm_ms = V2) %>% 
    mutate(
      dd_ms = as.numeric(ddm_ms) / 60, # converts 60-mitues to decimal minutes: out of 100
      dd = as.numeric(ddm_d)+dd_ms
      #dd_ms_prep = sub("[[:punct:]]","",dd_ms),
      #dd = as.numeric(paste0(ddm_d, ".", dd_ms_prep))
                         ) %>% select(dd) # drop all the workings and original data keeping only the converted decimal degrees.
  
}

##WRONG
# Step 2) Load the function to convert the coordinates
# function: converts a column of latitude or longtiude degrees - minutes-decimal sceconeds into decimal degrees
# conversion_fn <-  function(dat) { # feed in data
#   
#   stringr::str_split_fixed(string = as.character(dat), #make sure that the data is character format
#                                      pattern =  "[[:punct:]|[:alpha:]]", # split the data wafter each punctuation mark or alphabet letter
#                                      n = 3) %>% #into 3 column (d,m,ds)
#   as_tibble() %>% #convert to tibble
#   dplyr::rename(d = V1,#supply appropriate names (d = degrees)
#                 m60 = V2, #(minutes out of 60)
#                 ds = V3) %>% #decimal second 
#   mutate(dm = as.numeric(m60)*100/60, # converts 60-mitues to decimal minutes: out of 100
#          dds = as.numeric(paste0("0.",ds)),#stick a 0. infron t of the decimal seconds so that we can add it to the new decimal minutes
#          dd_ms = dm+dds) %>% #add the latter two together
#   mutate(dd_m = stringr::str_split_fixed(string = as.character(dd_ms), # split them again so taht we can paste them neatly into the correct decimal degree format i.e. we need to loose some punctuation as it only expects a point after the degrees
#                                              pattern =  "[[:punct:]|[:alpha:]]",
#                                              n = 2)[,1],
#          dd_s = stringr::str_split_fixed(string = as.character(dd_ms),
#                                              pattern =  "[[:punct:]|[:alpha:]]",
#                                              n = 2)[,2],
#          dd = as.numeric(paste0(d, ".", dd_m, dd_s))
#   ) %>% select(dd) # drop all the workings and original data keeping only the converted decimal degrees.
# 
# }
