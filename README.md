# Notes

## Quarto:

-   YAML - `self-contained: true` - ne kreira poseban folder sa quarto_files
-   rendering se vrši sa `system()` - terminal
-   parametri koji su spremljeni u .yml file trebaju započinjati bez "parms:"

## GOTOVO:

- [] Napomena ako loadDataFiz ne pronalazi ime_prezime po OIB-u
DODATNO - kako onda urediti fizicke_quarto ? Ako je parametar ime_prezime prazno, funkcije koje pretrazuju podatke po imenu i prezimenu (zk rh, plovila...) javljaju error

- [] nemamo napomene kod generiranja izvještaja -ocemo to dodati ? 

- [] malo još proučiti šifranike u Sudskom registru - zna se
dogoditi kaos kada API call povuće podatke za npr. PREDMET POSLOVANJA
i jos uz to povuće dodatni DF sa nacionalnom klasifikacijom (izabrat jedno ili
probat spojit sve zajedno) # nije toliko važno (za detalje vidi quarto pravne
sa OIB-om "02573674713" - učitaj prvi chunk i pogledaj objekt "tablice" u global env)

- [] ZK RS i Federacija koriste isti DT_template - kod skidanja tablica
sam stavio da se file zove "rezultati...". Moguće je napraviti da svaki
ima svoj template i da se file za RS kod skidanja zove "RS...", a kod Federacije
"Federacija..."

- [] U ZK RH se ne moze implementirati DT_template koji koriste RS i F
Problem stvara zadnji stupac "link" na koji se moze kliknuti i otvoriti url.
Nisam uspio sloziti niti poseban kod preko DT-a. Zadatak bi bio imati DT koji
prikazuje linkove u aplikaciji i izvoz koji linkove pretvara u tekst. Prekomplicirano
za DT() funkciju. Zato sam napravio "potpuno" drugačiji kod. Tablica se prikazuje normalno
sa linkovima, a u UI i server funkciji se koriste ugrađeni gumbovi od shiny aplikacije
za skidanje csv i xlsx file-ova. Kod je malo duži, morao sam ubaciti UTF-8 enkripciju,
prikaz gumba nakon prikaza tablice, ali sve super radi.
To mi se definitivno čini kao najlakše rješenje. Mozda se mozda i tablica spremiti u memoriju
pa skinuti na neki klik ispod tablice...

- [] Šifrarnik dodan u Zdravstveno za fizičke osobe (učitavam
`source("sifrarnik.R")` direkt u quarto)
ŠIFRARNIK JE ZASTARIO - upiši moj OIB:18710011268 i dobiješ ovo 00185, a ja sam nezaposlen u bazi

## TODO

- [] GFI izvještaji
- [] provjerit ovaj OIB (02573674713) za pravne osobe i pogledati predmet_poslovanja
- [] Dodati nazive umjesto sifrarnikau dijelu zdrastvenog osiguranja. Sifrarnik sam dodao u functions.R file na kraju.

## V2

- [] porezni duznici

## Firebase

Documentation for implementing firebase in th app is available [here](https://firebase.john-coene.com/).
