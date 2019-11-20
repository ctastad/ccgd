################################################################################
#
#   File:   app.R
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This is the source file for the shiny table backend of the
#               Candidate Cancer Gene Database.
#   Requires:   ccgd_export.csv, libraries(shiny, DT, dplyr, rsconnect)
#   Executed:   server-side
#
################################################################################


## package dependencies

# library to deploy shiny table app
library(shiny)
# library to employ datatables javascript library
library(DT)
library(dplyr)
# library for shiny app deployment
library(rsconnect)


################################################################################


# read in base source file
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
      )
    ),

    column(
      2,
      selectInput("Species",
        label = "Species",
        choices = c("Mouse", "Human", "Rat", "Fly", "Fish"),
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

  hr(),

  dataTableOutput("searchTable")

  # dataTableOutput("searchTable")

  # layout params for tabbed setup
  #  tabsetPanel(
  #    tabPanel("Search", dataTableOutput("searchTable")),
  #    tabPanel("Full", dataTableOutput("fullTable"))
  #  )
)

################################################################################

# server setup for app
server <- function(input, output) {
  # inputs are fed to a reactive function to setup for filtering
  Species.values <- reactive({
    if (is.null(input$Species)) {
      return(c("Mouse", "Human", "Rat", "Fly", "Fish"))
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

  ################################################################################

  # the output of the reactive inputs are assigned to a variables after filtering
  # to be sent to the respective table
  # this filter is for the search tab table
  filtered.search <- reactive({
    return(df %>%
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

  #  # the full table tab
  #  filtered.full <- reactive({
  #    return(df %>%
  #      select(
  #        contains(Species.values()),
  #        HumanName,
  #        HumanId,
  #        homologId:Studies
  #      ) %>%
  #      filter(
  #        Cancer %in% Cancer.values(),
  #        tolower(df[, 1]) %in% tolower(
  #          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
  #        ),
  #        Study %in% Study.values()
  #      ))
  #  })

  # this filter is not presented in the app but is used for the download fun
  #  filtered.export <- reactive({
  #    return(df %>%
  #      filter(
  #        Cancer %in% Cancer.values(),
  #        tolower(df[, 1]) %in% tolower(
  #          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
  #        ),
  #        Study %in% Study.values()
  #      ))
  #  })

  ################################################################################

  output$searchTable <- renderDataTable(
    {
      speciesName <- sym(paste0(quo_name(Species.values()), "Name"))
      speciesId <- sym(paste0(quo_name(Species.values()), "Id"))

      filtered.search() %>%
        mutate(!!speciesName := paste0(
          "<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",
          !!speciesName, "' target='_blank'>", !!speciesName, "</a>"
        )) %>%
        mutate(!!speciesId := paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/gene/",
          !!speciesId, "' target='_blank'>", !!speciesId, "</a>"
        )) %>%
        mutate(COSMIC = if_else(COSMIC == "Yes", paste0(
          "<a href='https://cancer.sanger.ac.uk/cosmic/gene/analysis?ln=",
          HumanName, "' target='_blank'>", COSMIC, "</a>"
        ), "No")) %>%
        mutate(HumanId = paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/gene/",
          HumanId, "' target='_blank'>", HumanId, "</a>"
        )) %>%
        mutate(HumanName = paste0(
          "<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",
          HumanName, "' target='_blank'>", HumanName, "</a>"
        )) %>%
        mutate(homologId = paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/homologene/?term=",
          homologId, "' target='_blank'>", homologId, "</a>"
        )) %>%
        mutate(Study = paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/pubmed/?term=",
          PubMedId, "' target='_blank'>", Study, "</a>"
        )) %>%
        mutate(CISAddress = paste0(
          "<a href='",
          "http://genome.ucsc.edu/cgi-bin/hgTracks?db=mm10&lastVirtModeType=default&",
          "lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&",
          "position=",
          CISAddress,
          "&hgsid=778514051_gvmjIrgAGh0FwdOmrMCVYF6QcIFD' target='_blank'>", CISAddress, "</a>"
        )) %>%
        select(
          contains(Species.values()),
          HumanName,
          HumanId,
          homologId:Studies
        )
      #        select(
      #          !!speciesName,
      #          HumanName,
      #          Study,
      #          Effect,
      #          Rank,
      #          Cancer,
      #          Studies
      #        )
    },
    extensions = "Buttons",
    options = list(
      dom = "Bfrtip",
      columnDefs = list(list(visible = FALSE, targets = c(2, 4:7, 9, 11))),
      buttons = list(list(extend = "colvis", columns = c(2, 4:7, 9, 11)))
    ),
    style = "bootstrap",
    escape = FALSE
  )

  #  output$fullTable <- renderDataTable(
  #    {
  #      filtered.full()
  #    },
  #    extensions = "Buttons",
  #    options = list(
  #      dom = "Bfrtip",
  #      columnDefs = list(list(visible = FALSE, targets = c(2, 4:7, 9, 11))),
  #      buttons = list(list(extend = "colvis", columns = c(2, 4:7, 9, 11)))
  #    ),
  #    style = "bootstrap"
  #  )

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("ccgd_export_", Sys.Date(), ".csv", sep = "")
    },
    content = function(con) {
      write.csv(df %>%
        filter(
          Cancer %in% Cancer.values(),
          tolower(df[, 1]) %in% tolower(
            unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
          ),
          Study %in% Study.values()
        )
      # filtered.export(), con, row.names = F)
      , con,
      row.names = F
      )
    }
  )
}

shinyApp(ui, server)
