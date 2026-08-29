# Week 3: SDM Data Preparation
# Species: Prosopis cineraria (Khejri / Tree of Life)
# Author: Aamna Naveed

library(readr)
library(dplyr)
library(ggplot2)
library(raster)
library(geodata)

setwd("C:/Users/Laptop Land/Desktop")

# Download global Khejri data
species_key <- rgbif::name_backbone(name = "Prosopis cineraria")$speciesKey
occ_global <- rgbif::occ_search(taxonKey = species_key, hasCoordinate = TRUE, 
                                hasGeospatialIssue = FALSE, limit = 2000)
khejri_global <- occ_global$data %>% 
  dplyr::select(species, decimalLatitude, decimalLongitude, eventDate, country, stateProvince, basisOfRecord) %>%
  filter(!is.na(decimalLatitude), !is.na(decimalLongitude))
write_csv(khejri_global, "prosopis_cineraria_global.csv")

# Download WorldClim
bio_clim <- worldclim_global(var = "bio", res = 10, path = tempdir())
extent_region <- extent(55, 85, 20, 40)
bio_clim_crop <- crop(bio_clim, extent_region)
writeRaster(bio_clim_crop, "worldclim_pakistan_region.tif", overwrite = TRUE)

# Extract climate at presence points
khejri <- read_csv("prosopis_cineraria_global.csv")
bio_clim <- stack("worldclim_pakistan_region.tif")
khejri_coords <- khejri %>% dplyr::select(decimalLongitude, decimalLatitude)
khejri_coords <- as.data.frame(khejri_coords)
coordinates(khejri_coords) <- ~decimalLongitude + decimalLatitude
khejri_climate <- extract(bio_clim, khejri_coords)
khejri_presence <- cbind(as.data.frame(khejri), as.data.frame(khejri_climate))
khejri_presence$presence <- 1
write_csv(khejri_presence, "khejri_presence_with_climate.csv")

# Generate background points
n_bg <- nrow(khejri) * 10
set.seed(42)
bg_lon <- runif(n_bg, min = 60, max = 77)
bg_lat <- runif(n_bg, min = 24, max = 37)
bg_points <- data.frame(decimalLongitude = bg_lon, decimalLatitude = bg_lat)
coordinates(bg_points) <- ~decimalLongitude + decimalLatitude
bg_climate <- extract(bio_clim, bg_points)
bg_climate_df <- as.data.frame(bg_climate)
valid_rows <- complete.cases(bg_climate_df)
background <- data.frame(decimalLongitude = bg_points@coords[valid_rows, 1],
                         decimalLatitude = bg_points@coords[valid_rows, 2],
                         bg_climate_df[valid_rows, ])
background$presence <- 0
write_csv(background, "khejri_background_with_climate.csv")

print("Week 3 complete!")