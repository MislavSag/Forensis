# mod_forensis_fizicke_osobe.R

MUI_forensis_fizicke_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyFeedback(), # Omogućuje korištenje shinyFeedback-a
    titlePanel("Forensis Fizičke Osobe"),
    fluidRow(
      column(12, align = "center",
             div(style = "display: inline-block; width: 80%; max-width: 600px;",
                 tags$div(style = "font-weight: bold; font-size: 16px; margin-bottom: 10px;",
                          textInput(ns("oib"), "Unesite OIB:", value = "",
                                    placeholder = "Unesite OIB i pritisnite Enter ili kliknite Generiraj dokument"),
                          textInput(ns("ime_prezime"), "Unesite Ime i Prezime (neobavezno):", value = "")
                 ),
                 actionButton(ns("render_btn"), "Generiraj dokument", style = "width:100%; font-weight: bold; font-size: 16px; background-color: #337ab7; color: white;"),
                 tags$p("Napomena: Generiranje izvještaja traje cca 2 minute.")
             ),
             uiOutput(ns("download_ui"))
      )
    ),
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

  html_file = eventReactive(input$render_btn, {
    req(input$oib)

    # Provjera duljine OIB-a
    if (nchar(input$oib) != 11) {
      showFeedbackDanger(inputId = "oib", text = "OIB mora imati točno 11 znakova.")
      return(NULL)
    } else {
      hideFeedback("oib")
    }

    # Provjera valjanosti OIB-a
    if (oib_checker(input$oib) != 1) {
      showFeedbackDanger(inputId = "oib", text = "Neispravan OIB.")
      return(NULL)
    } else {
      hideFeedback("oib")
    }

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

    file_name_ = paste0(input$oib, '_fizicke.html')
    print(file_name_)

    render_command <- paste('quarto render fizicke_quarto.qmd --execute-params', param_file,
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
