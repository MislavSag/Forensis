library(shiny)
library(bslib)
library(DT)


### VERSION 1

ui <- page_navbar(
  title = "Forensis",
  id = "nav",
  sidebar = sidebar(
    conditionalPanel(
      "input.nav === 'Nekretnine RH'",

      checkboxGroupInput("checkbox", "Pretraži dio",
                         choices = c("Sve", "Dio A", "Dio B", "Dio C"))
      ),
    conditionalPanel(
      "input.nav === 'Nekretnine RS'",
      "test"
    )
  ),
  nav_panel("Nekretnine RH",
            textInput("nekretninerh_q",
                      "Unesite pojam za pretragu ZK i KPU",
                      width = "100%")),
  nav_panel("Nekretnine RS",
            textInput("nekretniners_q",
                      "Unesite pojam za pretragu katastra RS",
                      width = "100%"))
)

server <- function(input, output) {
  # output$p <- renderPlot({
  #   textInput("caption", "Caption", "Data Summary")
  # })
  # output$nekretninerh_q = render
}

shinyApp(ui, server)

### VERSION 2

# ui <- page_navbar(
#   title = "Forensis",
#   id = "nav",
#   sidebar = sidebar(
#     accordion(
#       accordion_panel(
#         "Nekretnine RH",
#         checkboxGroupInput("checkbox", "Pretraži dio", choices = c("Dio A", "Dio B"))
#       ),
#       accordion_panel(
#         "Nekretnine RS",
#         "Test"
#       )
#     )
#   )
# )
#
# server <- function(input, output) {
#   # output$p <- renderPlot({
#   #   textInput("caption", "Caption", "Data Summary")
#   # })
# }
#
# shinyApp(ui, server)
