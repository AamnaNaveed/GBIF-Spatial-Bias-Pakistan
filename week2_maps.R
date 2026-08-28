# Week 2: Spatial Visualization
# GBIF Plant Biodiversity Data for Pakistan
# Author: Aamna Naveed
# Date: August 2026

library(readr)
library(dplyr)
library(ggplot2)
library(hexbin)
library(sf)

setwd("C:/Users/Laptop Land/Desktop")

# Download Pakistan boundary
download.file(
  "https://raw.githubusercontent.com/johan/world.geo.json/master/countries/PAK.geo.json",
  destfile = "pakistan_boundary.geojson",
  mode = "wb"
)

# Read and clean GBIF data
data <- read_csv("gbif_pakistan.csv.csv")
data_clean <- data %>%
  filter(
    !is.na(decimalLatitude), !is.na(decimalLongitude),
    decimalLatitude >= 24, decimalLatitude <= 37,
    decimalLongitude >= 60, decimalLongitude <= 77
  )

# Map 1: Occurrence points
map1 <- ggplot(data_clean, aes(x = decimalLongitude, y = decimalLatitude)) +
  geom_point(alpha = 0.15, size = 0.5, color = "forestgreen") +
  coord_fixed(ratio = 1, xlim = c(60, 77), ylim = c(24, 37)) +
  labs(title = "Plant Biodiversity Occurrence Points in Pakistan",
       subtitle = paste(format(nrow(data_clean), big.mark = ","), "GBIF records"),
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(plot.title = element_text(size = 16, face = "bold"))
ggsave("map_1_occurrence_points.png", plot = map1, width = 10, height = 10, dpi = 300)

# Map 2: Hexbin density
map2 <- ggplot(data_clean, aes(x = decimalLongitude, y = decimalLatitude)) +
  geom_hex(bins = 30) +
  scale_fill_gradient(low = "lightyellow", high = "darkred", name = "Record\nCount") +
  coord_fixed(ratio = 1, xlim = c(60, 77), ylim = c(24, 37)) +
  labs(title = "Density of Plant Biodiversity Records in Pakistan",
       subtitle = "Hexbin heatmap | Bad coordinates removed",
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(plot.title = element_text(size = 16, face = "bold"))
ggsave("map_2_hexbin_density.png", plot = map2, width = 10, height = 10, dpi = 300)

# Map 3: Points on Pakistan boundary
pakistan <- st_read("pakistan_boundary.geojson", quiet = TRUE)
map3 <- ggplot() +
  geom_sf(data = pakistan, fill = "lightgray", color = "black", size = 0.4) +
  geom_point(data = data_clean, aes(x = decimalLongitude, y = decimalLatitude),
             alpha = 0.12, size = 0.4, color = "darkgreen") +
  coord_sf(xlim = c(60, 77), ylim = c(24, 37)) +
  labs(title = "GBIF Plant Records Overlaid on Pakistan",
       subtitle = paste(format(nrow(data_clean), big.mark = ","), "occurrence points"),
       x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(plot.title = element_text(size = 16, face = "bold"))
ggsave("map_3_pakistan_base.png", plot = map3, width = 10, height = 10, dpi = 300)

print("All 3 maps saved to Desktop!")