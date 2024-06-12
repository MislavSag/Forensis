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
- dodati html text inpput ime i prezime koji je opcionalan. Ako se upiše ime i prezime, ono se koristi u pretrazi RS, Federacije, plovila i eventualnih drugi pretraga. Ako se ime i prezime ostavi prazno, povlači se ime i prezime iz nađe baze. Primer povlačenja imena i prezimena iz naše baze dostupan je u mom koduČ

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

