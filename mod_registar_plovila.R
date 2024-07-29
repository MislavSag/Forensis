# UI funkcija za modul
MUI_registar_plovila <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Pretraga plovila RH"),
    fluidRow(
      column(12, align = "center",
             div(style = "display: inline-block; width: 80%; max-width: 600px;",
                 tags$div(style = "font-weight: bold; font-size: 16px; margin-bottom: 10px;",
                          textInput(ns("search_term"), "Unesite naziv:", value = "",
                                    placeholder = "Unesite naziv i pritisnite Enter ili kliknite na Pretraži")
                 ),
                 actionButton(ns("search_button"), "Pretraži", style = "width:100%; font-weight: bold; font-size: 16px; background-color: #337ab7; color: white;")
             )
      )
    ),
    fluidRow(
      column(12,
             div(style = "width: 100%;",
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
      DT_plovila(results)
    }
  }, server = FALSE) # OVDJE JE DODANA POSTAVKA server = FALSE
}
