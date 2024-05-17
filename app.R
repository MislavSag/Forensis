#-------------------------------------------------------------------------------
#-----------------------------------# PAKETI #----------------------------------

library(shiny)
library(bslib)
library(DT)
library(httr)
library(jsonlite)
# library(tidyverse) # TODO: install individual packages
library(data.table)
library(shinydashboard)
library(mongolite)

# library(microbenchmark) # izračun vremena operacija

# Učitavanje zasebnih skripti
source("functions.R")

# Učitajte varijable okruženja
db_url <- Sys.getenv("db_url")
print(db_url)
db_name <- Sys.getenv("db_name")
collection_name <- Sys.getenv("collection_name")

#------------------------------# UI (User interface) #--------------------------

ui <- dashboardPage(
  dashboardHeader(title = "Forensis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Pretraga", tabName = "pretraga", icon = icon("search")),
      menuItem("Analiza", tabName = "analiza", icon = icon("chart-line"))
    ),
    collapsible = TRUE,
    collapsed = TRUE
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "pretraga",
              fluidPage(
                titlePanel("Pretraga Katastra"),
                sidebarLayout(
                  sidebarPanel(
                    textInput("term", "Unesite pojam za pretragu katastra", value = ""),
                    radioButtons("checkbox", "Pretraži dio",
                                 choices = list("Sve" = "0", "Dio A" = "1", "Dio B" = "2", "Dio C" = "3"),
                                 selected = "0"),
                    radioButtons("history", "Povijest",
                                 choices = list("Da" = "true", "Ne" = "false"),
                                 selected = "true"),
                    actionButton("pretraga", "Pretraži", style = "width:100%;")
                  ),
                  mainPanel(
                    dataTableOutput("rezultati_tab")
                  )
                )
              )
      ),
      tabItem(tabName = "analiza",
              fluidPage(
                titlePanel("Analiza Podataka")
              )
      )
    )
  )
)

#-------------------------------------------------------------------------------
#-----------------------------------# SERVER #----------------------------------

server <- function(input, output) {
  pretraga_rezultati <- eventReactive(input$pretraga, {
    req(input$term)

    # Dohvaćanje rezultata pretrage iz API-ja
    api_data <- dac_hr_api(input$term, input$checkbox, input$history)
    if (nrow(api_data) == 0) return(data.table(Rezultat = "Nem rezultata pretrage"))

    # Dohvaćanje dokumenata iz MongoDB-a
    mongo_data <- get_doc_MongoDB(api_data$id)

    # Spajanje podataka
    final_data <- spoji_podatke(api_data, mongo_data)

    # Ažuriranje URL-a
    base_url <- "https://oss.uredjenazemlja.hr/oss/public/reports/ldb-extract/"
    final_data[, fileUrl := ifelse(is.na(fileUrl), NA_character_, paste0(base_url, fileUrl))]

    # Odabir potrebnih varijabli
    final_data <- final_data[, .(id, type, unit, institution, book, status, burden, fileUrl)]

    return(final_data)
  })

  output$rezultati_tab <- renderDT({
    if (length(pretraga_rezultati()) == 0) {
      return(data.table(Rezultat = "Nem rezultata pretrage"))
    }

    datatable(pretraga_rezultati(), escape = FALSE, options = list(
      columnDefs = list(
        list(targets = ncol(pretraga_rezultati()),  # Dinamičko određivanje indeksa stupca fileUrl
             render = JS(
               "function(data, type, row) {
                 return type === 'display' && data ? '<a href=\"' + data + '\" target=\"_blank\">Open</a>' : data;
               }"
             )
        )
      )
    ))
  })
}

#-------------------------------------------------------------------------------

# Pokretanje aplikacije
shinyApp(ui, server)










