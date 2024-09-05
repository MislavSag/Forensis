# modul fizičke osobe

MUI_forensis_fizicke_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyFeedback(), # Omogućuje korištenje shinyFeedback-a
    fluidRow(
      column(width = 4, offset = 4,
             align = "center",
             h2("Izrada forenzičkog izvještaja za", strong("fizičke"), "osobe"),
             br(),
             br(),
             textInput(ns("oib"), "OIB", width = "50%"),
             br(),
             textInput(ns("ime_prezime"), "Ime i Prezime (neobavezno)", width = "50%"),
             br(),
             actionButton(ns("render_btn"), "Generiraj dokument"),
             br(),
             br(),
             uiOutput(ns("download_ui"))
      )),
    fluidRow(
      column(12,
             div(style = "width: 100%;",
                 shinycssloaders::withSpinner(
                   uiOutput(ns("html_output"))
                 )
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

MS_forensis_fizicke_osobe <- function(input, output, session) {
  ns <- session$ns

  # Kreiranje zadatka za generiranje izvještaja
  generate_report_task <- ExtendedTask$new(function(oib, ime_prezime) {
    future_promise({
      cat("Task started\n")

      # Postavljanje mysql opcija unutar paralelnog procesa
      options(mysql = list(
        "host" = "91.234.46.219",
        "port" = 3306L,
        "user" = "odvjet12_mislav",
        "password" = "Contentio0207"
      ))

      # Provjera OIB-a
      if (nchar(oib) != 11) {
        stop("OIB mora imati točno 11 znakova.")
      }

      if (oib_checker(oib) != 1) {
        stop("Neispravan OIB.")
      }

      # Provjera imena i prezimena, dohvat podataka ako ime_prezime nije dano
      if (ime_prezime == "") {
        cat("Fetching data for OIB: ", oib, "\n")
        data <- loadDataFiz(oib)  # Pozivanje loadDataFiz unutar future_promise
        if (nrow(data) > 0) {
          ime_prezime <- data$ime_prezime[1]
        } else {
          ime_prezime <- ""
        }
      }

      # Generiranje YAML datoteke
      yaml_content <- paste0(
        "oib: '", oib, "'\n",
        "ime_prezime: '", ime_prezime, "'\n"
      )
      param_file <- "params.yml"
      writeLines(yaml_content, param_file)

      cat("YAML Content:\n", yaml_content, "\n")

      # Renderiranje izvještaja
      file_name_ <- paste0(oib, '_fizicke.html')
      render_command <- paste('quarto render fizicke_quarto.qmd --execute-params', param_file,
                              '--output ', file_name_,
                              '--output-dir reports')

      cat("Render Command:\n", render_command, "\n")
      system(render_command, wait = TRUE)

      cat("Task completed, file generated: ", file_name_, "\n")
      return(file_name_)
    })
  }) |> bind_task_button(ns("render_btn"))

  observeEvent(input$render_btn, {
    cat("Invoke task with OIB: ", input$oib, "\n")
    generate_report_task$invoke(input$oib, input$ime_prezime)
  })

  output$html_output <- renderUI({
    tags$iframe(style = "height:1000px; width:100%",
                src = sprintf("my_resource/%s", generate_report_task$result()))
  })

  output$download_ui <- renderUI({
    downloadButton(ns("download_btn"), "Preuzmi dokument", class = "btn btn-success")
  })

  output$download_btn <- downloadHandler(
    filename = function() {
      generate_report_task$result()
    },
    content = function(file) {
      file.copy(file.path("reports", generate_report_task$result()), file)
    }
  )
}
