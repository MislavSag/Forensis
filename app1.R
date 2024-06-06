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
library(quarto)
library(RMySQL)
library(purrr) # za map_dfr u load_zkrs
library(stringr)


# Učitavanje zasebnih skripti
source("functions.R")
source("mod_zemljisne_knjige.R")
source("mod_registar_plovila.R")
source("mod_forensis_dokument.R")
source("mod_zemljisne_knjige_RS.R")  # Uključivanje nove skripte

#------------------------------# UI (User interface) #--------------------------

ui <- dashboardPage(
  dashboardHeader(title = "Forensis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Zemljišne knjige RH", tabName = "zemljisne_knjige", icon = icon("book")),
      menuItem("Registar plovila RH", tabName = "registar_plovila", icon = icon("ship")),
      menuItem("Forensis dokument", tabName = "forensis_dokument", icon = icon("file-alt")),
      menuItem("Zemljišne knjige RS", tabName = "zemljisne_knjige_RS", icon = icon("book"))  # Dodavanje novog modula
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
      ),
      tabItem(tabName = "zemljisne_knjige_RS",  # UI za novi modul
              MUI_zemljisne_knjige_RS("zemljisne_knjige_RS")
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
  callModule(MS_zemljisne_knjige_RS, "zemljisne_knjige_RS")  # Server funkcija za novi modul
}

#-------------------------------------------------------------------------------

# Pokretanje aplikacije
shinyApp(ui, server)
