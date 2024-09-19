kategorija <- structure(
  list(Sifra = c("A", "B", "C", "D", "E", "F", "H", "I",
                 "IS", "IZ", "J", "K", "L", "M", "N"),
       oznaka_kategorija = c("DJELATNICI I ČLANOVI NJIHOVIH OBITELJI",
                             "OSOBE KOJE SAMOSTALNO OBAVLJAJU PRIVREDNE I NEPRIVREDNE DJELATNOSTI I ČLANOVI NJIHOVIH OBITELJI",
                             "POLJOPRIVREDNICI I ČLANOVI NJIHOVIH OBITELJI", "UMIROVLJENICI I ČLANOVI NJIHOVIH OBITELJI",
                             "OSOBE OSIGURANE PREMA POSEBNIM PROPISIMA",
                             "OSOBE PRIVREMENO NEZAPOSLENE I ČLANOVI NJIHOVIH OBITELJI",
                             "INOZEMNI OSIGURANICI I ČLANOVI NJIHOVIH OBITELJI",
                             "NEOSIGURANE OSOBE (NOO, NOS) -> Osigurane osobe koje same uplaćuju doprinos",
                             "OSIGURANE OSOBE - PROGNANICI U REPUBLICI HRVATSKOJ", "NEOSIGURANE OSOBE - IZBJEGLICE",
                             "OSTALE OSIGURANE OSOBE (SVI ONI KOJI NISU POBROJANI POD GORNJIM OZNAKAMA)",
                             "ROČNICI I ČLANOVI NJIHOVIH OBITELJI", "NEOSIGURANE OSOBE IZ RH",
                             "NEOSIGURANE OSOBE - STRANCI", "TRAŽITELJI AZILA")),
  .Names = c("Sifra",
             "oznaka_kategorija"), class = "data.frame", row.names = c(NA, -15L))

osnova <- structure(
  list(Sifra = c(101L, 161L, 115L, 112L, 414L, 207L,
                 208L, 170L, 133L, 130L),
       oznaka_osnova = c("Radni odnos", "Pomorac u plovidbi",
                         "Nezaposlenost",
                         "Umirovljenik s HR mirovinom",
                         "Umirovljenik s inozemnom mirovinom",
                         "Član obitelji (supružnik)", "Član obitelji (dijete)", "Djeca (samostalno)",
                         "Obrtnik (vlasnik)", "Radni odnos kod obrtnika")),
  .Names = c("Sifra", "oznaka_osnova"), class = "data.frame", row.names = c(NA, -10L))

osnova$Sifra <- str_pad(osnova$Sifra, width = 5, side = "left", pad = "0")
