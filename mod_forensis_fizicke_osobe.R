# mod_forensis_fizicke_osobe.R

MUI_forensis_fizicke_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyFeedback(), # Omogućuje korištenje shinyFeedback-a
    fluidRow(
      column(width = 4, offset = 4,
             align = "center",
             h2("Izrada forenzičkog izvještaja za", strong("fizičke"), " osobe"),
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

  observeEvent(input$render_btn, {
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
        showFeedbackWarning(inputId = "ime_prezime", text = "Ime i prezime nisu pronađeni, molim vas unesite ime i prezime u tražilicu.
                            Izvještaj će prikazati rezultate samo za uneseni OIB")
      }
    }

    yaml_content <- paste0(
      "oib: '", input$oib, "'\n",
      "ime_prezime: '", ime_prezime, "'\n"
    )
    param_file <- "params.yml"
    writeLines(yaml_content, param_file)

    # Debug ispis YAML sadržaja
    cat("YAML Content:\n", yaml_content, "\n")

    file_name_ = paste0(input$oib, '_fizicke.html')
    print(file_name_)

    render_command <- paste('quarto render fizicke_quarto.qmd --execute-params', param_file,
                            '--output ', file_name_,
                            '--output-dir reports')

    # Debug ispis render naredbe
    cat("Render Command:\n", render_command, "\n")

    system(render_command, wait = TRUE)

    output$html_output <- renderUI({
      invalidateLater(180000, session)
      tags$iframe(style = "height:1000px; width:100%",
                  src = sprintf("my_resource/%s", file_name_))
    })

    output$download_ui <- renderUI({
      if (!is.null(file_name_)) {
        downloadButton(ns("download_btn"), "Preuzmi dokument", class = "btn btn-success")
      }
    })

    output$download_btn <- downloadHandler(
      filename = function() {
        file_name_
      },
      content = function(file) {
        file.copy(file.path("reports", file_name_), file)
      }
    )
  })
}
