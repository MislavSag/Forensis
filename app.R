require(shiny)
require(bslib)
require(DT)
require(httr)
require(jsonlite)
require(data.table)
require(mongolite)
require(shinycssloaders)
require(shinyFeedback)
require(RMySQL)
require(stringr)
require(shinyjs)
# require(firebase)
require(promises)  # Za asinkrono programiranje
require(future)  # Za asinkrono programiranje
require(openxlsx)
# Postavljanje plana za future
future::plan(multisession, workers = 2)

# Provjera postojanja direktorija i kreiranje ako ne postoji
if (!dir.exists("reports")) {
  dir.create("reports")
}

# Add resource path for Quarto HTML file
addResourcePath("my_resource", "reports")

# Učitavanje zasebnih skripti
source("functions.R")
source("mod_zemljisne_knjige.R")
source("mod_registar_plovila.R")
source("mod_forensis_fizicke_osobe.R")
source("mod_zemljisne_knjige_RS.R")
source("mod_zemljisne_knjige_F.R")
source("mod_forensis_pravne_osobe.R")

ui = page_navbar(
  title = "Forensis",
  id = "nav",
  sidebar = NULL,
  nav_panel(title = "Zemljišne knjige RH", MUI_zemljisne_knjige("zemljisne_knjige")),
  nav_panel(title = "Zemljišne knjige RS", MUI_zemljisne_knjige_RS("zemljisne_knjige_RS")),
  nav_panel(title = "Zemljišne knjige Federacija", MUI_zemljisne_knjige_F("zemljisne_knjige_F")),
  nav_panel(title = "Registar plovila RH", MUI_registar_plovila("registar_plovila")),
  nav_panel(title = "Forensis fizičke osobe", MUI_forensis_fizicke_osobe("forensis_fizicke_osobe")),
  nav_panel(title = "Forensis pravne osobe", MUI_forensis_pravne_osobe("forensis_pravne_osobe")),
  nav_spacer(),
  nav_panel(
    tags$a(
      icon("sign-out-alt"),
      "Odjava",
      href = "https://forensis.shinyapps.io/ForensisTest/__logout__/"
    )
  )
)

server <- function(input, output, session) {
  callModule(MS_zemljisne_knjige, "zemljisne_knjige")
  callModule(MS_zemljisne_knjige_RS, "zemljisne_knjige_RS")
  callModule(MS_zemljisne_knjige_F, "zemljisne_knjige_F")
  callModule(MS_registar_plovila, "registar_plovila")
  callModule(MS_forensis_fizicke_osobe, "forensis_fizicke_osobe")
  callModule(MS_forensis_pravne_osobe, "forensis_pravne_osobe")
}

# Pokretanje aplikacije
shinyApp(ui, server)
