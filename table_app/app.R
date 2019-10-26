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
              #value = unlist(strsplit(as.character(df[,1]), ",")),
              value = NULL),
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
    if (is.null(input$Genes)) {
      return("pten")
    } else {
      return(input$Genes)
    }
  })

filtered.df <- reactive({
    return(df %>%
             select(contains(Model.values()), COSMIC:Studies) %>%
#             filter(grepl(Gene.values(), df[,1], ignore.case = TRUE)) %>%
             filter(Cancer.Type %in% Cancer.values(),
                    tolower(df[,1]) %in% tolower(unlist(strsplit(Gene.values(), ", "))),
                    Study %in% Study.values()))
  })

  output$mainTable <- renderDataTable({
    filtered.df()},
    options = list(
      pageLength = 15),
    style = "bootstrap")

}

shinyApp(ui, server)


#shinyApp(
#  ui = fluidPage(DTOutput('tbl')),
#  server = function(input, output) {
#    output$tbl = renderDataTable(
#      df, options = list(lengthChange = FALSE)
#    )
#  }
#)

## MWE

#ui <- fluidPage(
#  #User dropbox
#  selectInput("state", "Choose state", choices=c("MA", "CA", "NY"))
#  #Print table to UI
#  ,tableOutput("table1")
#)
#
#server <- function(input,output){
#
#  category <- c("MA", "CA", "NY")
#  population <- c(3,8,4)
#
#  df <- data.frame(category,population)
#
#  df_subset <- reactive({
#    a <- subset(df, category == input$state)
#    return(a)
#  })
#
#  output$table1 <- renderTable(df_subset()) #Note how df_subset() was used and not df_subset
#
#}
#
#shinyApp(ui, server)

# https://stackoverflow.com/questions/48926395/simplify-the-subset-of-a-table-using-multiple-conditions-in-r-shiny

#ui <- fluidPage(
#
#  titlePanel("mtcars"),
#
#  sidebarLayout(
#    sidebarPanel(
#      selectInput("vs",
#                  label = "vs",
#                  choices = c(0, 1),
#                  selected = NULL,
#                  multiple = TRUE),
#      selectInput("carb",
#                  label = "carb",
#                  choices = c(1, 2, 3, 4, 6, 8),
#                  selected = NULL,
#                  multiple = TRUE),
#      selectInput("gear",
#                  label = "gear",
#                  choices = c(3, 4, 5),
#                  selected = NULL,
#                  multiple = TRUE)
#    ),
#
#
#    mainPanel(
#      tabsetPanel(
#        tabPanel("Expression values", tableOutput("mainTable")),
#        tabPanel("ID filtering", tableOutput("table"))
#      )
#    )
#  )
#)
#
#server <- function(input, output) {
#
#  samples.df <- data.frame(ID = paste0("ID", as.character(round(runif(nrow(mtcars),
#                                                                      min = 0,
#                                                                      max = 100 * nrow(mtcars))))),
#                           gear = as.factor(mtcars$gear),
#                           carb = as.factor(mtcars$carb),
#                           vs = as.factor(mtcars$vs))
#
#  values.df <- cbind(paste0("Feature", 1:20),
#                     as.data.frame(matrix(runif(20 * nrow(samples.df)), nrow = 20)))
#
#  colnames(values.df) <- c("Feature", as.character(samples.df$ID))
#
#  vs.values <- reactive({
#    if (is.null(input$vs)) {
#      return(c(0, 1))
#    } else {
#      return(input$vs)
#    }
#  })
#
#  carb.values <- reactive({
#    if (is.null(input$carb)) {
#      return(c(1, 2, 3, 4, 6, 8))
#    } else {
#      return(input$carb)
#    }
#  })
#
#  gear.values <- reactive({
#    if (is.null(input$gear)) {
#      return(c(3, 4, 5))
#    } else {
#      return(input$gear)
#    }
#  })
#
#  filtered.samples.df <- reactive({
#    return(samples.df %>% filter(gear %in% gear.values(),
#                                 vs %in% vs.values(),
#                                 carb %in% carb.values()))
#  })
#
#  filtered.values.df <- reactive({
#    selected.samples <- c("Feature", names(values.df)[names(values.df) %in% filtered.samples.df()$ID])
#    return(values.df %>% select(selected.samples))
#  })
#
#  output$mainTable <- renderTable({
#    filtered.values.df()
#  })
#
#  output$table <- renderTable({
#    filtered.samples.df()
#  })
#
#
#}
#
#shinyApp(ui = ui, server = server)
