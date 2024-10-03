# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju započinjati bez "parms:"

## GOTOVO:

- [] Ako netko napiše samo OIB bez ime_prezime, a funkcija loadDataFiz ne pronađe ime_prezime,
stavio sam sljedeće upozorenje: 
"Nije pronađeno ime i prezime za navedeni OIB. Potrebno je napisati ime i prezime za generiranje izvještaja."
- razlog je što nije moguće renderirati quarto dokument ako je ime_prezime = ""
- jednostavnije mi je to nego u quarto stavljati if petlju da preskače chunk-ove gdje se traži ime_prezime, ako je ime_prezime = ""

- [] dodane napomene za generiranje izvještaja
- [] uredio sam sve nazive tablica kod exporta
- [] pojednostavio prikaze - kozmetički doradio što se moglo

- [] stavio sam iste funkcije za prikaz DT-a u module i u quarto dokument - sada
quarto dokumenti izgledaju full bolje i korisnici mogu koristiti export podataka
unutar generiranog .html file-a

## TODO

- [] malo još proučiti šifranike u Sudskom registru - zna se
dogoditi kaos kada API call povuće podatke za npr. PREDMET POSLOVANJA
i jos uz to povuće dodatni DF sa nacionalnom klasifikacijom (izabrat jedno ili
probat spojit sve zajedno) # nije toliko važno (za detalje vidi quarto pravne
sa OIB-om "02573674713" - učitaj prvi chunk i pogledaj objekt "tablice" u global env)

- [] GFI izvještaji
- [] provjerit ovaj OIB (02573674713) za pravne osobe i pogledati predmet_poslovanja
- [] Dodati nazive umjesto sifrarnikau dijelu zdrastvenog osiguranja. Sifrarnik sam dodao u functions.R file na kraju.

## V2

- [] porezni duznici

## Firebase

Documentation for implementing firebase in th app is available [here](https://firebase.john-coene.com/).
