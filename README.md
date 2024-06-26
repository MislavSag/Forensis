# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## TODO

- [] progugalti mogucnosti za administriranje korisnika. Meni su poznati shinyauth i auth0. Ali koliko se sjecam ima i neka opcija sa Firebasom. Ploomber se isto cini ok ovako na prvu.
- [] staviti UI na sredinu (na primjer input text gdje se upisuje pojam i opcije ispod na sredinu). Output bi stabio ispod, isto na sredinu, kao sto je u NekretninePlus apliakciji. Mislim da ljepse izgleda. Ovako napamet, mislim da se za to koristi rowfloud u base shiny. Za bslib trba pogledati u dokumentaciju.
- [] za pravne osobe treba dodati neke podatke, to mozemo na callu rapstaviti kada se vrati s mora. Najbitnije je dodati pretrage nekretnina za sada.
- [] Dodati mogucnost generiranje reporta za pravne osobe

## Q
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)
- rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

