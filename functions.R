# Učitajte varijable okruženja
db_url <- Sys.getenv("db_url")
db_name <- Sys.getenv("db_name")
collection_name <- Sys.getenv("collection_name")

sudreg_api_user <- Sys.getenv("SUDREG_API_USER") # sudski registar
sudreg_api_pass <- Sys.getenv("SUDREG_API_PASS") # sudski registar

mysql_host <- Sys.getenv("MYSQL_HOST")
mysql_port <- as.integer(Sys.getenv("MYSQL_PORT"))
mysql_user <- Sys.getenv("MYSQL_USER")
mysql_password <- Sys.getenv("MYSQL_PASSWORD")

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Funkcija za DATA API
dataApi <- function(oib, url, query = NULL){
  req = RETRY(
    "GET",
    url = paste0('http://api.data-api.io/v1/', url, '/'),
    add_headers('x-dataapi-key' = "59dd75a6525e"),
    query = c(list(oib = oib), query),
    timeout(180),
    times = 6
  )
  req <- httr::content(req, type = 'text', encoding = 'utf-8')
  api_df <- jsonlite::fromJSON(req)
  return(api_df)
}

# Funkcija za dohvaćanje podataka iz API-ja zemljišne knjige
zkrh <- function(search_term, part, history = "false", limit = 200, skip = 0) {
  response <- GET("http://dac.hr/api/v1/query",
                  query = list(
                    q = search_term,
                    history = history,
                    limit = limit,
                    skip = skip,
                    part = part
                  ),
                  add_headers(`X-DataApi-Key` = "59dd75a6525e"))

  if (httr::status_code(response) != 200) {
    stop("HTTP request failed with status ", httr::status_code(response))
  }

  res <- content(response)
  if (is.null(res$hits) || length(res$hits) == 0) {
    return(data.table())
  } else {
    dt <- rbindlist(res$hits, fill = TRUE)

    # Dodaj identifikatore - bitno za spajanje sa MongoDB
    dt$id_parts <- strsplit(dt$id, "-")
    dt$institutionId <- sapply(dt$id_parts, function(x) x[2])
    dt$mainBookId <- sapply(dt$id_parts, function(x) x[3])
    dt$lrUnitNumber <- sapply(dt$id_parts, function(x) x[4])

    return(dt)
  }
}
# x = zkrh("93335620125", "0", "true", 200, 0)

# funkcija sa dohvaćanje dokumenata iz MongoDB baze
# koristi se atlas search (22.05.) koji je znatno skratio vrijeme dohvate docc
mongoDB <- function(ids, collection, db, url) {
  conn <- mongo(collection = collection_name, db = db_name, url = db_url)

  conditions <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    lrUnitNumber <- parts[length(parts)]
    mainBookId <- as.numeric(parts[length(parts)-1])
    list(
      'compound' = list(
        'must' = list(
          list(
            'text' = list(
              'query' = lrUnitNumber,
              'path' = 'lrUnitNumber'
            )
          ),
          list(
            'equals' = list(
              'path' = 'mainBookId',
              'value' = mainBookId
            )
          )
        )
      )
    )
  })

  combined_conditions <- list(
    'should' = conditions
  )

  search_query <- list(
    list(
      '$search' = list(
        'index' = 'ids',
        'compound' = combined_conditions
      )
    ),
    list(
      '$project' = list(
        'institutionId' = 1,
        'lrUnitNumber' = 1,
        'mainBookId' = 1,
        'fileUrl' = 1
      )
    )
  )

  search_query_json <- toJSON(search_query, auto_unbox = TRUE)

  documents <- conn$aggregate(pipeline = search_query_json)

  conn$disconnect()

  return(documents)
}

# Funkcija za spajanje podataka bez prepare_mongo_documents
spoji_podatke <- function(api_data, mongo_data) {
  # data.table format
  mongo_data <- as.data.table(mongo_data)

  # Convert to chr type
  mongo_data[, lrUnitNumber := as.character(lrUnitNumber)]
  mongo_data[, mainBookId := as.character(mainBookId)]
  mongo_data[, institutionId := as.character(institutionId)]

  # merge
  spojena_tablica <- merge(api_data, mongo_data, by = c("institutionId", "mainBookId", "lrUnitNumber"), all.x = TRUE)

  return(spojena_tablica)
}

