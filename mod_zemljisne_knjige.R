# mod_zemljisne_knjige.R

# UI funkcija za modul
MUI_zemljisne_knjige <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML(".table-container {
          width: 80%;
          margin: 0 auto;
        }
        .center-radio {
          display: flex;
          justify-content: center;
          margin-bottom: 10px;
        }
        .center-radio .shiny-input-container {
          margin: 0 15px;
        }"))
    ),
    tagList(
      fluidRow(
        column(width = 4, offset = 4,
               align = "center",
               h2("Brza pretraga nekretnina u zemljišnim knjigama i knjizi položenih ugovora u ",
                  strong("Republici Hrvatskoj")),
               br(),
               br(),
               textInput(ns("term"), "Unesite pojam", width = "100%"),
               br(),
               div(class = "center-radio",
                   radioButtons(
                     ns("checkbox"),
                     "Pretraži dio",
                     choices = list(
                       "Sve" = "0",
                       "Dio A" = "1",
                       "Dio B" = "2",
                       "Dio C" = "3"
                     ),
                     selected = "0",
                     inline = TRUE
                   )
               ),
               br(),
               div(class = "center-radio",
                   radioButtons(
                     ns("history"),
                     "Povijest",
                     choices = list("Da" = "true", "Ne" = "false"),
                     selected = "true",
                     inline = TRUE
                   )
               ),
               br(),
               br(),
               div(class = "center-radio",
                   selectizeInput(ns("book_filter"), "Glavna knjiga:", choices = NULL, selected = NULL, multiple = FALSE, options = list(placeholder = 'Pretražite glavne knjige...'))
               ),
               br(),
               actionButton(ns("pretraga"), "Pretraži"),
               br(),
               br(),
               style = 'text-align: center;'
        )),
      fluidRow(
        column(12,
               div(class = "table-container",
                   uiOutput(ns("rezultati_tab")) %>% shinycssloaders::withSpinner(type = 8, color = "#0dc5c1")
               )
        )
      ),
      tags$script(
        HTML(sprintf("$(document).on('keypress', function(e) {
            if(e.which == 13 && $('#%s').is(':focus')) {
              $('#%s').click();
            }
          });", ns("term"), ns("pretraga")))
      )
    )
  )
}

# Server funkcija za modul
MS_zemljisne_knjige <- function(input, output, session, f) {
  # Dohvaćanje meta podataka za filter glavne knjige
  meta <- fread("meta-20240710141424.csv")
  observe({
    sorted_books <- sort(unique(meta$value1))
    updateSelectizeInput(session, "book_filter", choices = c("Sve", sorted_books), server = TRUE)
  })

  pretraga_rezultati <- eventReactive(input$pretraga, {
    req(input$term)

    # Dohvaćanje rezultata pretrage iz API-ja
    if (Sys.info()["user"] == "Mislav") {
      zkrh_data <- zkrh(input$term, input$checkbox, input$history, limit = input$limit)
    } else {
      zkrh_data <- zkrh(input$term, input$checkbox, input$history, limit = 2000)
    }

    message("Broj redaka nakon dohvaćanja podataka: ", nrow(zkrh_data))

    if (nrow(zkrh_data) == 0) {
      showNotification("Nema rezultata za unijeti pojam.", type = "error")
      return(NULL)
    }

    # Dohvaćanje dokumenata iz MongoDB-a
    mongo_data <- mongoDB(zkrh_data$id, collection = collection_name, db = db_name, url = db_url)

    # Spajanje podataka
    final_data <- spoji_podatke(zkrh_data, mongo_data)

    # Ažuriranje URL-a
    base_url <- "https://oss.uredjenazemlja.hr/oss/public/reports/ldb-extract/"
    final_data[, fileUrl := ifelse(is.na(fileUrl), NA_character_, paste0(base_url, fileUrl))]

    # Odabir potrebnih varijabli i promjena imena stupaca
    final_data <- final_data[, .(id, type, unit, institution, book, status, burden, fileUrl)]
    setnames(final_data, old = c("id", "type", "unit", "institution", "book", "status", "burden", "fileUrl"),
             new = c("ID", "Vrsta knjige", "Broj zemljišta (kat. čestice)", "Općinski sud / ZK odjel", "Glavna knjiga", "Status", "Teret", "Link"))

    # Prilagodba stupca 'Glavna knjiga'
    final_data[, `Glavna knjiga` := toupper(gsub("^Zemljišnoknjižni odjel ", "", `Glavna knjiga`))]

    # Uklanjanje redova sa svim NA vrednostima
    final_data <- na.omit(final_data)

    message("Broj redaka nakon transformacije podataka: ", nrow(final_data))

    # Ako je odabran filter za 'Glavna knjiga'
    if (!is.null(input$book_filter) && input$book_filter != "Sve") {
      filtered_data <- final_data[`Glavna knjiga` == input$book_filter, ]
      message("Broj redaka nakon filtriranja glavnih knjiga: ", nrow(filtered_data))
      if (nrow(filtered_data) == 0) {
        showNotification("Nema dostupnih rezultata za odabranu glavnu knjigu.", type = "error")
        return(NULL)
      }
      return(filtered_data[1:min(100, nrow(filtered_data)), ])  # Selektira do 100 redova ili manje ako je dostupno
    }

    message("Broj redaka nakon primene svih filtera: ", nrow(final_data))
    return(final_data[1:min(100, nrow(final_data)), ])  # Selektira do 100 redova ili manje ako je dostupno
  })

  output$rezultati_tab <- renderUI({
    results <- pretraga_rezultati()
    if (is.null(results) || nrow(results) == 0) {
      return(HTML("<p style='font-size: 20px; color: red; font-weight: bold;'>Nema rezultata pretrage</p>"))
    } else {
      return(dataTableOutput(session$ns("results_table")))
    }
  })

  output$results_table <- renderDataTable({
    results <- pretraga_rezultati()
    if (!is.null(results) && nrow(results) > 0) {
      DT_template_ZKRH(results)  # Koristi funkciju za prikaz tablice
    }
  }, server = FALSE)
}
