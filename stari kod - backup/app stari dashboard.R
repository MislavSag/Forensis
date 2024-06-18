#-------------------------------------------------------------------------------
#-----------------------------------# PAKETI #----------------------------------

library(shiny)
library(bslib)
library(DT)
library(httr)
library(jsonlite)
library(data.table)
library(shinydashboard)
library(mongolite)
library(shinycssloaders)
library(quarto)
library(RMySQL)
library(stringr)


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

#------------------------------# UI (User interface) #--------------------------

ui <- dashboardPage(
  dashboardHeader(title = "Forensis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Zemljišne knjige RH", tabName = "zemljisne_knjige", icon = icon("book")),
      menuItem("Registar plovila RH", tabName = "registar_plovila", icon = icon("ship")),
      menuItem("Forensis dokument", tabName = "forensis_dokument", icon = icon("file-alt")),
      menuItem("Zemljišne knjige RS", tabName = "zemljisne_knjige_RS", icon = icon("book")),
      menuItem("Zemljišne knjige Federacija", tabName = "zemljisne_knjige_F", icon = icon("book")) # Dodano za novi modul
    ),
    collapsible = TRUE,
    collapsed = TRUE
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "zemljisne_knjige",
              MUI_zemljisne_knjige("zemljisne_knjige")
      ),
      tabItem(tabName = "registar_plovila",
              MUI_registar_plovila("registar_plovila")
      ),
      tabItem(tabName = "forensis_dokument",
              MUI_forensis_dokument("forensis_dokument")
      ),
      tabItem(tabName = "zemljisne_knjige_RS",
              MUI_zemljisne_knjige_RS("zemljisne_knjige_RS")
      ),
      tabItem(tabName = "zemljisne_knjige_F",
              MUI_zemljisne_knjige_F("zemljisne_knjige_F")
      )
    )
  )
)

#-------------------------------------------------------------------------------
#-----------------------------------# SERVER #----------------------------------

server <- function(input, output, session) {
  callModule(MS_zemljisne_knjige, "zemljisne_knjige")
  callModule(MS_registar_plovila, "registar_plovila")
  callModule(MS_forensis_dokument, "forensis_dokument")
  callModule(MS_zemljisne_knjige_RS, "zemljisne_knjige_RS")
  callModule(MS_zemljisne_knjige_F, "zemljisne_knjige_F")
}

#-------------------------------------------------------------------------------

# Pokretanje aplikacije
shinyApp(ui, server)
