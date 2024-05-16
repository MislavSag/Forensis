

Sys.getenv("TOKEN")
Sys.getenv("IME")


api_key <- Sys.getenv("TOKEN")
print(api_key)

# DATA API ----------------------------------------------------------------
# Search ZK
zk_l = lapply(terms, function(x) {
  p = GET("http://dac.hr/api/v1/query",
          query = list(
            q = x,
            history = "false",
            part = 2, # 1 SVe , 2 B
            limit = 100,
            skip = 0
          ),
          add_headers(`X-DataApi-Key` = api_key))
  res = content(p)
  res = rbindlist(res$hits)
  as.data.table(cbind.data.frame(term = x, res))
})
lapply(zk_l, function(x) nrow(x))
lapply(zk_l, function(x) nrow(x[type == "zk"]))
zkdt = rbindlist(zk_l)
zkdt_unique = unique(zkdt[, .SD, .SDcols = -"term"])


#-------------------------------------------------------------------------------

# Osnovni URL API-ja
url <- "http://dac.hr/api/v1/query"

# Postavljanje headera zahtjeva
headers <- add_headers(`X-DataApi-Key` = "59dd75a6525e")

# Definiranje pojmova za pretragu
pojmovi <- c("INA d.d.", "Ina - industrija nafte d.d.", "27759560625")

# Možda korisni drugi pojmovi ? - asocijacije s Info.Biz
# (1) adresa: "Avenija Većeslava Holjevca 10, 10000 Zagreb"
# (2) matični broj: "03586243"
# (3) djelatnost: "1920 - Proizvodnja rafiniranih naftnih proizvoda"

# Prazni data.table za spremanje rezultata
rezultati_dt <- data.table()

# Petlja za iteraciju kroz svaki pojam i izvršavanje API zahtjeva
for (pojam in pojmovi) {
  # Postavljanje parametara zahtjeva za svaki pojam
  params <- list(
    q = pojam,
    history = "true",
    limit = 1000,
    skip = 0
  )

  # Slanje GET zahtjeva
  response <- GET(url, query = params, headers)

  # Dohvaćanje sirovog sadržaja odgovora
  res_raw <- content(response, "text")

  # Dekodiranje JSON sadržaja u listu
  # ovo mi je napravio chat GPT i ima više smisla nego direktno res <- content(response)
  res <- fromJSON(res_raw)

  # Ako res$hits ne postoji, preskoči ovu iteraciju
  if (is.null(res$hits) || length(res$hits) == 0) next

  # Pretvaranje dobivenih podataka u data.table
  dt <- rbindlist(list(res$hits), fill = TRUE)

  # Ako nema imena, preskoči daljnje obrade
  if (is.null(colnames(dt))) next

  # Dodavanje kolone 'pojam' s trenutnim pojmom pretrage
  dt[, pojam := pojam]

  # Spremanje rezultata u glavni data.table
  rezultati_dt <- rbindlist(list(rezultati_dt, dt), fill = TRUE)
}

# Eksportiranje finalnih rezultata u CSV datoteku
fwrite(rezultati_dt, "INA_podaci.csv")
# Eksportiranje finalnih rezultata u Excel datoteku
write.xlsx(rezultati_dt, "INA_podaci.xlsx")


# Ovo je kratki kod da maknem dupliće (meni najlakše preko tidyverse, ali mogu napisati u data.table)
rezultati_unique <- rezultati_dt %>%
  select(!pojam) %>%
  unique()










