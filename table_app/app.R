################################################################################
#
#   File:   app.R
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-21
#
#   Function:   This is the source file for the shiny table backend of the
#               Candidate Cancer Gene Database.
#   Requires:   ccgd_export.csv, libraries(shiny, DT, dplyr, rsconnect)
#   Executed:   server-side
#
################################################################################


library(shiny) # library to deploy shiny table app
library(DT) # library to employ datatables javascript library
library(dplyr) # library for tidy code
library(rsconnect) # library for shiny app deployment

################################################################################

df <- read.csv("ccgd_export.csv") # read in base source file
speciesList <- c("Mouse", "Human", "Rat", "Fly", "Fish", "Yeast")

# inputs are arranged in column, width orientation
# each column variable set represents a single input and its params
# next row of inputs layout
ui <- fluidPage( # build shiny app UI
  fluidRow(
    column(
      2,
      selectizeInput("Species",
        label = "Species",
        choices = speciesList
      )
    ),

    column(
      3,
      selectizeInput("Study",
        label = "Study",
        choices = sort(unique(df$Study)),
        selected = NULL,
        multiple = TRUE,
        options = list(placeholder = "All studies")
      )
    ),

    column(
      3,
      selectizeInput("Cancer",
        label = "Cancer",
        choices = sort(unique(df$Cancer)),
        selected = NULL,
        multiple = TRUE,
        options = list(placeholder = "All cancers")
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

server <- function(input, output) { # server setup for app
  # inputs are fed to a reactive function to setup for filtering
  Species.values <- reactive({
    if (is.null(input$Species)) {
      return(speciesList)
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
      return(unlist(strsplit(as.character(df$MouseName), " ")))
    } else {
      return(input$Genes)
    }
  })

  ################################################################################

  # the output of the reactive inputs are assigned to a variables after filtering
  filtered.search <- reactive({
    return(df %>%
      filter(
        Cancer %in% Cancer.values(),
        Study %in% Study.values()
      ) %>%
      filter_at(
        vars(contains(Species.values())),
        any_vars(tolower(.) %in%
          # this regex fun allows for different delims on input
          tolower(unlist(strsplit(gsub("[\r\n]", ",", Gene.values()), ","))))
      ))
  })

  ################################################################################

  output$searchTable <- renderDataTable( # output generated for table
    {
      geneCardLink <- function(x) {
        ifelse(!is.na(x),
          paste0(
            "<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",
            x, "' target='_blank'>", x, "</a>"
          ), x
        )
      }

      filtered.search() %>%
        mutate(COSMIC = if_else(tolower(COSMIC) == "true", paste0(
          "<a href='https://cancer.sanger.ac.uk/cosmic/gene/analysis?ln=",
          HumanName, "' target='_blank'>", tolower(COSMIC), "</a>"
        ), "false")) %>%
        mutate(CGC = if_else(tolower(CGC) == "true", paste0(
          "<a href='https://cancer.sanger.ac.uk/cosmic/gene/analysis?ln=",
          HumanName, "' target='_blank'>", tolower(CGC), "</a>"
        ), "false")) %>%
        mutate(homologId = paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/homologene/?term=",
          homologId, "' target='_blank'>", homologId, "</a>"
        )) %>%
        mutate(Study = paste0(
          "<a href='http://hst-ccgd-prd-web.oit.umn.edu/references.html#",
          Study, "' target='_blank'>", Study, "</a>"
        )) %>%
        mutate(PubMedId = paste0(
          "<a href='https://www.ncbi.nlm.nih.gov/pubmed/?term=",
          PubMedId, "' target='_blank'>", PubMedId, "</a>"
        )) %>%
        mutate(CISAddress = paste0(
          "<a href='",
          "http://genome.ucsc.edu/cgi-bin/hgTracks?db=mm10&lastVirtModeType=",
          "default&lastVirtModeExtraState=&virtModeType=default&virtMode=",
          "0&nonVirtPosition=&position=",
          CISAddress,
          "&hgsid=778514051_gvmjIrgAGh0FwdOmrMCVYF6QcIFD' target='_blank'>",
          CISAddress, "</a>"
        )) %>%
        mutate_at(vars(ends_with("Name")), geneCardLink)
    },
    extensions = "Buttons",
    options = list(
      dom = "Brpit",
      columnDefs = list(list(
        visible = FALSE,
        targets = c(1, 3:11, 13:14, 16, 18)
      )),
      buttons = list(list(
        extend = "colvis",
        columns = c(1, 3:11, 13:14, 16, 18)
      ))
    ),
    selection = "none",
    rownames = FALSE,
    style = "bootstrap",
    escape = FALSE
  )

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("ccgd_export_", Sys.Date(), ".csv")
    },
    content = function(con) {
      write.csv(filtered.search(), con,
        row.names = F
      )
    }
  )
}

shinyApp(ui, server)
