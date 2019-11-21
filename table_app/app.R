################################################################################
#
#   File:   app.R
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-19
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
  # next row of inputs layout
  fluidRow(

    column(
      2,
      selectizeInput("Species",
        label = "Species",
        choices = c("Mouse", "Human", "Rat", "Fly", "Fish", "Yeast"),
        #selected = NULL,
        selected = c("Mouse", "Human"),
        multiple = TRUE
      )
    ),

    column(
      3,
      selectizeInput("Study",
        label = "Study",
        choices = sort(unique(df$Study)),
        selected = NULL,
        multiple = TRUE,
        options = list(placeholder = 'All studies')
      )
    ),

    column(
      3,
      selectizeInput("Cancer",
        label = "Cancer",
        choices = sort(unique(df$Cancer)),
        selected = NULL,
        multiple = TRUE,
        options = list(placeholder = 'All cancers')
      )
    ),

    column(
      4,
      textAreaInput("Genes",
        label = "Genes",
        placeholder = "GeneA,GeneB,GeneC..."
      )
    )
  ),

  fluidRow(
    column(
      2,
      # button for table export
      downloadButton("downloadData",
        label = "Download"
      )
    )
  ),

  hr(),

  dataTableOutput("searchTable")

)

################################################################################

# server setup for app
server <- function(input, output) {
  # inputs are fed to a reactive function to setup for filtering
  Species.values <- reactive({
    if (is.null(input$Species)) {
      return(c("Mouse", "Human", "Rat", "Fly", "Fish", "Yeast"))
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
    #if (input$Genes == "") {
    if (input$Genes == "") {
      # the gene value input is setup to allow for different delims
      #return(unlist(strsplit(as.character(df[, 1]), " ")))
      return(unlist(strsplit(as.character(df$MouseName), " ")))
    } else {
      return(input$Genes)
    }
  })

################################################################################

  # the output of the reactive inputs are assigned to a variables after filtering
  # to be sent to the respective table
  filtered.search <- reactive({
    return(df %>%
      filter_at(
        vars(MouseName:YeastId),
        any_vars(tolower(.) %in% tolower(
          # this regex fun allows for different delims on input
          unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))))
     # filter(
     #   Cancer %in% Cancer.values(),
     #   # the towlower implementation allows for case insensitivity for gene inputs
     #   #tolower(df[, 1]) %in% tolower(
     #     # this regex fun allows for different delims on input
     #     #unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
     #   ),
     #   Study %in% Study.values()
      ))
  })


#filter_all(genes, any_vars(. == "ERG10"))





################################################################################

  output$searchTable <- renderDataTable({
#     speciesName <- sym(paste0(quo_name(Species.values()), "Name"))
#      speciesId <- sym(paste0(quo_name(Species.values()), "Id"))

      filtered.search() %>%
##        mutate(!!speciesName := paste0(
##          "<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",
##          !!speciesName, "' target='_blank'>", !!speciesName, "</a>"
##        )) %>%
##        mutate(!!speciesId := paste0(
##          "<a href='https://www.ncbi.nlm.nih.gov/gene/",
##          !!speciesId, "' target='_blank'>", !!speciesId, "</a>"
##        )) %>%
#        mutate(COSMIC = if_else(tolower(COSMIC) == "true", paste0(
#          "<a href='https://cancer.sanger.ac.uk/cosmic/gene/analysis?ln=",
#          HumanName, "' target='_blank'>", tolower(COSMIC), "</a>"
#        ), "false")) %>%
##        mutate(HumanId = paste0(
##          "<a href='https://www.ncbi.nlm.nih.gov/gene/",
##          HumanId, "' target='_blank'>", HumanId, "</a>"
##        )) %>%
##        mutate(HumanName = paste0(
##          "<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",
##          HumanName, "' target='_blank'>", HumanName, "</a>"
##        )) %>%
#        mutate(homologId = paste0(
#          "<a href='https://www.ncbi.nlm.nih.gov/homologene/?term=",
#          homologId, "' target='_blank'>", homologId, "</a>"
#        )) %>%
#        mutate(Study = paste0(
#          "<a href='https://www.ncbi.nlm.nih.gov/pubmed/?term=",
#          PubMedId, "' target='_blank'>", Study, "</a>"
#        )) %>%
#        mutate(CISAddress = paste0(
#          "<a href='",
#          "http://genome.ucsc.edu/cgi-bin/hgTracks?db=mm10&lastVirtModeType=default&",
#          "lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&",
#          "position=",
#          CISAddress,
#          "&hgsid=778514051_gvmjIrgAGh0FwdOmrMCVYF6QcIFD' target='_blank'>", CISAddress, "</a>"
#        )) %>%
        select_if(
          #contains(Species.values()),
          matches(Species.values()),
          #MouseName,
          #HumanName,
          #HumanId,
          homologId:Studies
        )
    },
    extensions = "Buttons",
    options = list(
      dom = "Brpti",
      columnDefs = list(list(visible = FALSE, targets = c(2, 4:7, 9, 11))),
      buttons = list(list(extend = "colvis", columns = c(2, 4:7, 9, 11)))
    ),
    rownames = FALSE,
    style = "bootstrap",
    escape = FALSE
  )

#  output$downloadData <- downloadHandler(
#    filename = function() {
#      paste0("ccgd_export_", Sys.Date(), ".csv", sep = "")
#    },
#    content = function(con) {
#      write.csv(df %>%
#        filter(
#          Cancer %in% Cancer.values(),
#          tolower(df[, 1]) %in% tolower(
#            unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))
#          ),
#          Study %in% Study.values()
#        )
#      , con,
#      row.names = F
#      )
#    }
#  )
}

shinyApp(ui, server)
