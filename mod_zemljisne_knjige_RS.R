# mod_zemljisne_knjige_RS.R

# UI funkcija za modul
MUI_zemljisne_knjige_RS <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Zemljišne knjige RS"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("search_term"), "Unesite naziv:", value = ""),
        actionButton(ns("search_button"), "Pretraži", style = "width:100%;")
      ),
      mainPanel(
        uiOutput(ns("rezultati_tab")) %>% withSpinner(type = 8, color = "#0dc5c1")
      )
    )
  )
}

# Server funkcija za modul
MS_zemljisne_knjige_RS <- function(input, output, session) {
  ns <- session$ns

  pretraga_rezultati <- eventReactive(input$search_button, {
    req(input$search_term)

    # Dohvaćanje rezultata pretrage iz API-ja
    zkrs_data <- zkrs(naziv = input$search_term)
    if (nrow(zkrs_data) == 0) return(NULL)

    return(zkrs_data)
  })

  output$rezultati_tab <- renderUI({
    results <- pretraga_rezultati()
    if (is.null(results) || nrow(results) == 0) {
      return(HTML("<p style='font-size: 20px; color: red; font-weight: bold;'>Nema rezultata pretrage</p>"))
    } else {
      return(DT::dataTableOutput(ns("results_table")))
    }
  })

  output$results_table <- DT::renderDataTable({
    results <- pretraga_rezultati()
    if (!is.null(results) && nrow(results) > 0) {
      DT_template(results)
    }
  })
}
