# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju zapoćinjati bez "parms:"

## TODO

- [] staviti UI na sredinu (na primjer input text gdje se upisuje pojam i opcije ispod na sredinu). Output bi stabio ispod, isto na sredinu, kao sto je u NekretninePlus apliakciji. Mislim da ljepse izgleda. Ovako napamet, mislim da se za to koristi rowfloud u base shiny. Za bslib trba pogledati u dokumentaciju.
- [] za pravne osobe treba dodati neke podatke, to mozemo na callu rapstaviti kada se vrati s mora. Najbitnije je dodati pretrage nekretnina za sada.
- [] Dodati mogucnost generiranje reporta za pravne osobe
- [] Excel epxort kod datatable-a treba povuci cijelu tablicu (server = FALSE)
- [] OIB checker i max 11 znakova
- [] Pretraga plovila samo po nazivu.
- [] Pretraga po OIB-u 44339275803 u forensis dokument modulu vraca 404. Provjeriti zasto.

## Q
- da ubacim oib checker ? Našao sam jedan mali problem:
oib_checker mi daje 1 za 18710011268 (točan oib) i 1871001126811111 (ili bilo koji drugi nastavak brojeva nakon točnog oib-a)
-   updateData i sel funkcije (functions.R skripta) - kada se koriste ? (Ovo možemo proći nabrzinu uzivo iz starog forensis koda. Mislio sam da ću koristiti te funkcije u novoj aplikaciji)
- rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

## Pravne osobe
- sudski registar - API call subjetk_detalji
- izvjestaji sa FINA-e. Otici na [link](https://rgfi.fina.hr/JavnaObjava-web/jsp/prijavaKorisnika.jsp){target="_blank"}. Registrirati se, preuzeti csv za 2022. Probat prvo stavit u data folder. Ucitati kada se aplikacija pokrece sa fread. Prikazati podatke i izvjestaja
- nekretnine RH po OIB-u i nazivu
- nekretnine RS po nazivu
- nekretnine Federacija po nazivu
- plovila po nazivu

## V2
- porezni duznici

## Firebase

Documentation for implementing firebase in th app is available [here](https://firebase.john-coene.com/).
