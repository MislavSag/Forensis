db_url <- Sys.getenv("db_url")
db_name <- Sys.getenv("db_name")
collection_name <- Sys.getenv("collection_name")


# Funkcija za dohvaćanje podataka iz API-ja
zkrh <- function(search_term, part, history = "false", limit = 50, skip = 0) {
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

# Funkcija za dohvaćanje dokumenata iz MongoDB baze
get_doc_MongoDB <- function(ids) {
  # Povezivanje na MongoDB
  conn <- mongo(collection = collection_name, db = db_name, url = db_url)

  # Razdvajanje ID-ova na dijelove
  id_parts <- tstrsplit(ids, "-", fixed = TRUE)
  conditions <- data.table(
    lrUnitNumber = id_parts[[4]],
    mainBookId = as.numeric(id_parts[[3]])
  )

  # Konverzija uvjeta u listu imenovanih listi
  conditions_list <- lapply(1:nrow(conditions), function(i) {
    list(lrUnitNumber = conditions$lrUnitNumber[i], mainBookId = conditions$mainBookId[i])
  })

  # Konverzija u JSON format
  query <- jsonlite::toJSON(list('$or' = conditions_list), auto_unbox = TRUE)

  # Pokretanje upita
  documents <- conn$find(query, fields = '{"institutionId" : true, "lrUnitNumber" : true,
                                          "mainBookId" : true, "fileUrl" : true}')
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
