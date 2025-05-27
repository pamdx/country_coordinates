library(dplyr)
library(tidyr)
library(readr)
library(janitor)

# Loading the missing coordinates

source("missing_coord.R")

# Downloading Google country point data

google_coord <- read_csv("https://raw.githubusercontent.com/google/dspl/master/samples/google/canonical/countries.csv", na = "") %>%
  rename(iso2 = country, lat = latitude, lon = longitude) %>%
  select(iso2, lat, lon) %>%
  mutate(comment = "Coordinates added from https://github.com/google/dspl/blob/master/samples/google/canonical/countries.csv")

# Adding Google's data to NFISS' country list

country_coord <- read_csv("https://raw.githubusercontent.com/openfigis/RefData/refs/heads/gh-pages/country/CL_FI_COUNTRY_M49.csv", na = "") %>%
  clean_names() %>%
  select(un_code, iso2_code, name_en) %>%
  left_join(google_coord, by = c("iso2_code" = "iso2")) %>%
  select(-iso2_code) %>%
  rows_update(missing_coord, by = "un_code") # Fixing existing entries whose coordinates are missing
  

if (any(is.na(country_coord$lat)) | any(is.na(country_coord$lon))) {
 
  warning("The above entries are lacking coordinates")
  
  country_coord %>% 
    filter(is.na(country_coord$lat) | is.na(country_coord$lon))
   
}

write_csv(country_coord, "country_coordinates.csv")