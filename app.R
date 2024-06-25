library(shiny)
library(bslib)
library(DT)
library(httr)
library(jsonlite)
library(data.table)
library(mongolite)
library(shinycssloaders)
library(RMySQL)
library(stringr)
library(shinyjs)

# ADDED -------------------------------------------------------------------
# Add resource path for Quarto HTML file
addResourcePath("my_resource", "reports")
# ADDED -------------------------------------------------------------------

# Učitavanje zasebnih skripti
source("functions.R")
source("mod_zemljisne_knjige.R")
source("mod_registar_plovila.R")
source("mod_forensis_dokument.R")
source("mod_zemljisne_knjige_RS.R")
source("mod_zemljisne_knjige_F.R")
source("mod_pravne_osobe.R")

ui <- fluidPage(
  theme = bs_theme(
    bootswatch = "cosmo",
    primary = "#007bff",
    secondary = "#6c757d",
    success = "#28a745",
    info = "#17a2b8",
    warning = "#ffc107",
    danger = "#dc3545",
    light = "#f8f9fa",
    dark = "#343a40"
  ),
  navbarPage(
    title = "Forensis",
    tabPanel(
      title = "Zemljišne knjige RH",
      MUI_zemljisne_knjige("zemljisne_knjige")
    ),
    tabPanel(
      title = "Zemljišne knjige RS",
      MUI_zemljisne_knjige_RS("zemljisne_knjige_RS")
    ),
    tabPanel(
      title = "Zemljišne knjige Federacija",
      MUI_zemljisne_knjige_F("zemljisne_knjige_F")
    ),
    tabPanel(
      title = "Registar plovila RH",
      MUI_registar_plovila("registar_plovila")
    ),
    tabPanel(
      title = "Forensis dokument",
      MUI_forensis_dokument("forensis_dokument")
    ),
    tabPanel(
      title = "Pravne osobe",
      MUI_pravne_osobe("pravne_osobe")
    )
  )
)

server <- function(input, output, session) {
  callModule(MS_zemljisne_knjige, "zemljisne_knjige")
  callModule(MS_zemljisne_knjige_RS, "zemljisne_knjige_RS")
  callModule(MS_zemljisne_knjige_F, "zemljisne_knjige_F")
  callModule(MS_registar_plovila, "registar_plovila")
  callModule(MS_forensis_dokument, "forensis_dokument")
  callModule(MS_pravne_osobe, "pravne_osobe")
}

# Pokretanje aplikacije
shinyApp(ui, server)
