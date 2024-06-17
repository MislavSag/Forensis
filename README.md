# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

# TODO

## Završeno
- gumb "preuzmi dokument" - nakon prikaza u aplikaciji i zelene boje
- povećan je iframe
- u sql bazi "fizicke_osobe" dodana varijabla datumrodenja_korigirano (datumrodjenja + 1 dan) i varijabla ime_prezime da se ne moraju naknadno spajati ime + prezime
- dodatni text input za ime_prezime - koristi se u pretrazi svih baza, a ako nije uneseno, povlaće se podaci sa funkcijom loadDataFiz

## Pitanja
- trebam li plovila RH pretraživati samo po ime_prezime ili i po oib-u ?
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)

## Problemi
- [x] ne mogu napraviti spinner u forensis dokument modulu. Jednostavan spinner radi u modulu zemljišne knjige RH.
- [x] sigurno je potrebno koristiti shinyjs paket koji omogućuje sakrivanje i prikaz elemenata i nekih zanimljivih funkcija iz java scripta
- [x] uz pomoć GPT-ja napravio sam neki kod, ali ne mogu ga završiti kako treba
- [x] pokušaji su bili sljedeći: (1) spinner se vrti cijelo vrijeme i prije nego se upišu podaci i stisne gumb "generiraj dokument"; (2) Ima spinera i nema html outputa (shvatio sam da je zbog hide komande); (3) ovu verziju sam stavio u posebnu skriptu pa se mozda moze doraditi - html se prikazuje, sve radi, ali nema spinnera iako je stavljen u kod

(mislav) - mislim da je ovo rijsenoe

## Forensic report
Postoji još jedna malo složenija pretraga koju bi dodao, ali to možemo u drugoj fazi.
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