# Ovo je za Zemljišne knjige RS
zkrs <- function(table = "zk_rs_vlasnici", naziv) {
  # Povezivanje na bazu podataka koristeći definirane varijable
  db <- dbConnect(MySQL(), dbname = 'odvjet12_zk', host = mysql_host,
                  port = mysql_port, user = mysql_user, password = mysql_password)

  # Priprema query-ja
  zk_input <- paste0("+", stringr::str_split(enc2utf8(naziv), pattern = " ")[[1]], collapse = " ")
  query <- paste0("SELECT *, MATCH(vlasnik) AGAINST('", enc2utf8(zk_input), "' IN BOOLEAN MODE) AS score ",
                  "FROM ", table, " ",
                  "WHERE MATCH(vlasnik) AGAINST('", enc2utf8(zk_input),  "' IN BOOLEAN MODE) ",
                  "ORDER BY score DESC ",
                  "LIMIT 250;")

  # Izvršavanje query-ja i postavljanje karakter seta
  rs <- dbSendQuery(db, 'set character set "utf8"')
  rs <- dbSendQuery(db, 'SET NAMES utf8')
  data <- dbGetQuery(db, query)
  dbDisconnect(db)

  # Alternativa za map_dfr iz purrr paketa za UTF-8 encoding
  data <- as.data.frame(lapply(data, function(x) {
    if (is.character(x)) {
      Encoding(x) <- "UTF-8"
    }
    x
  }))

  return(data)
}

