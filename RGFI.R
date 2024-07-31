library(readr)
library(openxlsx)
library(stringi)

# Postavljanje putanja
input_dir <- "D:/R_projekti/Forensis/RGFI Sudski registar/Row data"
output_dir <- "D:/R_projekti/Forensis/RGFI Sudski registar/UTF converted"

# Provjera postojanja ulaznog direktorija
if (!dir.exists(input_dir)) {
  stop("Ulazni direktorij ne postoji. Provjerite putanju.")
}

# Kreiranje izlaznog direktorija ako ne postoji
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Provjera CSV datoteka u ulaznom direktoriju
csv_files <- list.files(input_dir, pattern = "\\.csv$", full.names = TRUE)

# Provjera broja pronađenih datoteka
print(paste("Pronađeno CSV datoteka:", length(csv_files)))


# Funkcija za učitavanje, konverziju i spremanje podataka
convert_csv_to_utf8 <- function(file_path, output_dir) {
  # Učitajte podatke iz CSV datoteke
  data <- read_delim(file_path, delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)

  # Konverzija svih znakova u UTF-8
  data_utf8 <- as.data.frame(lapply(data, function(x) {
    if (is.character(x)) {
      return(stri_enc_toutf8(x, validate = TRUE))
    } else {
      return(x)
    }
  }))

  # Prikaz prvih nekoliko redaka i stupaca za provjeru
  print(paste("Prikaz podataka za datoteku:", basename(file_path)))
  print(colnames(data_utf8)[1:5])  # Prikaz prvih 5 stupaca

  # Kreirajte ime izlazne datoteke
  output_file <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(file_path)), "_utf8.csv"))

  # Spremite konvertirane podatke u novu CSV datoteku
  write_delim(data_utf8, output_file, delim = ";")
}

# Učitajte i konvertirajte podatke iz svih CSV datoteka
for (csv_file in csv_files) {
  convert_csv_to_utf8(csv_file, output_dir)
}




#___________________
library(tidyverse)

RGFI_2008 <- read_delim("RGFI Sudski registar/UTF converted/RGFI_javna_objava_2008_utf8.csv",
                        delim = ";", escape_double = FALSE, trim_ws = TRUE)

a1 <- head(RGFI_2008, 50)
write.xlsx(a1, "a1.xlsx")


RGFI_2022 <- read_delim("RGFI Sudski registar/UTF converted/RGFI_javna_objava_2022_utf8.csv",
                        delim = ";", escape_double = FALSE, trim_ws = TRUE)

a2 <- head(RGFI_2022, 50)
write.xlsx(a2, "a2.xlsx")





