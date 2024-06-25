# modul_pravne_osobe.R

MUI_pravne_osobe <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Podaci pravne osobe"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("oib"), "Unesite OIB:", value = "", placeholder = "Unesite OIB i pritisnite Enter ili kliknite Pretraži"),
        actionButton(ns("pretraga"), "Pretraži", style = "width:100%;")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Opći podaci", DTOutput(ns("opci_podaci"))),
          tabPanel("Tvrtka", DTOutput(ns("tvrtka"))),
          tabPanel("Skraćena Tvrtka", DTOutput(ns("skracena_tvrtka"))),
          tabPanel("Sjedište", DTOutput(ns("sjediste"))),
          tabPanel("Email adrese", DTOutput(ns("email_adrese"))),
          tabPanel("Predmeti poslovanja", DTOutput(ns("predmeti_poslovanja")))
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
      ", ns("oib"), ns("pretraga")))
    )
  )
}

MS_pravne_osobe <- function(input, output, session) {
  ns <- session$ns

  podaci <- eventReactive(input$pretraga, {
    # Dohvaćanje tokena
    response <- POST("https://sudreg-data.gov.hr/api/oauth/token",
                     authenticate("TApnnmx8utL-Y_CmMt-c8w..", "_sDBLXV9IS-If0niA7E4KQ.."),
                     body = list(grant_type = "client_credentials"),
                     encode = "form")

    if (status_code(response) == 200) {
      token_data <- content(response, "parsed", simplifyVector = TRUE)
      access_token <- token_data$access_token

      # Definiranje URL-a za endpoint "/detalji_subjekta"
      base_url <- "https://sudreg-data.gov.hr/api/javni"
      endpoint <- "/detalji_subjekta"
      oib <- input$oib
      url <- paste0(base_url, endpoint, "?tip_identifikatora=oib&identifikator=", oib)

      # Slanje GET zahtjeva na API s autentifikacijom
      response <- GET(url, add_headers(Authorization = paste("Bearer", access_token)))

      if (status_code(response) == 200) {
        # Parsiranje JSON odgovora
        data <- content(response, "parsed", simplifyVector = TRUE)
        return(data)
      } else {
        showModal(modalDialog(
          title = "Greška",
          paste("Status kod:", status_code(response)),
          easyClose = TRUE,
          footer = NULL
        ))
        return(NULL)
      }
    } else {
      showModal(modalDialog(
        title = "Greška",
        paste("Status kod:", status_code(response)),
        easyClose = TRUE,
        footer = NULL
      ))
      return(NULL)
    }
  })

  observeEvent(podaci(), {
    data <- podaci()
    if (!is.null(data)) {
      # Pretvaranje podataka u tablice
      opci_podaci <- data.frame(
        Ključ = c("MBS", "Status", "Sud ID Nadležan", "Sud ID Služba", "OIB", "MB", "Potpuni MBS",
                  "Potpuni OIB", "Ino Podružnica", "Stečajna Masa", "Likvidacijska Masa",
                  "Glavna Djelatnost", "Datum Osnivanja", "Vrijeme Zadnje Izmjene"),
        Vrijednost = c(data$mbs, data$status, data$sud_id_nadlezan, data$sud_id_sluzba, data$oib, data$mb,
                       data$potpuni_mbs, data$potpuni_oib, data$ino_podruznica, data$stecajna_masa,
                       data$likvidacijska_masa, data$glavna_djelatnost, data$datum_osnivanja, data$vrijeme_zadnje_izmjene)
      )

      tvrtka <- data.frame(
        Tvrtka = data$tvrtka$ime,
        Naznaka_Ime = data$tvrtka$naznaka_imena
      )

      skracena_tvrtka <- data.frame(
        Skracena_Tvrtka = data$skracena_tvrtka$ime
      )

      sjediste <- data.frame(
        Županija = data$sjediste$naziv_zupanije,
        Općina = data$sjediste$naziv_opcine,
        Naselje = data$sjediste$naziv_naselja,
        Ulica = data$sjediste$ulica,
        Kućni_Broj = data$sjediste$kucni_broj
      )

      email_adrese <- data.frame(data$email_adrese)

      predmeti_poslovanja <- data.frame(data$predmeti_poslovanja)

      # Ažuriranje tablica
      output$opci_podaci <- renderDT({ datatable(opci_podaci) })
      output$tvrtka <- renderDT({ datatable(tvrtka) })
      output$skracena_tvrtka <- renderDT({ datatable(skracena_tvrtka) })
      output$sjediste <- renderDT({ datatable(sjediste) })
      output$email_adrese <- renderDT({ datatable(email_adrese) })
      output$predmeti_poslovanja <- renderDT({ datatable(predmeti_poslovanja) })
    }
  })
}
