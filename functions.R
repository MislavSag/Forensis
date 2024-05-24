# Funkcija za dohvaćanje podataka iz API-ja
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

# funkcija sa dohvaćanje dokumenata iz MongoDB baze
# koristi se atlas search (22.05.) koji je znatno skratio vrijeme dohvate docc
mongoDB <- function(ids) {
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
