# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## TODO
- [] naprviti pretragu sudskog reistra preko Data API-a preko kojeg pretrazujemo i ZK. Trazimo poslovne funkcije u poslovnim subjektima. Mozes pogledat moj stari kod
- [] naprviti pretragu nekretnina u federaciji
- [] napraviti pretragu statusa zdrastvenog osiguranja. Ovo takodjer imamo preko Data API-a. Iako bi mogli i samo implementirati. Ali za sada Data API
- [] prijeci na novi bslib dashboard
- [] progugalti mogucnosti za administriranje korisnika. Meni su poznati shinyauth i auth0. Ali koliko se sjecam ima i neka opcija sa Firebasom

## Q
- trebam li plovila RH pretraživati samo po ime_prezime ili i po oib-u ?
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)
