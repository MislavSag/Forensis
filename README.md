# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## GOTOVO:

-   UI na sredini
-   export iz DT u excel/pdf/print radi za sve stupce
-   OIB checker i max 11 znakova
-   Pretraga plovila samo po nazivu
-   Pravne osobe modul
-   Skripta za GFI zasada sadrži samo konvertiranje originalnih GFI-jeva u utf-8

## TODO

- [] staviti UI na sredinu (na primjer input text gdje se upisuje pojam i opcije ispod na sredinu). Output bi stabio ispod, isto na sredinu, kao sto je u NekretninePlus apliakciji. Mislim da ljepse izgleda. Ovako napamet, mislim da se za to koristi rowfloud u base shiny. Za bslib trba pogledati u dokumentaciju.
- [] za pravne osobe treba dodati neke podatke, to mozemo na callu rapstaviti kada se vrati s mora. Najbitnije je dodati pretrage nekretnina za sada.
- [] Dodati mogucnost generiranje reporta za pravne osobe
- [] Excel epxort kod datatable-a treba povuci cijelu tablicu (server = FALSE)
- [] OIB checker i max 11 znakova
- [] Pretraga plovila samo po nazivu.
- [] Pretraga po OIB-u 44339275803 u forensis dokument modulu vraca 404. Provjeriti zasto.
- treba odabrati što ćemo zadržati u podacima iz API Sudski registar za pravne osobe
- GFI prikaz svih godina ? Konvertiranje iz HRK u EUR ?

## Q

-   rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

## V2

-   porezni duznici

## Firebase

Documentation for implementing firebase in th app is available [here](https://firebase.john-coene.com/).
