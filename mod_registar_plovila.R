# mod_pojedinacna_pretraga.R

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
             textInput(ns("search_term"), "Unesite pojam", width = "100%"),
             br(),
             actionButton(ns("search_button"), "Pretraži"),
             br(),
             br(),
             style = "text-align: center;"
      )
    ),
    fluidRow(
      column(12,
             div(class = "table-container",
                 uiOutput(ns("rezultati_tab"))
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

# mod_pojedinacna_pretraga.R

MS_registar_plovila <- function(input, output, session,
                                    vlasnici_plovila,
                                    korisnici_plovila,
                                    opci_podaci,
                                    porivni_uredaji,
                                    tenicki_pregled,
                                    prethodni_upis,
                                    db_name = Sys.getenv("db_name"),
                                    db_url = Sys.getenv("db_url")) {

  pretraga_rezultati <- eventReactive(input$search_button, {
    req(input$search_term)
    search_term <- input$search_term
    words <- unlist(strsplit(search_term, "\\s+"))

    if (length(words) == 1) {
      pipeline <- sprintf('[
        {
          "$search": {
            "index": "plovila_vlasnik",
            "text": {
              "query": "%s",
              "path": [
                "KorisnikNaziv",
                "BrodicaDetaljno.VlasniciPlovila.Naziv"
              ]
            }
          }
        },
        { "$project": { "_id": 1 } }
      ]', search_term)
    } else {
      must_queries <- sapply(words, function(word) {
        sprintf('{ "text": { "query": "%s", "path": ["KorisnikNaziv", "BrodicaDetaljno.VlasniciPlovila.Naziv"] } }', word)
      })
      must_clause <- paste(must_queries, collapse = ", ")
      pipeline <- sprintf('[
        {
          "$search": {
            "index": "plovila_vlasnik",
            "compound": {
              "must": [ %s ]
            }
          }
        },
        { "$project": { "_id": 1 } }
      ]', must_clause)
    }

    conn <- mongolite::mongo(collection = "plovila", db = db_name, url = db_url)
    result <- conn$aggregate(pipeline)
    conn$disconnect()

    ids <- as.character(result[["_id"]])
    ids <- unique(ids)

    # Agregacija s data.table:
    df_vlasnici <- vlasnici_plovila[`_id` %chin% ids]

    df_vlasnici_single <- df_vlasnici[broj_vlasnika == 1, .(
      `_id`,
      Vlasnik = Naziv,
      broj_vlasnika,
      TipSubjekta,
      VrstaOgranicenja,
      Naselje,
      Drzava
    )]

    df_vlasnici_multiple <- df_vlasnici[broj_vlasnika > 1, .(
      Vlasnik = paste(Naziv, collapse = "; ")
    ), by = .(`_id`, broj_vlasnika)]
    df_vlasnici_multiple[, `:=`(
      TipSubjekta = NA_character_,
      VrstaOgranicenja = NA_character_,
      Naselje = NA_character_,
      Drzava = NA_character_
    )]

    df_vlasnici_final <- data.table::rbindlist(list(df_vlasnici_single, df_vlasnici_multiple), use.names = TRUE, fill = TRUE)
    df_vlasnici_detailed <- df_vlasnici[broj_vlasnika > 1, .(
      `_id`,
      Vlasnik = Naziv,
      TipSubjekta,
      VrstaOgranicenja,
      Naselje,
      Drzava,
      broj_vlasnika
    )]

    df_korisnici <- korisnici_plovila[`_id` %chin% ids]
    df_korisnici_single <- df_korisnici[broj_korisnika == 1, .(`_id`, Korisnik, TipKorisnika, broj_korisnika)]
    df_korisnici_multiple <- df_korisnici[broj_korisnika > 1, .(
      Korisnik = paste(Korisnik, collapse = "; "),
      TipKorisnika = paste(unique(TipKorisnika), collapse = "; ")
    ), by = .(`_id`, broj_korisnika)]
    df_korisnici_final <- data.table::rbindlist(list(df_korisnici_single, df_korisnici_multiple), use.names = TRUE, fill = TRUE)
    df_korisnici_detailed <- df_korisnici[broj_korisnika > 1, .(`_id`, Korisnik, TipKorisnika, broj_korisnika)]

    df_opci <- opci_podaci[`_id` %chin% ids]
    df_opci[, c("ENI", "KategorijaStarosti", "MaterijalKategorija") := NULL]

    df_porivni <- porivni_uredaji[`_id` %chin% ids]
    df_porivni[, c("KategorijaMotora", "SnagaKategorija") := NULL]

    df_tenicki <- tenicki_pregled[`_id` %chin% ids]
    df_prethodni <- prethodni_upis[`_id` %chin% ids]

    # Full joinovi – koristimo merge s all=TRUE
    df_temp <- merge(df_vlasnici_final, df_korisnici_final, by = "_id", all = TRUE)
    df_temp2 <- merge(df_temp, df_opci, by = "_id", all = TRUE)
    df_temp3 <- merge(df_temp2, df_porivni, by = "_id", all = TRUE)
    df_temp4 <- merge(df_temp3, df_tenicki, by = "_id", all = TRUE)
    df_final <- merge(df_temp4, df_prethodni, by = "_id", all = TRUE)

    return(list(
      aggregated = df_final,
      detailed_vlasnici = df_vlasnici_detailed,
      detailed_korisnici = df_korisnici_detailed
    ))
  })

  output$rezultati_tab <- renderUI({
    res <- pretraga_rezultati()
    if (is.null(res$aggregated) || nrow(res$aggregated) == 0) {
      HTML("<p style='font-size: 20px; color: red; font-weight: bold;'>Nema rezultata pretrage</p>")
    } else {
      tagList(
        h3("Agregirana tablica plovila"),
        p("Ovdje se prikazuju svi podaci. Tablicu je potrebno preuzeti u excel.
          Napomena: ako za određeno plovilo postoji više od jednog vlasnika ili više od jednog
          korisnika plovila, detaljni podaci o vlasnicima i korisnicima biti će prikazati u tablicama ispod.
          Korisnik aplikacije onda može preuzeti i dodatne tablice, pa po ID stupcu iz prve tablice,
          istražiti dodatne informacije."),
        DT::DTOutput(session$ns("results_table")),
        br(),
        if (!is.null(res$detailed_vlasnici) && nrow(res$detailed_vlasnici) > 0) {
          tagList(
            h3("Vlasnici plovila detaljno"),
            p("Detaljni podaci o vlasnicima plovila (long format)."),
            DT::DTOutput(session$ns("detailed_vlasnici_table"))
          )
        },
        br(),
        if (!is.null(res$detailed_korisnici) && nrow(res$detailed_korisnici) > 0) {
          tagList(
            h3("Korisnici plovila detaljno"),
            p("Detaljni podaci o korisnicima plovila (long format)."),
            DT::DTOutput(session$ns("detailed_korisnici_table"))
          )
        }
      )
    }
  })

  output$results_table <- DT::renderDataTable({
    res <- pretraga_rezultati()
    if (!is.null(res$aggregated) && nrow(res$aggregated) > 0) {
      DT_template_plovila1(res$aggregated, caption = "Agregirana tablica plovila", filename_prefix = "Plovila_")
    }
  }, server = FALSE)

  output$detailed_vlasnici_table <- DT::renderDataTable({
    res <- pretraga_rezultati()
    if (!is.null(res$detailed_vlasnici) && nrow(res$detailed_vlasnici) > 0) {
      DT_template_plovila2(res$detailed_vlasnici, caption = "Detaljni podaci o vlasnicima plovila", filename_prefix = "Plovila_")
    }
  }, server = FALSE)

  output$detailed_korisnici_table <- DT::renderDataTable({
    res <- pretraga_rezultati()
    if (!is.null(res$detailed_korisnici) && nrow(res$detailed_korisnici) > 0) {
      DT_template_plovila2(res$detailed_korisnici, caption = "Detaljni podaci o korisnicima plovila", filename_prefix = "Plovila_")
    }
  }, server = FALSE)
}


