# ---- Loading libraries ----
library("shiny")
library("shinydashboard")
library("tidyverse")
library("leaflet")
library("plotly")
library("DT")
library("fs")
library("wbstats")
library(reticulate)

source_python("backend.py")
source("utils.R", local = T)

DATA_ZIP_PATH <- "data/argcovidapi.zip"

downloadGithubData <- function() {
  download.file(
    url      = "https://github.com/mariano22/argcovidapi/archive/master.zip",
    destfile = DATA_ZIP_PATH
  )

  unzip(
    zipfile   = DATA_ZIP_PATH,
    files     = c("argcovidapi-master/csvs/Argentina_Provinces.csv"),
    exdir     = "data",
    junkpaths = T
  )
}


updateData <- function() {
    # Call backend update function
    backend_update_data()
}

# Update with start of app
backend_update_data()
# Get last update data day and time
changed_date <- backend_global_status_getter('timestamp')
# Get data from backend
data_evolution <- backend_global_status_getter('soon_deprecated') %>%
                  mutate(date = as.Date(date)) 
# Get latest day
current_date <- as.Date(max(data_evolution$date), format = "%d/%m/%y")

data_atDate <- function(inputDate) {
  x <- data_evolution[which(data_evolution$date == inputDate),] %>%
       distinct() %>%
       pivot_wider(id_cols = c("Province/State", "Country/Region", "date", "Lat", "Long", "population"), names_from = var, values_from = value) %>%
       filter(confirmed > 0 |
              recovered > 0 |
              deceased > 0 |
              active > 0);
  x

}

data_latest <- data_atDate(max(data_evolution$date))

top5_countries <- data_evolution %>%
  filter(var == "active", date == current_date) %>%
  group_by(`Country/Region`) %>%
  summarise(value = sum(value, na.rm = T)) %>%
  arrange(desc(value)) %>%
  top_n(5) %>%
  select(`Country/Region`) %>%
  pull()
