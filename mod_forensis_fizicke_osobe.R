# Modul fizičke osobe

# UI funkcija za modul
MUI_forensis_fizicke_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyFeedback(),  # Omogućuje korištenje shinyFeedback-a
    fluidRow(
      column(
        width = 4, offset = 4, align = "center",
        h2("Izrada forenzičkog izvještaja za", strong("fizičke"), "osobe"),
        br(), br(),
        textInput(ns("oib"), "OIB", width = "50%"),
        br(),
        textInput(ns("ime_prezime"), "Ime i Prezime (neobavezno)", width = "50%"),
        br(),
        actionButton(ns("render_btn"), "Generiraj dokument"),
        # Dodana napomena ispod gumba
        br(),
        tags$small(
          style = "color: gray;",
          "Napomena: Generiranje izvještaja može potrajati nekoliko minuta."),
        br(), br(),
        uiOutput(ns("download_ui"))
      )
    ),
    br(),
    br(),
    fluidRow(
      column(
        12,
        div(
          style = "width: 100%;",
          shinycssloaders::withSpinner(
            uiOutput(ns("html_output"))
          )
        )
      )
    ),
    tags$script(
      HTML(sprintf(
        "
        $(document).on('keypress', function(e) {
          if(e.which == 13 && $('#%s').is(':focus')) {
            $('#%s').click();
          }
        });
        ", ns("oib"), ns("render_btn")
      ))
    )
  )
}

# Server funkcija za modul
MS_forensis_fizicke_osobe <- function(input, output, session) {
  ns <- session$ns

  # 1) Kreiramo zadatak za generiranje izvještaja
  #    (ovdje smo maknuli "stop()" za OIB i ime_prezime - umjesto toga,
  #     validirat ćemo ih prije samog pokeštanja).
  generate_report_task <- ExtendedTask$new(function(oib, ime_prezime) {
    # Ovdje radimo samo "glavni" posao - generiranje dokumenta
    future_promise({
      cat("Task started\n")

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
      render_command <- paste(
        'quarto render fizicke_quarto.qmd --execute-params', param_file,
        '--output', file_name_,
        '--output-dir reports'
      )

      cat("Render Command:\n", render_command, "\n")
      system(render_command, wait = TRUE)

      cat("Task completed, file generated: ", file_name_, "\n")
      return(file_name_)
    })
  }) |> bind_task_button(ns("render_btn"))

  # 2) observeEvent: kada kliknemo na "Generiraj dokument",
  #    prvo provjeravamo OIB i pokušavamo dohvatiti ime/prezime
  #    prije samog 'invoke' ExtendedTask-a.
  observeEvent(input$render_btn, {
    cat("Invoke task with OIB: ", input$oib, "\n")

    # a) Provjera duljine OIB-a
    if (nchar(input$oib) != 11) {
      showFeedbackDanger(
        inputId = "oib",
        text = "OIB mora imati točno 11 znakova!"
      )
      return(NULL)
    } else {
      hideFeedback("oib")  # ako je sve ok, sakrij poruku
    }

    # b) Provjera ispravnosti OIB-a
    if (oib_checker(input$oib) != 1) {
      showFeedbackDanger(
        inputId = "oib",
        text = "Neispravan OIB!"
      )
      return(NULL)
    } else {
      hideFeedback("oib")
    }

    # c) Ako ime/prezime nije uneseno, pokušaj dohvatiti iz baze
    ime_prezime_local <- input$ime_prezime
    if (ime_prezime_local == "") {
      cat("Fetching data for OIB: ", input$oib, "\n")
      data <- loadDataFiz(input$oib)
      if (nrow(data) > 0) {
        ime_prezime_local <- data$ime_prezime[1]
      } else {
        showFeedbackDanger(
          inputId = "ime_prezime",
          text = "Nije pronađeno ime i prezime za navedeni OIB.
          Potrebno je napisati ime i prezime za generiranje izvještaja."
        )
        return(NULL)
      }
    } else {
      hideFeedback("ime_prezime")
    }

    # Ako je sve prošlo bez return(NULL), možemo pokrenuti zadatak
    generate_report_task$invoke(input$oib, ime_prezime_local)
  })

  # 3) iframe prikaz HTML-a nakon što je generiran
  output$html_output <- renderUI({
    req(generate_report_task$result())  # čekaj da postoji rezultat
    tags$iframe(
      style = "height:1000px; width:100%",
      src = sprintf("my_resource/%s", generate_report_task$result())
    )
  })

  # 4) Gumb za preuzimanje generiranog dokumenta
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

