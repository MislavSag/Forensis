# mod registar plovila

# UI funkcija za modul
MUI_registar_plovila <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML("
        .table-container {
          width: 80%;
          margin: 0 auto;
        }
      "))
    ),
    fluidRow(
      column(width = 4, offset = 4,
             h2("Brza pretraga plovila u registru plovila"),
             br(),
             br(),
             textInput(ns("search_term"), "Unesite pojam", width = "100%"),
             br(),
             actionButton(ns("search_button"), "Pretraži"),
             br(),
             br(),
             style = 'text-align: center;'
      )),
    fluidRow(
      column(12,
             div(class = "table-container",
                 uiOutput(ns("rezultati_tab")) %>% withSpinner(type = 8, color = "#0dc5c1")
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
      ", ns("search_term"), ns("search_button")))
    )
  )
}

# Server funkcija za modul
MS_registar_plovila <- function(input, output, session) {
  ns <- session$ns

  pretraga_rezultati <- eventReactive(input$search_button, {
    req(input$search_term)

    # Dohvaćanje rezultata pretrage iz baze podataka
    plovila_data <- loadData_plovila(input$search_term)
    if (nrow(plovila_data) == 0) return(NULL)

    return(plovila_data)
  })

  output$rezultati_tab <- renderUI({
    results <- pretraga_rezultati()
    if (is.null(results) || nrow(results) == 0) {
      return(HTML("<p style='font-size: 20px; color: red; font-weight: bold;'>Nema rezultata pretrage</p>"))
    } else {
      return(dataTableOutput(ns("results_table")))
    }
  })

  output$results_table <- renderDataTable({
    results <- pretraga_rezultati()
    if (!is.null(results) && nrow(results) > 0) {
      DT_template_ZKBIH_plovila(results, filename_prefix = "Plovila_")
    }
  }, server = FALSE) # OVDJE JE DODANA POSTAVKA server = FALSE
}
