# VER1 :NE RADI
# mod_forensis_dokument.R
#
# MUI_forensis_dokument <- function(id) {
#   ns <- NS(id)
#   fluidPage(
#     titlePanel("Forensis Dokument"),
#     mainPanel(
#       uiOutput(ns("html_output"))
#     )
#   )
# }
#
# MS_forensis_dokument <- function(input, output, session) {
#   ns <- session$ns
#
#   output$html_output <- renderUI({
#     includeHTML("forensis_quarto.html")
#   })
# }


# VER2 :NE RADI
# mod_forensis_dokument.R

MUI_forensis_dokument <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Forensis Dokument"),
    mainPanel(
      uiOutput(ns("html_output"))
    )
  )
}

MS_forensis_dokument <- function(input, output, session) {
  ns <- session$ns

  output$html_output <- renderUI({
    tags$iframe(src = "forensis_quarto.html", width = "100%", height = "800px")
  })
}

