#===============================================================================
# Scrip to wrangle production data for sap of red and sugar maple trees at the 
# Proctor Maple Research Center. More details on the study can be found in the 
# README.md
#-------------------------------------------------------------------------------

library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

# File path -----
f <- "/Users/trademac/Library/CloudStorage/OneDrive-UniversityofVermont/PMRC/Data/production/PMRC Red v Sugar Sap Records.xlsx"

# ------------------------------------------------------------------------------
# Read number of taps 
# ------------------------------------------------------------------------------
n_taps <- read_excel(
  f,
  sheet = "Number of taps",
  na = "NA",
  col_types = c(
    "numeric",  # Number of taps
    "numeric",  # Year
    "text",     # Treatment
    "text"      # Comments
  )
) %>%
  rename(
    n_taps = `Number of taps`,
    yr = Year,
    t = Treatment,
    comments = Comments
  )

# ------------------------------------------------------------------------------
# Read all yearly production sheets
# ------------------------------------------------------------------------------

# Identify sheets whose names are 4-digit years ----
year_sheets <- excel_sheets(f) %>%
  keep(~ str_detect(.x, "^20\\d{2}$"))

# Read and combine all production data ----
d <- map_dfr(year_sheets, function(sheet_name) {
  
  read_excel(
    f,
    sheet = sheet_name,
    na = "NA",
    col_types = c(
      "date",    # Date
      "text",    # Treatment
      "numeric", # Volume (gal)
      "numeric", # SC (Brix)
      "numeric", # Vacuum ("Hg)
      "text"     # Comments
    )
  ) %>%
    mutate(year = as.integer(sheet_name))
}) %>%
  rename(
    date = Date,
    t = Treatment,
    vol = `Volume (gal)`,
    ssc = `SC (°Brix)`,
    vacuum = `Vaccum ("Hg)`,
    comments = Comments
  ) %>%
  relocate(year, .before = date)


#===============================================================================