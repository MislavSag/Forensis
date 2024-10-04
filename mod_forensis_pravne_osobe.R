MUI_forensis_pravne_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyFeedback(), # Omogućuje korištenje shinyFeedback-a
    fluidRow(
      column(width = 4, offset = 4, align = "center",
             h2("Izrada forenzičkog izvještaja za", strong("pravne"), "osobe"),
             br(),
             textInput(ns("oib"), "OIB", width = "50%"),
             br(),
             actionButton(ns("render_btn"), "Generiraj dokument"),
             # Dodana napomena ispod gumba
             br(),
             tags$small(
               style = "color: gray;",
               "Napomena: Generiranje izvještaja može potrajati nekoliko minuta."),
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

MS_forensis_pravne_osobe <- function(input, output, session) {
  ns <- session$ns

  generate_report_task <- ExtendedTask$new(function(oib) {
    future_promise({
      cat("Task started\n")

      # Provjera OIB-a
      if (nchar(oib) != 11) {
        stop("OIB mora imati točno 11 znakova.")
      }

      if (oib_checker(oib) != 1) {
        stop("Neispravan OIB.")
      }

      yaml_content <- paste0("oib: '", oib, "'\n")
      param_file <- "params.yml"
      writeLines(yaml_content, param_file)
      cat("YAML file written\n")

      file_name_ <- paste0(oib, '_pravne.html')
      render_command <- paste('quarto render pravne_quarto.qmd --execute-params', param_file,
                              '--output ', file_name_,
                              '--output-dir reports')

      cat("Render command: ", render_command, "\n")
      system(render_command, wait = TRUE)

      cat("Task completed, file generated: ", file_name_, "\n")
      return(file_name_)
    })
  }) |> bind_task_button(ns("render_btn"))

  observeEvent(input$render_btn, {
    cat("Invoke task with OIB: ", input$oib, "\n")
    generate_report_task$invoke(input$oib)
  })

  output$html_output <- renderUI({
    tags$iframe(style = "height:1000px; width:100%",
                src = sprintf("my_resource/%s", generate_report_task$result()))
  })

  output$download_ui <- renderUI({
    req(generate_report_task$result())
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
