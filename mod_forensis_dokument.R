# mod_forensis_dokument.R

MUI_forensis_dokument <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Forensis Dokument"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("oib"), "Unesite OIB:", value = ""),
        actionButton(ns("render_btn"), "Generiraj dokument"),
        downloadButton(ns("download_btn"), "Preuzmi dokument")
      ),
      mainPanel(
        uiOutput(ns("html_output"))
      )
    )
  )
}

MS_forensis_dokument <- function(input, output, session) {
  ns <- session$ns

  observeEvent(input$render_btn, {
    req(input$oib)

    # Stvorite YAML sadržaj s novim OIB-om
    yaml_content <- paste0("oib: '", input$oib, "'\n")
    param_file <- "params.yml"
    writeLines(yaml_content, param_file)

    # Renderirajte Quarto dokument s novim parametrima koristeći params.yml datoteku
    render_command <- paste('quarto render forensis_quarto.qmd --execute-params', param_file, '--output-dir reports')
    system(render_command, wait = TRUE) # čekanje da se renderiranje završi

    # Ažurirati iframe za prikaz generiranog dokumenta
    output$html_output <- renderUI({
      invalidateLater(180000, session) # Provjeri promjene svakih 3 minute (180000 ms)
      tags$iframe(style = "height:485px; width:100%", src = "my_resource/forensis_quarto.html")
    })
  })

  # Omogućite preuzimanje generiranog dokumenta
  output$download_btn <- downloadHandler(
    filename = function() {
      paste0("report_", input$oib, ".html")
    },
    content = function(file) {
      file.copy("reports/forensis_quarto.html", file)
    }
  )
}
