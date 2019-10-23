library(shiny)
library(DT)

df <- read.csv("ccgd_export.csv")

shinyApp(
  ui = fluidPage(DTOutput('tbl')),
  server = function(input, output) {
    output$tbl = renderDT(
      df, options = list(lengthChange = FALSE)
    )
  }
)
