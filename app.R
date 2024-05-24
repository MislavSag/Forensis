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
library(shinycssloaders) # ovo je za spinera kod pretraživanja / maknuti ?

# Učitavanje zasebnih skripti
source("functions.R")
source("mod_zemljisne_knjige.R")
source("mod_registar_plovila.R")
source("mod_forensis_dokument.R")

# Učitajte varijable okruženja
db_url <- Sys.getenv("db_url")
db_name <- Sys.getenv("db_name")
collection_name <- Sys.getenv("collection_name")

#------------------------------# UI (User interface) #--------------------------

ui <- dashboardPage(
  dashboardHeader(title = "Forensis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Zemljišne knjige RH", tabName = "zemljisne_knjige", icon = icon("book")),
      menuItem("Registar plovila RH", tabName = "registar_plovila", icon = icon("ship")),
      menuItem("Forensis dokument", tabName = "forensis_dokument", icon = icon("file-alt"))
    ),
    collapsible = TRUE,
    collapsed = TRUE
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "zemljisne_knjige",
              MUI_zemljisne_knjige("zemljisne_knjige1")
      ),
      tabItem(tabName = "registar_plovila",
              MUI_registar_plovila("registar_plovila1")
      ),
      tabItem(tabName = "forensis_dokument",
              MUI_forensis_dokument("forensis_dokument1")
      )
    )
  )
)

#-------------------------------------------------------------------------------
#-----------------------------------# SERVER #----------------------------------

server <- function(input, output, session) {
  callModule(MS_zemljisne_knjige, "zemljisne_knjige1")
  callModule(MS_registar_plovila, "registar_plovila1")
  callModule(MS_forensis_dokument, "forensis_dokument1")
}

#-------------------------------------------------------------------------------

# Pokretanje aplikacije
shinyApp(ui, server)
