#===============================================================================

# This script imports maple sap production data for sap of red and sugar maple 
# trees at the Proctor Maple Research Center (PMRC). More details on the study 
# can be found in the repository's README.md file. The data is imported from the 
# workbook: "PMRC Red v Sugar Records.xlsx".
#
# Workbook structure:
#   1. "Number of taps"
#      - Annual number of taps by treatment. Each tree received a single tap, 
#        thus this is also the number of trees.
#      - Columns: Number of taps, Year, Treatment, Comments.
#      - Imported into the tibble `n_taps`.
#
#   2. Year-specific sheets ("2022", "2023", ..., "2027", etc.)
#      - Individual sap collection records for each treatment (Red versus Sugar) 
#        and date.
#      - Columns: Date, Treatment, Volume (gal), SC (°Brix),
#                 Vacuum ("Hg), Comments.
#      - All yearly sheets are combined into a single tibble `d`.
#
# Variables:
#   - Volume (gal): Sap volume collected (gallons).
#   - SC (Brix): Sap solubles concentration (°Brix).
#   - Vacuum ("Hg): Collection-system vacuum level (inches Hg).
#
# The import procedure automatically identifies and reads all sheets whose
# names correspond to calendar years, allowing future years (e.g., 2027, 2028)
# to be added without modifying the code. 
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