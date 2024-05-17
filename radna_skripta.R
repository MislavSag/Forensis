#-------------------------------------------------------------------------------
#---------------------------# dac_hr_api funckija #-----------------------------

dac_hr_api <- function(search_term, part, history = "false", limit = 50, skip = 0) {
  response <- GET("http://dac.hr/api/v1/query",
                  query = list(
                    q = search_term,
                    history = history,  # Koristi history parametar iz UI
                    limit = limit,
                    skip = skip,
                    part = part
                  ),
                  add_headers(`X-DataApi-Key` = "59dd75a6525e"))

  # Provjera statusnog koda odgovora
  if (httr::status_code(response) != 200) {
    stop("HTTP request failed with status ", httr::status_code(response))
  }

  res <- content(response)
  if (is.null(res$hits) || length(res$hits) == 0) {
    return(data.table())  # Vraća prazan data.table ako nema rezultata
  } else {
    dt <- rbindlist(res$hits, fill = TRUE)
    return(dt)
  }
}

# u funckiju za shiny se id dodatno dijeli na inentifikatore koji služe za spajanje
# podataka sa MongoDB dokumentima

dac_dt <- dac_hr_api("62694367015", 0, history = "false")

#-------------------------------------------------------------------------------
#------------------------# Izvlačenje url-a iz MongoDB #------------------------

# ovo je prva funkcija s kojom sam izvlačio podatke iz MongoDB (MongoDB_get_doc)
# međutim, funkcija šalje pojedinačne podatke pa je zato sporija
# dodati ću dolje i bržu funkciju

# Funkcija za dohvaćanje dokumenta iz MongoDB baze
MongoDB_get_doc <- function(ids) {
  documents <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    lrUnitNumber <- parts[length(parts)]  # Zadnji element kao string
    mainBookId <- as.numeric(parts[length(parts)-1])  # Predzadnji element pretvoren u numeric

    query <- sprintf('{"lrUnitNumber": "%s", "mainBookId": %d}', lrUnitNumber, mainBookId)
    conn <- mongo(collection = collection_name, db = db_name, url = db_url)
    document <- conn$find(query)

    return(document)
  })

  return(documents)
}

source("pristupni_podaci.R")

# Primjer vektora ID-ova koji dobivaš iz pretrage
ids <- c("zk-285-50135-13132", "zk-285-31389-4128")

# Pozivanje funkcije i spremanje rezultata
documents <- MongoDB_get_doc(ids)

# Izvlačenje 'fileUrl' iz svakog dokumenta
fileUrls <- MongoDB_urls(documents)

# Prikaz svih 'fileUrl' dobivenih iz dokumenata
print(fileUrls)

#-------------------------------------------------------------------------------
#------------------------# get_doc_MongoDB funkcija #---------------------------

# ovdje stavljam funkiciju koja izvlači podatke iz MongoDB baze, ali ne pojedinačno
# nego grupno pomoću $or operatora

# Funkcija za dohvaćanje dokumenta iz MongoDB baze
get_doc_MongoDB <- function(ids) {
  conn <- mongo(collection = collection_name, db = db_name, url = db_url)

  conditions <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    lrUnitNumber <- parts[length(parts)]
    mainBookId <- as.numeric(parts[length(parts)-1])
    list(lrUnitNumber = lrUnitNumber, mainBookId = mainBookId)
  })

  query <- jsonlite::toJSON(list('$or' = conditions), auto_unbox = TRUE)
  documents <- conn$find(query)
  conn$disconnect()

  return(documents)
}

# Funkcija za izvlačenje 'fileUrl' iz dokumenta
extract_file_urls <- function(documents) {
  # Provjera postoji li stupac 'fileUrl' u data frame-u
  if ("fileUrl" %in% names(documents)) {
    # Vraća vektor URL-ova ili NA ako je URL prazan (NULL ili ne postoji)
    fileUrls <- sapply(documents$fileUrl, function(url) {
      if (!is.null(url) && nzchar(url)) {
        return(url)
      } else {
        return(NA)
      }
    })
    return(fileUrls)
  } else {
    # Vraća NA vektor ako nema stupca 'fileUrl'
    return(rep(NA, nrow(documents)))
  }
}

documents <- get_doc_MongoDB(ids)
extract_file_urls(documents)

#-------------------------------------------------------------------------------
#-----------------# Benchmark - izvlačenje podataka iz MongoDB #----------------

# Definiranje pristupnih podataka
source("pristupni_podaci.R")

ids <- c("zk-285-50135-13132", "zk-285-31389-4128")
ids_50 <- rep(ids, 50)


# Stara funkcija - pojedinačni zahtjev
get_documents_staro <- function(ids) {
  documents <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    lrUnitNumber <- parts[length(parts)]
    mainBookId <- as.numeric(parts[length(parts)-1])

    query <- sprintf('{"lrUnitNumber": "%s", "mainBookId": %d}', lrUnitNumber, mainBookId)
    conn <- mongo(collection = collection_name, db = db_name, url = db_url)
    document <- conn$find(query)
    conn$disconnect()

    return(document)
  })
  return(documents)
}

# Nova optimizirana funkcija - više zahtjeva odjednom
get_documents_novo <- function(ids) {
  conn <- mongo(collection = collection_name, db = db_name, url = db_url)

  conditions <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    lrUnitNumber <- parts[length(parts)]
    mainBookId <- as.numeric(parts[length(parts)-1])
    list(lrUnitNumber = lrUnitNumber, mainBookId = mainBookId)
  })

  query <- jsonlite::toJSON(list('$or' = conditions), auto_unbox = TRUE)
  documents <- conn$find(query)
  conn$disconnect()

  return(documents)
}

