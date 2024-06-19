# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## TODO
- [] promijeniti redoslijed modu gore u app: ZK RH, ZK RS, ZK Federacija, plovila, Forensis dokument, Forensis dokument pravne
- [] dodao bi napomenu da generiranje dokumenta traje cca 2 minute.
- [] dodati modu za pravne osobe i za sada pronaći samo osnovne podatke iz sudskog registra po OIB-u. Dokumentacija za javni API sudskog registra dostupna je na [linku](https://sudreg-data.gov.hr/ords/r/srn_rep/vanjski-srn-rep/home). Ovo je nova dokumentacija aktivna od 1.5.2024. Dakle pokazati osnovne podatke o firmi u tablici. nije potrebno sve podatke. Sam izaberi koje ces staviti, ali za pocetak je dovoljno, naziv, OIB, sjediste i td. Nazive endpointa mozes dobit pomocu koda.
- [] omoguciti da se pretraga izvrsi pomocu entera, barem za brze pretrage ZK i plovila. 
- [] nisam mislio za sada cijepislacit, ali odvojio bi malo gumbe Generiraj i Preuzmi dokument.
- [] progugalti mogucnosti za administriranje korisnika. Meni su poznati shinyauth i auth0. Ali koliko se sjecam ima i neka opcija sa Firebasom. Ploomber se isto cini ok ovako na prvu.
 

```{r}
sr_api = read_json("https://sudreg-data.gov.hr/api/javni/dokumentacija/open_api")
names(sr_api$paths)
```
Za detalje o firmi mozes koristiti endpoint `detalji_subjekta`.

- [] Pretvorio bi tablicu poslovnih funkcija u wide format. dakle da budu kolone naziv subjekta, funkcija, aktivnost funkcije.


## Q
- trebam li plovila RH pretraživati samo po ime_prezime ili i po oib-u ?
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)
- rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

## Gotovo
- pretraga nekretnina u federaciji + dodano u forensis dokument
- pretraga RS i Federacije samo po imenu i prezimenu u forensis dok.
- pretraga zdravstvenog osiguranja
- pretraga poslovnih funkcija u poduzećima
- novi bslib dashboard - još se treba dodatno uredit. Stari app kod sam spremio u arhivu
