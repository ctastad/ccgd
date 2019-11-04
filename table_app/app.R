library(shiny)
library(DT)
library(dplyr)
library(rsconnect)



df <- read.csv("ccgd_export.csv")

ui <- fluidPage(

#  sidebarLayout(
#    sidebarPanel(
      #User dropbox
    fluidRow(
      column(3,
        selectInput("Species",
                    label = "Species",
                    choices = c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"),
                    selected = NULL),
      ),
      column(3,
        selectInput("Cancer",
                    label = "Cancer",
                    choices = sort(unique(df$Cancer.Type)),
                    selected = NULL,
                    multiple = TRUE),
      ),
      column(3,
        selectInput("Study",
                    label = "Study",
                    choices = sort(unique(df$Study)),
                    selected = NULL,
                    multiple = TRUE),
      ),
      column(3,
        textAreaInput("Genes",
                    label = "Genes",
                    placeholder = "GeneA,GeneB,GeneC..."),
      )
    ),
      #Print table to UI
#  dataTableOutput("mainTable")

      tabsetPanel(
        tabPanel("Search", dataTableOutput("mainTable")),
        #tabPanel("Search", textOutput("mainTable")),
        tabPanel("Export", dataTableOutput("mainTable1"))
      )
    )
#)

server <- function(input,output){

  Species.values <- reactive({
    if (is.null(input$Species)) {
      return(c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"))
    } else {
      return(input$Species)
    }
  })

  Cancer.values <- reactive({
    if (is.null(input$Cancer)) {
      return(unique(df$Cancer.Type))
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
      return(unlist(strsplit(as.character(df[,1]), " ")))
      #return("Wac")
    } else {
      return(input$Genes)
    }
  })

filtered.df <- reactive({
    return(df %>%
             select(contains(Species.values()), COSMIC:Studies) %>%
             filter(Cancer.Type %in% Cancer.values(),
                    tolower(df[,1]) %in% tolower(
                            unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))),
                    Study %in% Study.values()))
  })

#output$mainTable <- renderText({
#    paste("output", input$Genes)
#})

  output$mainTable <- renderDataTable({
    filtered.df()},
    options = list(
      dom = 'frtip'),
    style = "bootstrap")

  output$mainTable1 <- renderDataTable({
    filtered.df()},
    extensions = "Buttons",
    options = list(
      dom = 'B',
      pageLength = -1,
      buttons = c('copy', 'csv')),
    style = "bootstrap")
}

shinyApp(ui, server)

