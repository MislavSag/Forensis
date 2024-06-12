# Functions skripta

-   updateData i sel funkcije - kada se koriste ?

# Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

# Pitanja

-pretražuju li se plovila preko oib-a ?
-   oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)

# TODO

## Forensic report

- gumb "Preuzmi dokument" se pojavljuje nakon generiranje dokumenta. Moze biti zelene boje
- povećao bi height of iframe-a da se vidi veći dio dokumenta
- dodati  shiny loadere, da korisnik zna da se nešto događa kada klikne preuzmi izvještaj. Postoji primjer u mom kodu. Iako od onda vjerojatno postoji još novih paketa. Na primjer brzo guglanje: https://github.com/daattali/shinycssloaders
- dodati html text input ime i prezime koji je opcionalan. Ako se upiše ime i prezime, ono se koristi u pretrazi RS, Federacije, plovila i eventualnih drugi pretraga. Ako se ime i prezime ostavi prazno, povlači se ime i prezime iz nađe baze. Primer povlačenja imena i prezimena iz naše baze dostupan je u mom koduČ

```
loadDataFiz <- function(oibreqFiz) {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = "odvjet12_fizicke", host = options()$mysql$host, 
                  port = as.integer(options()$mysql$port), user = options()$mysql$user, 
                  password = options()$mysql$password)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s WHERE oib = '%s'", table_load, oibreqFiz)
  # Submit the fetch query and disconnect
  rs <- dbSendQuery(db, 'set character set "utf8"')
  rs <- dbSendQuery(db, 'SET NAMES utf8')
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

```

- nekretnine bi se trebale pretraživati po OIB-u i imenu i prezimenu (dvije pretrage). Postoji još jedna malo složenija pretraga koju bi dodao, ali to možemo u drugoj fazi.
- implementirati pretagu sudskog registra - provjera pravnih funkcija u poslovnim subjektima. Primjer je u mom kodu:

```
  funkcije <- reactive({
    withProgress(message = 'Provjera zemljišnih knjiga',{
      funkcije <- dataApi(report_exe(), "osobe")
      # funkcije <- dataApi("16156693245", "osobe")
      if (length(funkcije) > 0 && report_exe() %in% funkcije$osobaOib) {
        funkcije <- funkcije[funkcije$osobaOib == report_exe(), ]
        # funkcije <- funkcije[funkcije$osobaOib == "16156693245", ]
        povezani_subjekti <- funkcije$povezaniSubjekti
        funkcije$povezaniSubjekti <- NULL
        funkcije <- funkcije[!duplicated(funkcije),]
        oibreq_subjekti <- unique(funkcije$subjektOib)
        if (is.null(oibreq_subjekti)) {
          funkcije <- NULL
        } else {
          req <- list()
          for (i in 1:length(oibreq_subjekti)) {
            req[[i]] <- dataApi(oibreq_subjekti[i], "subjekti")
          }
        }
        subjekti <- as.data.frame(do.call(base::rbind, req))
        subjekti$isActive <- NULL
        colnames(subjekti)[which(colnames(subjekti) == "adresa")] <- "adresa_subjekta"
        funkcije_all <- merge(x = funkcije, y = subjekti, by.x = "subjektOib", by.y = "oib", all.x = TRUE, all.y=FALSE)
        # za tablicu
        funkcije <- funkcije_all[,c("naziv", "funkcija", "isActive")]
        prva_kolona_ <- data_frame(kol = rep(c("Naziv subjekta", "Funkcija", "Aktivnost funkcije"), nrow(funkcije)))
        prva_kolona_[prva_kolona_$kol == "Naziv subjekta",] <- paste0(1:nrow(funkcije), ". Naziv subjekta")
        funkcije <- unlist(t(funkcije))
        funkcije <- cbind(prva_kolona_, funkcije)
        funkcije <- as.data.frame(funkcije, stringsAsFactors = FALSE)
        colnames(funkcije) <- c("Opis", "Podaci")
        return(list(funkcije = funkcije, funkcije_all = funkcije_all))
      } else {
        funkcije <- data.frame(Opis = "Osoba nije obnašala pravne funkcije u poslovnim subjektima", 
                               Podaci = " ", stringsAsFactors = FALSE)
        funkcije_all <- NA
        return(list(funkcije = funkcije, funkcije_all = funkcije_all))
      }
    })
  })
```
