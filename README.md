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
-   Pravne osobe se pretražuju samo po OIB-u u aplikaciji, a qmd file uzima skraćenu tvrtku sa sudskog registra kao "naziv"
-   Sve tablice su na sredini aplikacije
-   radioButtons u zemljisnim knjigama su na sredini aplikacije
-   Napomena ako loadDataFiz ne pronalazi
ime_prezime po OIB-u - DODATNO - kako onda urediti fizicke_quarto ? Ako je parametar ime_prezime prazno, funkcije koje pretrazuju podatke po imenu i prezimenu (zk rh, plovila...) javljaju error

## TODO

- [] izvještaj fizičke - napomena ako funkcija loadDataFiz ne pronalazi
ime_prezime po OIB-u
- [] Parallel processing for forensis report. Look at https://shiny.posit.co/r/articles/improve/nonblocking/index.html
- [] dodati expand_relations parametar u pravne_osobe_API funkciju

## Q

-   rezultati zdravstvenog osiguranja prikazati u tablici ili u tekstu ? (trenutno je tablica)

## V2

-   porezni duznici

## Firebase

Documentation for implementing firebase in th app is available [here](https://firebase.john-coene.com/).
