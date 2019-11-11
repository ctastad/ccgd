library(shiny)
library(DT)
library(dplyr)
library(rsconnect)


df <- read.csv("ccgd_export.csv")

ui <- fluidPage(
  fluidRow(
    column(
      2,
      downloadButton("downloadData",
        label = "Download"
      ),
    ),

    column(
      2,
      selectInput("Species",
        label = "Species",
        choices = c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"),
        selected = NULL
      )
    ),


    column(
      8,
      selectInput("Study",
        label = "Study",
        choices = sort(unique(df$Study)),
        selected = NULL,
        multiple = TRUE
      )
    )
  ),

  fluidRow(
    column(
      4,
      selectInput("Cancer",
        label = "Cancer",
        choices = sort(unique(df$Cancer)),
        selected = NULL,
        multiple = TRUE
      )
    ),

    column(
      8,
      textAreaInput("Genes",
        label = "Genes",
        placeholder = "GeneA,GeneB,GeneC..."
      )
    )
  ),

  tabsetPanel(
    tabPanel("Search", dataTableOutput("searchTable")),
    tabPanel("Full", dataTableOutput("fullTable"))
  )
)

server <- function(input, output) {
  Species.values <- reactive({
    if (is.null(input$Species)) {
      return(c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"))
    } else {
      return(input$Species)
    }
  })

  Cancer.values <- reactive({
    if (is.null(input$Cancer)) {
      return(unique(df$Cancer))
    } else {
      return(input$Cancer)
    }
  })

  Study.values <- reactive({
    if (is.null(input$Study)) {
      return(unique(df$Study))
    } else {
      return(input$Study)
    }
  })

  Gene.values <- reactive({
    if (input$Genes == "") {
      return(unlist(strsplit(as.character(df[, 1]), " ")))
    } else {
      return(input$Genes)
    }
  })

  filtered.search <- reactive({
    return(df %>%
      select(
        contains(Species.values()),
        Study,
        Effect,
        Rank,
        Cancer,
        Studies
      ) %>%
      filter(
        Cancer %in% Cancer.values(),
        tolower(df[, 1]) %in% tolower(
          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
        ),
        Study %in% Study.values()
      ))
  })

  filtered.full <- reactive({
    return(df %>%
      select(contains(Species.values()), homologId:Studies) %>%
      filter(
        Cancer %in% Cancer.values(),
        tolower(df[, 1]) %in% tolower(
          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
        ),
        Study %in% Study.values()
      ))
  })

  filtered.export <- reactive({
    return(df %>%
      filter(
        Cancer %in% Cancer.values(),
        tolower(df[, 1]) %in% tolower(
          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
        ),
        Study %in% Study.values()
      ))
  })

  output$searchTable <- renderDataTable(
    {
      filtered.search()
    },
    options = list(
      dom = "frtip"
    ),
    style = "bootstrap"
  )

  output$fullTable <- renderDataTable(
    {
      filtered.full()
    },
    options = list(
      dom = "frtip"
    ),
    style = "bootstrap"
  )

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("ccgd_export_", Sys.Date(), ".csv", sep = "")
    },
    content = function(con) {
      write.csv(filtered.export(), con, row.names = F)
    }
  )
}

shinyApp(ui, server)
