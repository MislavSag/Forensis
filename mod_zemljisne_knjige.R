# mod_zemljisne_knjige.R

MUI_zemljisne_knjige <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Zemljišne knjige RH"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("term"), "Unesite pojam za pretragu katastra", value = ""),
        radioButtons(ns("checkbox"), "Pretraži dio",
                     choices = list("Sve" = "0", "Dio A" = "1", "Dio B" = "2", "Dio C" = "3"),
                     selected = "0"),
        radioButtons(ns("history"), "Povijest",
                     choices = list("Da" = "true", "Ne" = "false"),
                     selected = "true"),
        sliderInput(ns("limit"), "Limit rezultata:", min = 50, max = 1000, value = 200, step = 50),
        actionButton(ns("pretraga"), "Pretraži", style = "width:100%;")
      ),
      mainPanel(
        uiOutput(ns("rezultati_tab")) %>% withSpinner(type = 8, color = "#0dc5c1")
      )
    )
  )
}

MS_zemljisne_knjige <- function(input, output, session) {
  pretraga_rezultati <- eventReactive(input$pretraga, {
    req(input$term)

    # Dohvaćanje rezultata pretrage iz API-ja
    zkrh_data <- zkrh(input$term, input$checkbox, input$history, limit = input$limit)
    if (nrow(zkrh_data) == 0) return(NULL)

    # Dohvaćanje dokumenata iz MongoDB-a
    mongo_data <- mongoDB(zkrh_data$id)

    # Spajanje podataka
    final_data <- spoji_podatke(zkrh_data, mongo_data)

    # Ažuriranje URL-a
    base_url <- "https://oss.uredjenazemlja.hr/oss/public/reports/ldb-extract/"
    final_data[, fileUrl := ifelse(is.na(fileUrl), NA_character_, paste0(base_url, fileUrl))]

    # Odabir potrebnih varijabli i promjena imena stupaca
    final_data <- final_data[, .(id, type, unit, institution, book, status, burden, fileUrl)]
    setnames(final_data, old = c("id", "type", "unit", "institution", "book", "status", "burden", "fileUrl"),
             new = c("ID", "Vrsta knjige", "Broj zemljišta (kat. čestice)", "Općinski sud / ZK odjel", "Glavna knjiga", "Status", "Teret", "Link"))

    return(final_data)
  })

  output$rezultati_tab <- renderUI({
    results <- pretraga_rezultati()
    if (is.null(results) || nrow(results) == 0) {
      return(HTML("<p style='font-size: 20px; color: red; font-weight: bold;'>Nema rezultata pretrage</p>"))
    } else {
      return(DT::dataTableOutput(session$ns("results_table")))
    }
  })

  output$results_table <- DT::renderDataTable({
    results <- pretraga_rezultati()
    if (!is.null(results) && nrow(results) > 0) {
      datatable(results, escape = FALSE, options = list(
        columnDefs = list(
          list(targets = ncol(results),  # Dinamičko određivanje indeksa stupca Link
               render = JS(
                 "function(data, type, row) {
                   return type === 'display' && data ? '<a href=\"' + data + '\" target=\"_blank\">Open</a>' : data;
                 }"
               )
          )
        )
      ))
    }
  })
}
