# GBIF Spatial Bias Analysis for Pakistan
# Author: Aamna Naveed
# Date: August 2026

# Load required packages
library(readr)
library(dplyr)
library(ggplot2)

# Set working directory (adjust path as needed)
setwd("C:/Users/Laptop Land/Desktop")

# Read GBIF data
data <- read_csv("gbif_pakistan.csv.csv")

# Clean data: select relevant columns, remove rows with missing province
data_clean <- data %>%
  select(stateProvince, family, species, eventDate, decimalLatitude, decimalLongitude) %>%
  filter(!is.na(stateProvince))

# Count records by province (top 10)
province_counts <- data_clean %>%
  count(stateProvince) %>%
  arrange(desc(n)) %>%
  slice_head(n = 10)

# Count records by plant family (top 10)
family_counts <- data_clean %>%
  count(family) %>%
  arrange(desc(n)) %>%
  slice_head(n = 10)

# Save cleaned data
write_csv(data_clean, "gbif_pakistan_cleaned.csv")

# Chart 1: Records by Province
chart1 <- ggplot(province_counts, aes(x = reorder(stateProvince, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Plant Biodiversity Records by Province in Pakistan",
    subtitle = "Top 10 Provinces by Record Count | Data from GBIF",
    x = "Province / Region",
    y = "Number of Records"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 11),
    plot.title = element_text(size = 14, face = "bold")
  )

ggsave("chart_province_records.png", plot = chart1, width = 10, height = 6, dpi = 300)

# Chart 2: Top 10 Plant Families
chart2 <- ggplot(family_counts, aes(x = reorder(family, n), y = n)) +
  geom_col(fill = "forestgreen") +
  coord_flip() +
  labs(
    title = "Top 10 Plant Families in Pakistan GBIF Records",
    subtitle = "Data from GBIF",
    x = "Plant Family",
    y = "Number of Records"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold")
  )

ggsave("chart_top_families.png", plot = chart2, width = 10, height = 6, dpi = 300)

# Print summary to console
print("Analysis complete. Check Desktop for output files.")