benchmark_result <- microbenchmark(
  old = get_documents_staro(ids_50),
  new = get_documents_novo(ids_50),
  times = 10  # Broj ponavljanja testa za bolju statistiku
)

print(benchmark_result)

#-------------------------------------------------------------------------------
#---------------------# Benchmark - MongoDB lappy vs DT #-----------------------

# Definiranje pristupnih podataka
source("pristupni_podaci.R")

# stara funckija koja radi uzas od strukture podataka s listama, ali je točna
get_doc_MongoDB <- function(ids) {
  conn <- mongo(collection = collection_name, db = db_name, url = db_url)
  conditions <- lapply(ids, function(id) {
    parts <- unlist(strsplit(id, split = "-"))
    list(lrUnitNumber = parts[length(parts)], mainBookId = as.numeric(parts[length(parts)-1]))
  })
  query <- jsonlite::toJSON(list('$or' = conditions), auto_unbox = TRUE)
  # selektiraju se samo relevantne varijable - po potrebi promijeniti
  documents <- conn$find(query, fields = '{"institutionId" : true, "lrUnitNumber" : true,
                       "mainBookId" : true, "fileUrl" : true}')
  conn$disconnect()
  return(documents)
}


# Nova funkcija koja koristi tstrsplit i datatable umjesto lapply
get_doc_MongoDB_2 <- function(ids) {
  # DEBUG
  # ids <- c("zk-285-50135-13132", "zk-285-31389-4128")
  # ids <- rep(ids, 10)

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

ids <- c("zk-285-50135-13132", "zk-285-31389-4128")
ids_50 <- rep(ids, 300)

# Usporedba vremena izvršavanja
benchmark_result <- microbenchmark(
  old = get_doc_MongoDB(ids_50),
  new = get_doc_MongoDB_2(ids_50),
  times = 20  # Broj ponavljanja testa za bolju statistiku
)

# Ispis rezultata
print(benchmark_result)

# ZAKLJUČAK: nova funkcija je minimalno brža, ali lijepša u kodu pa nastavljam s njom
# na serveru. Ime funckije ostaje get_doc_MongoDB


# STARA FUNKCIJA JE UKLJUČIVALA I OVO:
# Priprema podataka za spajanje
prepare_mongo_documents <- function(mongo_documents) {
  mongo_documents$lrUnitNumber <- sapply(mongo_documents$lrUnitNumber, function(x) as.character(unlist(x)))
  mongo_documents$mainBookId <- sapply(mongo_documents$mainBookId, function(x) as.character(unlist(x)))
  mongo_documents$institutionId <- sapply(mongo_documents$institutionId, function(x) as.character(unlist(x)))
  return(mongo_documents)
}

# Funkcija za spajanje podataka
spoji_podatke <- function(api_data, mongo_data) {
  mongo_data <- prepare_mongo_documents(mongo_data)
  spojena_tablica <- merge(api_data, mongo_data, by = c("institutionId", "mainBookId", "lrUnitNumber"), all.x = TRUE)
  return(spojena_tablica)
}

#-------------------------------------------------------------------------------
#---------------------------------# indexes #-----------------------------------

# Ponovno povezivanje ako je konekcija zatvorena
conn <- mongo(collection = collection_name, db = db_name, url = db_url)

# Listanje indeksa
indexes <- conn$index()

# Ja sam kreirao indekse direktno na webu, ali se moze i iz R-a:
# conn$index(add = '{"lrUnitNumber": 1}')
# GPT kaze da MongoDB automatski koristi indekse. Nažalost, provjeru ne mogu
# napraviti iz R-a. Potrebno je preko compassa napraviti query i napraviti analizu
# brzine i optimalnosti koda

# Zatvaranje konekcije
conn$disconnect()

#-------------------------------------------------------------------------------
#-------------------------------# Testiranje Servera #--------------------------

# TESTIRANJE FUNKCIJA U SERVERU
api_data <- dac_hr_api("47432874968", 0, "true") # 62694367015

ids <- c(api_data$id)

mongo_data <- get_doc_MongoDB(ids)

final_data <- spoji_podatke(api_data, mongo_data)

# Ažuriranje URL-a
base_url <- "https://oss.uredjenazemlja.hr/oss/public/reports/ldb-extract/"
final_data[, fileUrl := ifelse(is.na(fileUrl), NA_character_, paste0(base_url, fileUrl))]

# Odabir potrebnih varijabli
final_data <- final_data[, .(id, type, unit, institution, book, status, burden, fileUrl)]

#-------------------------------------------------------------------------------



# TEST ATLAS SEARCH -------------------------------------------------------
# Replace with your actual connection details
conn <- mongo(collection = collection_name, db = db_name, url = db_url)

# FIELDS_NAME_Q = [
#   "ownershipSheetB.lrUnitShares.lrOwners.name",
#   "ownershipSheetB.lrUnitShares.lrOwners.taxNumber",
#   "ownershipSheetB.lrUnitShares.subSharesAndEntries.lrOwners.name"
# ]

# Define the search query using the aggregation pipeline
desired_lrUnitNumber_value <- 1202 # Replace with the actual integer value you are searching for
desired_mainBookId_value <- "21148" # Replace with the actual string value you are searching for

query <- sprintf('[
  {
    "$search": {
      "index": "ids",
      "compound": {
        "should": [
          {
            "equals": {
              "value": %d,
              "path": "lrUnitNumber"
            }
          },
          {
            "text": {
              "query": "%s",
              "path": "mainBookId"
            }
          }
        ]
      }
    }
  }
]', desired_lrUnitNumber_value, desired_mainBookId_value)
# Execute the search query
results <- conn$aggregate(pipeline = query)

# Print the search results
print(results)





