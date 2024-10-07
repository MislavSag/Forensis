# ovo je pojednostavljena DT funkcija za zemljišne knjige RH
# koristiti će se u quarto dokumentu
DT_template_ZKRH_simple <- function(df, fixedHeader = TRUE) {

  # Zero-based index of the 'Link' column
  link_col_index <- which(names(df) == "Link") - 1  # R koristi indeksiranje od 1, JavaScript od 0

  # Definiramo zajedničke JavaScript funkcije
  filename_js <- JS("function() { var date = new Date(); var day = ('0' + date.getDate()).slice(-2); var month = ('0' + (date.getMonth() + 1)).slice(-2); var year = date.getFullYear(); return 'ZKRH_' + day + '-' + month + '-' + year; }")
  body_js <- JS(paste0("function(data, row, column, node) { var idx = column; if(idx === ", link_col_index, ") { var link = $('<div>' + data + '</div>').find('a').attr('href'); return link ? link : data; } else { return data; } }"))

  datatable(
    df,
    rownames = FALSE,
    escape = FALSE,
    extensions = c('Buttons'),
    options = list(
      dom = 'B',  # Prikazuje samo gumbe za export
      pageLength = -1,  # Prikaz svih redaka
      columnDefs = list(
        list(
          targets = link_col_index,
          render = JS("function(data, type, row, meta) { if(type === 'display'){ return '<a href=\"' + data + '\" target=\"_blank\">Open</a>'; } else { return data; } }")
        )
      ),
      buttons = list(
        list(extend = 'copy', filename = filename_js, exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'csv', filename = filename_js, bom = TRUE, charset = 'utf-8', exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'excel', filename = filename_js, bom = TRUE, charset = 'utf-8', exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'pdf', filename = filename_js, exportOptions = list(columns = ':visible', format = list(body = body_js))),
        list(extend = 'print', filename = filename_js, title = '', exportOptions = list(columns = ':visible', format = list(body = body_js)))
      )
    )
  )
}

# ovo je pojednostavljeni DT template koji se koristi za RS i Federaciju (skraćeno BIH) i za plovila
# dodaje se argument za uređivanje imena - to se mijenja u QUARTO CHUNK-u !!!
DT_template_ZKBIH_plovila_simple <- function(df, filename_prefix = "rezultati", fixedHeader = TRUE) {
  datatable(
    df,
    rownames = FALSE,
    extensions = c('Buttons', 'FixedHeader'),
    options = list(
      dom = 't',  # Uklanjanje gumbova za pretragu, paginaciju itd.
      pageLength = -1,  # Prikaz svih redaka
      autoWidth = TRUE,  # Automatsko podešavanje širine stupaca
      ordering = FALSE,  # Onemogućava sortiranje tablice
      scrollX = TRUE,    # Omogućava horizontalno skrolanje
      fixedHeader = fixedHeader, # Zaglavlje će ostati vidljivo prilikom vertikalnog skrolanja
      buttons = list(
        'copy',
        list(extend = 'csv', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y")),
             bom = TRUE, charset = 'utf-8'),  # CSV
        list(extend = 'excel', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y")),
             bom = TRUE, charset = 'utf-8'),  # Excel
        list(extend = 'pdf', filename = paste0(filename_prefix, format(Sys.Date(), "%d-%m-%Y"))),  # PDF
        list(extend = 'print', title = '')  # Print
      )
    )
  )
}
