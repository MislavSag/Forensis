library(shiny)
# library(markdown)

ui <- fluidPage(

  titlePanel("includeText, includeHTML, and includeMarkdown"),

  fluidRow(
    # column(4,
    #        includeText("include.txt"),
    #        br(),
    #        pre(includeText("include.txt"))
    # ),
    column(4,
           includeHTML("forensis_quarto.html")
    )
    # column(4,
    #        includeMarkdown("include.md")
    # )
  )
)

server <- function(input, output) {

}


shinyApp(ui, server)
