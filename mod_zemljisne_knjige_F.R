# mod_zemljisne_knjige_F.R

# UI funkcija za modul
MUI_zemljisne_knjige_F <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Zemljišne knjige Federacija"),
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
MS_zemljisne_knjige_F <- function(input, output, session) {
  ns <- session$ns

  pretraga_rezultati <- eventReactive(input$search_button, {
    req(input$search_term)

    # Dohvaćanje rezultata pretrage iz API-ja za Federaciju
    zkf_data <- zkrs(naziv = input$search_term, table = "zk_f_vlasnici")
    if (nrow(zkf_data) == 0) return(NULL)

    return(zkf_data)
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
      DT_template(results)
    }
  })
}
