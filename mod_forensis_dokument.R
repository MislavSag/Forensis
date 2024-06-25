# mod_forensis_dokument.R

MUI_forensis_dokument <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Forensis Dokument"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("oib"), "Unesite OIB:", value = "",
                  placeholder = "Unesite OIB i pritisnite Enter ili kliknite Generiraj dokument"),
        textInput(ns("ime_prezime"), "Unesite Ime i Prezime (neobavezno):", value = ""),
        actionButton(ns("render_btn"), "Generiraj dokument"),
        tags$p("Napomena: Generiranje izvještaja traje cca 2 minute."),
        uiOutput(ns("download_ui"))
      ),
      mainPanel(
        shinycssloaders::withSpinner(
          uiOutput(ns("html_output"))
        )
      )
    ),
    tags$script(
      HTML(sprintf("
        $(document).on('keypress', function(e) {
          if(e.which == 13 && $('#%s').is(':focus')) {
            $('#%s').click();
          }
        });
      ", ns("oib"), ns("render_btn")))
    )
  )
}

MS_forensis_dokument <- function(input, output, session) {
  ns <- session$ns

  html_file = eventReactive(input$render_btn, {
    req(input$oib)

    ime_prezime <- input$ime_prezime

    if (ime_prezime == "") {
      data <- loadDataFiz(input$oib)
      if (nrow(data) > 0) {
        ime_prezime <- data$ime_prezime[1]
      } else {
        ime_prezime <- ""
      }
    }

    yaml_content <- paste0(
      "oib: '", input$oib, "'\n",
      "ime_prezime: '", ime_prezime, "'\n"
    )
    param_file <- "params.yml"
    writeLines(yaml_content, param_file)

    file_name_ = paste0(input$oib, '.html')
    print(file_name_)

    render_command <- paste('quarto render forensis_quarto.qmd --execute-params', param_file,
                            '--output ', file_name_,
                            '--output-dir reports')
    system(render_command, wait = TRUE)

    return(file_name_)
  })

  output$html_output <- renderUI({
    invalidateLater(180000, session)
    tags$iframe(style = "height:1000px; width:100%",
                src = sprintf("my_resource/%s", html_file()))
  })

  output$download_ui <- renderUI({
    if (!is.null(html_file())) {
      downloadButton(ns("download_btn"), "Preuzmi dokument", class = "btn btn-success")
    }
  })

  output$download_btn <- downloadHandler(
    filename = function() {
      html_file()
    },
    content = function(file) {
      file.copy(file.path("reports", html_file()), file)
    }
  )
}
