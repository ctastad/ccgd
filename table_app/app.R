## package dependencies

# library to deploy shiny table app
library(shiny)
# library to employ datatables javascript library
library(DT)
library(dplyr)
# library for shiny app deployment
library(rsconnect)

#read in base source file
df <- read.csv("ccgd_export.csv")

# build shiny app UI
ui <- fluidPage(
  # layout for shiny app inputs
  # inputs are arranged in column, width orientation
  # each column variable set represents a single input and its params
  fluidRow(
    column(
      2,
      # button for table export
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

  # next row of inputs layout
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

  # layout params for tabbed setup
  tabsetPanel(
    tabPanel("Search", dataTableOutput("searchTable")),
    tabPanel("Full", dataTableOutput("fullTable"))
  )
)

# server setup for app
server <- function(input, output) {
  # inputs are fed to a reactive function to setup for filtering
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
      # the gene value input is setup to allow for different delims
      return(unlist(strsplit(as.character(df[, 1]), " ")))
    } else {
      return(input$Genes)
    }
  })

  # the output of the reactive inputs are assigned to a variables after filtering
  # to be sent to the respective table
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
        # the towlower implementation allows for case insensitivity for gene inputs
        tolower(df[, 1]) %in% tolower(
          # this regex fun allows for different delims on input
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
