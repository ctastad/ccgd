library(shiny)
library(DT)
library(dplyr)
library(rsconnect)


df <- read.csv("ccgd_export.csv")

ui <- fluidPage(
  #User dropbox
  selectInput("Model",
              label = "Model",
              choices = c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"),
              selected = NULL),
  selectInput("Cancer",
              label = "Cancer",
              choices = unique(df$Cancer.Type),
              selected = NULL,
              multiple = TRUE),
  selectInput("Study",
              label = "Study",
              choices = unique(df$Study),
              selected = NULL,
              multiple = TRUE),
  textAreaInput("Genes",
              label = "Genes",
              placeholder = "GeneA,GeneB,GeneC..."),
  #Print table to UI
  dataTableOutput("mainTable")
)

server <- function(input,output){

  Model.values <- reactive({
    if (is.null(input$Model)) {
      return(c("Mouse", "Human", "Rat", "Drosophila", "Zebrafish"))
    } else {
      return(input$Model)
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
      return(unlist(strsplit(as.character(df[,1]), ",")))
      #return("Wac")
    } else {
      return(input$Genes)
    }
  })

filtered.df <- reactive({
    return(df %>%
             select(contains(Model.values()), COSMIC:Studies) %>%
             filter(Cancer.Type %in% Cancer.values(),
                    tolower(df[,1]) %in% tolower(
                            unlist(strsplit(Gene.values(), ","))),
                    Study %in% Study.values()))
  })

  output$mainTable <- renderDataTable({
    filtered.df()},
    options = list(
      pageLength = 15),
    style = "bootstrap")

  observeEvent(input$Genes, {
    print(paste0("You have chosen: ", input$Genes))
    print(is.null(input$Genes))
    print(class(input$Genes))
    print(input$Genes == "")
  })

}

shinyApp(ui, server)
