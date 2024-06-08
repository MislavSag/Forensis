# VER1 :NE RADI
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
    # includeHTML("forensis_quarto.html")
    # tags$iframe(src = "forensis_quarto.html")
    tags$iframe(style="height:485px; width:100%", src = "my_resource/forensis_quarto.html")
  })
}



# # # ova verzija sa iframe mi baca error 404
# # mod_forensis_dokument.R
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
#     tags$iframe(src = "forensis_quarto.html", width = "100%", height = "800px")
#   })
# }