# ovo je DT template koji se koristi za RS i Federaciju (skraćeno BIH) i za plovila
# dodaje se argument za uređivanje imena - to se mijenja u modulima
DT_template_ZKBIH_plovila <- function(df, filename_prefix = "rezultati", fixedHeader = TRUE) {
  datatable(
    df,
    rownames = FALSE,
    extensions = c('Buttons', 'FixedHeader'),
    options = list(
      dom = 'Blfrtip',
      pageLength = 10,  # Prikazivanje 10 unosa po stranici
      autoWidth = TRUE,  # Automatsko podešavanje širine stupaca
      ordering = TRUE,   # Omogućava sortiranje tablice
      scrollX = TRUE,    # Omogućava horizontalno skrolanje
      scrollY = '500px', # Omogućava vertikalno skrolanje unutar visine od 500px
      fixedHeader = fixedHeader, # Zaglavlje će ostati vidljivo prilikom vertikalnog skrolanja
      buttons = list(
        'copy',
        list(extend = 'csv', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y")),
             bom = TRUE, charset = 'utf-8'),  # CSV
        list(extend = 'excel', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y")),
             bom = TRUE, charset = 'utf-8'),  # Excel
        list(extend = 'pdf', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y"))),  # PDF
        list(extend = 'print', title = ''),  # Print
        'colvis'  # Gumb za kontrolu vidljivosti stupaca
      ),
      lengthMenu = list(c(5, 10, 25, 50, -1), c('5', '10', '25', '50', 'All'))
    )
  )
}

# ovo je DT funkcija za zemljišne knjige RH
# posebno se definira export csv i excel-a zbog linka u zadnjem stupcu
DT_template_ZKRH <- function(df, fixedHeader = TRUE) {
  library(DT)

  # Zero-based index of the 'Link' column
  link_col_index <- which(names(df) == "Link") - 1  # R koristi indeksiranje od 1, JavaScript od 0

  # Definiramo zajedničke JavaScript funkcije
  filename_js <- JS("function() { var date = new Date(); var day = ('0' + date.getDate()).slice(-2); var month = ('0' + (date.getMonth() + 1)).slice(-2); var year = date.getFullYear(); return 'ZKRH_' + day + '-' + month + '-' + year; }")
  body_js <- JS(paste0("function(data, row, column, node) { var idx = column; if(idx === ", link_col_index, ") { var link = $('<div>' + data + '</div>').find('a').attr('href'); return link ? link : data; } else { return data; } }"))

  datatable(
    df,
    rownames = FALSE,
    escape = FALSE,
    extensions = c('Buttons', 'FixedHeader'),
    options = list(
      dom = 'Blfrtip',
      pageLength = 10,  # Broj prikazanih rezultata na 10
      scrollY = '500px',  # Omogućava vertikalno skrolanje unutar visine od 500px
      fixedHeader = fixedHeader,  # Fiksira zaglavlje tablice prilikom skrolanja
      columnDefs = list(
        list(
          targets = link_col_index,
          render = JS("function(data, type, row, meta) { if(type === 'display'){ return '<a href=\"' + data + '\" target=\"_blank\">Open</a>'; } else { return data; } }")
        )
      ),
      buttons = list(
        list(extend = 'copy', filename = filename_js, exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'csv', filename = filename_js, bom = TRUE, charset = 'utf-8', exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'excel', filename = filename_js, bom = TRUE, charset = 'utf-8', exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'pdf', filename = filename_js, exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'print', filename = filename_js, title = '', exportOptions = list(columns = ':visible', format = list(body = body_js)))
      ),
      lengthMenu = list(c(10, 25, 50, -1), c('10', '25', '50', 'All'))
    )
  )
}


# Funkcija za povlacenje podataka o plovilima
loadData_plovila <- function(naziv) {
  db <- dbConnect(MySQL(), dbname = 'odvjet12_plovila', host = mysql_host,
                  port = mysql_port, user = mysql_user, password = mysql_password)

  query <- paste0("SELECT * FROM plovila_all WHERE vlasnik LIKE '%", enc2utf8(naziv), "%'")

  rs <- dbSendQuery(db, 'set character set "utf8"')
  rs <- dbSendQuery(db, 'SET NAMES utf8')
  data <- dbGetQuery(db, query)
  dbDisconnect(db)

  data <- as.data.frame(lapply(data, function(x) {
    if (is.character(x)) {
      Encoding(x) <- "UTF-8"
    }
    x
  }))

  return(data)
}

# Provjera oib-a
oib_checker <- function(oib_vector){
  ostatak <- rep(0, 10)
  for (i in 1:10){
    iso <- as.integer(substr(oib_vector, i, i)) + 10 + ifelse(i > 1, ostatak[i-1], 0)
    iso <- ifelse((iso %% 10) == 0, 10, iso %% 10)
    iso <- iso * 2
    ostatak[i] <- iso %% 11
  }
  kontrolna <- ifelse((11 %% ostatak[10]) == 0, 0, 11 - ostatak[10])
  oib_chech <- ifelse(kontrolna == as.integer(substr(oib_vector, 11, 11)), 1, 0)
  return(oib_chech)
}

# Ovo je za dohvat podataka o fizičkim osobama
loadDataFiz <- function(oibreqFiz) {
  db <- dbConnect(MySQL(), dbname = "odvjet12_fizicke", host = mysql_host,
                  port = mysql_port, user = mysql_user, password = mysql_password)

  query <- sprintf("SELECT * FROM %s WHERE oib = '%s'", "fizicke_osobe", oibreqFiz)

  rs <- dbSendQuery(db, 'set character set "utf8"')
  rs <- dbSendQuery(db, 'SET NAMES utf8')
  data <- dbGetQuery(db, query)
  dbDisconnect(db)

  return(data)
}

# Povlaćenje podataka sa zdravstvenog - koristit će se u forensis dokument
zdravstveno <- function(oib) {
  osig <- dataApi(oib, "hzzostatus")
  osig <- lapply(osig, function(x) if (is.null(x)) {x <- NA} else {x <- x})
  osig <- as.data.frame(osig)
  return(osig)
}

# Pretraga poslovnih funkcija u poslovnim subjektima
poslovne_funkcije <- function(oib) {
  data <- dataApi(oib, "osobe")
  if (length(data) > 0 && oib %in% data$osobaOib) {
    data <- data[data$osobaOib == oib, ]
    povezani_subjekti <- data$povezaniSubjekti
    data$povezaniSubjekti <- NULL
    data <- data[!duplicated(data),]
    oibreq_subjekti <- unique(data$subjektOib)
    if (is.null(oibreq_subjekti)) {
      return(data.frame())
    } else {
      req <- list()
      for (i in 1:length(oibreq_subjekti)) {
        req[[i]] <- dataApi(oibreq_subjekti[i], "subjekti")
      }
      subjekti <- as.data.frame(do.call(base::rbind, req))
      subjekti$isActive <- NULL
      colnames(subjekti)[which(colnames(subjekti) == "adresa")] <- "adresa_subjekta"
      if (length(subjekti) > 0) {
        funkcije_all <- merge(x = data, y = subjekti, by.x = "subjektOib", by.y = "oib", all.x = TRUE, all.y=FALSE)
        funkcije_data <- funkcije_all[,c("naziv", "funkcija", "isActive")]
      } else {
        funkcije_data <- cbind.data.frame(naziv = NA, data[,c("funkcija", "isActive")])
      }
      # za tablicu
      colnames(funkcije_data) <- c("Naziv subjekta", "Funkcija", "Aktivnost funkcije")
      return(funkcije_data)
    }
  } else {
    return(data.frame())
  }
}

# Funkcija za dohvaćanje podataka o pravnim osobama iz API-ja
pravne_osobe_API <- function(oib) {
  # Funkcija za dohvaćanje tokena
  dohvati_token <- function() {
    response <- POST("https://sudreg-data.gov.hr/api/oauth/token",
                     authenticate(Sys.getenv("sudreg_api_user"), Sys.getenv("sudreg_api_pass")),
                     body = list(grant_type = "client_credentials"),
                     encode = "form")

    if (status_code(response) == 200) {
      token_data <- content(response, "parsed", simplifyVector = TRUE)
      return(token_data$access_token)
    } else {
      stop("Greška: Status kod ", status_code(response))
    }
  }

  # Dohvaćanje tokena
  access_token <- dohvati_token()

  # Definiranje URL-a za endpoint "/detalji_subjekta"
  base_url <- "https://sudreg-data.gov.hr/api/javni"
  endpoint <- "/detalji_subjekta"
  url <- paste0(base_url, endpoint, "?tip_identifikatora=oib&identifikator=", oib, "&expand_relations=true")

  # Slanje GET zahtjeva na API s autentifikacijom
  response <- GET(url, add_headers(Authorization = paste("Bearer", access_token)))

  if (status_code(response) == 200) {
    # Parsiranje JSON odgovora
    data <- content(response, "parsed", simplifyVector = TRUE)
    return(data)
  } else {
    stop("Greška: Status kod ", status_code(response))
  }
}

# Funkcija za prikaz podataka pravne_osobe_API
prikazi_podatke_pravne_osobe <- function(data) {
  if (!is.null(data)) {
    # Definicija funkcije za sigurno dohvaćanje vrijednosti
    sigurno_dohvati <- function(data, keys) { tryCatch({ val <- data; for (key in keys) { if (is.null(val[[key]])) return(NA); val <- val[[key]] }; return(val) }, error = function(e) { NA }) }

    # Extracting 'naziv' from sud_nadlezan and sud_sluzba
    sud_nadlezan_naziv <- sigurno_dohvati(data, c("sud_nadlezan", "naziv"))
    sud_sluzba_naziv <- sigurno_dohvati(data, c("sud_sluzba", "naziv"))

    # Extracting 'znacenje' from postupak
    postupak_znacenje <- sigurno_dohvati(data, c("postupak", "postupak", "znacenje"))

    # Extracting 'naziv' and 'kratica' from pravni_oblik
    pravni_oblik_naziv <- sigurno_dohvati(data, c("pravni_oblik", "vrsta_pravnog_oblika", "naziv"))
    pravni_oblik_kratica <- sigurno_dohvati(data, c("pravni_oblik", "vrsta_pravnog_oblika", "kratica"))

    # Existing fields
    mbs <- if (!is.null(data$mbs)) data$mbs else NA; status <- if (!is.null(data$status)) data$status else NA; oib <- if (!is.null(data$oib)) data$oib else NA; mb <- if (!is.null(data$mb)) data$mb else NA
    potpuni_mbs <- if (!is.null(data$potpuni_mbs)) data$potpuni_mbs else NA; potpuni_oib <- if (!is.null(data$potpuni_oib)) data$potpuni_oib else NA; ino_podruznica <- if (!is.null(data$ino_podruznica)) data$ino_podruznica else NA
    stecajna_masa <- if (!is.null(data$stecajna_masa)) data$stecajna_masa else NA; likvidacijska_masa <- if (!is.null(data$likvidacijska_masa)) data$likvidacijska_masa else NA; glavna_djelatnost <- if (!is.null(data$glavna_djelatnost)) data$glavna_djelatnost else NA
    datum_osnivanja <- if (!is.null(data$datum_osnivanja)) data$datum_osnivanja else NA; vrijeme_zadnje_izmjene <- if (!is.null(data$vrijeme_zadnje_izmjene)) data$vrijeme_zadnje_izmjene else NA

    # Extracting valuta naziv from temeljni_kapitali
    temeljni_kapital_iznos <- sigurno_dohvati(data, c("temeljni_kapitali", "iznos"))
    temeljni_kapital_valuta_naziv <- sigurno_dohvati(data, c("temeljni_kapitali", "valuta", "naziv"))
    temeljni_kapitali <- data.frame(Iznos = temeljni_kapital_iznos, Valuta = temeljni_kapital_valuta_naziv)

    # Handling GFI, extracting 'znacenje' from 'vrsta_dokumenta' if exists
    gfi <- data[["gfi"]]; if (!is.null(gfi) && "znacenje" %in% colnames(gfi$vrsta_dokumenta)) { gfi$vrsta_dokumenta <- gfi$vrsta_dokumenta$znacenje }

    # Updating the DataFrame
    opci_podaci <- data.frame(
      Ključ = c("MBS", "Status", "Sud Nadležan", "Sud Služba", "OIB", "MB", "Potpuni MBS",
                "Potpuni OIB", "Ino Podružnica", "Stečajna Masa", "Likvidacijska Masa",
                "Glavna Djelatnost", "Postupak", "Pravni Oblik", "Kratica", "Datum Osnivanja", "Vrijeme Zadnje Izmjene"),
      Vrijednost = c(mbs, status, sud_nadlezan_naziv, sud_sluzba_naziv, oib, mb,
                     potpuni_mbs, potpuni_oib, ino_podruznica, stecajna_masa,
                     likvidacijska_masa, glavna_djelatnost, postupak_znacenje, pravni_oblik_naziv, pravni_oblik_kratica, datum_osnivanja, vrijeme_zadnje_izmjene)
    )

    # Spremanje kombiniranih podataka za tvrtku i skraćenu tvrtku
    tvrtka <- data.frame(Tvrtka = data$tvrtka$ime, Skracena_Tvrtka = data$skracena_tvrtka$ime)

    sjediste <- as.data.frame(data[["sjediste"]])
    email_adrese <- as.data.frame(data[["email_adrese"]])
    predmeti_poslovanja <- as.data.frame(data[["predmeti_poslovanja"]])
    promjene <- as.data.frame(data[["promjene"]])

    # Returning the list of tables
    list(
      opci_podaci = opci_podaci,
      tvrtka = tvrtka,
      sjediste = sjediste,
      email_adrese = email_adrese,
      predmeti_poslovanja = predmeti_poslovanja,
      temeljni_kapitali = temeljni_kapitali,
      gfi = gfi,
      promjene = promjene
      )
  } else {
    NULL
  }
}

