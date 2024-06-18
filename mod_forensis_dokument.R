# mod_forensis_dokument.R

MUI_forensis_dokument <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Forensis Dokument"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("oib"), "Unesite OIB:", value = ""),
        textInput(ns("ime_prezime"), "Unesite Ime i Prezime (neobavezno):", value = ""),
        actionButton(ns("render_btn"), "Generiraj dokument"),
        uiOutput(ns("download_ui")) # Koristimo uiOutput za dinamički prikaz gumba
      ),
      mainPanel(
        shinycssloaders::withSpinner(
          uiOutput(ns("html_output"))
        )
      )
    )
  )
}

MS_forensis_dokument <- function(input, output, session) {
  ns <- session$ns

  ##### MISLAV WAY ######
  html_file = eventReactive(input$render_btn, {
      req(input$oib)

      ime_prezime <- input$ime_prezime

      # Ako ime i prezime nije uneseno, dohvatiti iz baze pomoću OIB-a
      if (ime_prezime == "") {
        data <- loadDataFiz(input$oib)
        if (nrow(data) > 0) {
          ime_prezime <- data$ime_prezime[1]
        } else {
          ime_prezime <- ""
        }
      }

      # Stvorite YAML sadržaj s OIB-om i Ime_Prezime
      yaml_content <- paste0(
        "oib: '", input$oib, "'\n",
        "ime_prezime: '", ime_prezime, "'\n"
      )
      param_file <- "params.yml"
      writeLines(yaml_content, param_file)

      # Crate a file name oib.html
      file_name_ = paste0(input$oib, '.html')
      print(file_name_)

      # Renderirajte Quarto dokument s novim parametrima koristeći params.yml datoteku
      render_command <- paste('quarto render forensis_quarto.qmd --execute-params', param_file,
                              '--output ', file_name_,
                              '--output-dir reports')
      system(render_command, wait = TRUE) # čekanje da se renderiranje završi

      return(file_name_)
  })

  # # Ažurirati iframe za prikaz generiranog dokumenta
  output$html_output <- renderUI({
    invalidateLater(180000, session) # Provjeri promjene svakih 3 minute (180000 ms)
    tags$iframe(style = "height:1000px; width:100%",
                src = sprintf("my_resource/%s", html_file()))
  })

  # Prikaz gumba za preuzimanje dokumenta nakon generiranja
  output$download_ui <- renderUI({
    if (!is.null(html_file())) {
      downloadButton(ns("download_btn"), "Preuzmi dokument", class = "btn btn-success")
    }
  })

  # Omogućite preuzimanje generiranog dokumenta
  output$download_btn <- downloadHandler(
    filename = function() {
      html_file()
      },
    content = function(file) {
      file.copy(file.path("reports", html_file()), file)
    }
  )
}
