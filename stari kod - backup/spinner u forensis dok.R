# Ovo je neka ideja za spinner. Međutim jednostavno ne radi. Po meni je problem
# na tragu show(id = "spinner_div")

# mod_forensis_dokument.R

MUI_forensis_dokument <- function(id) {
  ns <- NS(id)
  fluidPage(
    useShinyjs(),  # Inicijalizirajte shinyjs
    titlePanel("Forensis Dokument"),
    sidebarLayout(
      sidebarPanel(
        textInput(ns("oib"), "Unesite OIB:", value = ""),
        textInput(ns("ime_prezime"), "Unesite Ime i Prezime (opcionalno):", value = ""),
        actionButton(ns("render_btn"), "Generiraj dokument"),
        hidden(div(id = ns("download_ui_div"), uiOutput(ns("download_ui"))))  # Sakrij gumb za preuzimanje
      ),
      mainPanel(
        hidden(div(id = ns("spinner_div"), withSpinner(div(), color = "#0dc5c1"))),  # Dodaj spinner kao zaseban div
        uiOutput(ns("html_output"))  # Prikaži html_output
      )
    )
  )
}

MS_forensis_dokument <- function(input, output, session) {
  ns <- session$ns

  observeEvent(input$render_btn, {
    req(input$oib)

    # Prikaz spinnera i sakrivanje output-a na početku
    shinyjs::show(id = "spinner_div")
    shinyjs::hide(id = "html_output")
    shinyjs::hide(id = "download_ui_div")

    ime_prezime <- input$ime_prezime

    # Ako ime i prezime nije uneseno, dohvatiti iz baze pomoću OIB-a
    if (ime_prezime == "") {
      data <- loadDataFiz(input$oib)
      if (nrow(data) > 0) {
        ime_prezime <- data$ime_prezime[1]
      } else {
        ime_prezime <- ""
      }
    }

    # Stvorite YAML sadržaj s OIB-om i Ime_Prezime
    yaml_content <- paste0(
      "oib: '", input$oib, "'\n",
      "ime_prezime: '", ime_prezime, "'\n"
    )
    param_file <- "params.yml"
    writeLines(yaml_content, param_file)

    # Renderirajte Quarto dokument s novim parametrima koristeći params.yml datoteku
    render_command <- paste('quarto render forensis_quarto.qmd --execute-params', param_file, '--output-dir reports')
    system(render_command, wait = TRUE) # čekanje da se renderiranje završi

    # Sakrivanje spinnera i prikaz output-a nakon završetka renderiranja
    shinyjs::hide(id = "spinner_div")
    shinyjs::show(id = "html_output")
    shinyjs::show(id = "download_ui_div")

    # Ažurirati iframe za prikaz generiranog dokumenta
    output$html_output <- renderUI({
      tags$iframe(style = "height:1000px; width:100%", src = "my_resource/forensis_quarto.html")
    })

    # Prikaz gumba za preuzimanje dokumenta nakon generiranja
    output$download_ui <- renderUI({
      downloadButton(ns("download_btn"), "Preuzmi dokument", class = "btn btn-success")
    })
  })

  # Omogućite preuzimanje generiranog dokumenta
  output$download_btn <- downloadHandler(
    filename = function() {
      paste0("report_", input$oib, ".html")
    },
    content = function(file) {
      file.copy("reports/forensis_quarto.html", file)
    }
  )
}
