# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## TODO

- [] progugalti mogucnosti za administriranje korisnika. Meni su poznati shinyauth i auth0. Ali koliko se sjecam ima i neka opcija sa Firebasom. Ploomber se isto cini ok ovako na prvu.

## Q
- trebam li plovila RH pretraživati samo po ime_prezime ili i po oib-u ?
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)
- rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

## Gotovo
- redoslijed modula u aplikaciji
- dodana napomena da generiranje dokumenta traje cca 2 minute
- gumb preuzmi dokument odvojen od generiraj dokument
- enter za pretraživanje dodan u search - svi moduli (u forensis dokumentu samo kod OIB-a)
- dodan je modul pravne_osobe - svi su podaci ubačeni u modul pa se možemo dogovoriti što da maknem
- tablica poslovnih funkcija je u wide formatu
