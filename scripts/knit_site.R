#!/usr/bin/env Rscript

################################################################################
#
#   File:   knit_site.R
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This script performs an rmarkdown html knit to generate all
#               base web files for the Candidate Cancer Gene Database website. 
#   Requires:   RMarkdown library, pandoc, x11 graphics, a yaml header, several
#               support dirs (img, styles, table_app), markdown source files
#               (index.Rmd, search.Rmd, help.Rmd, references.Rmd, contact.Rmd)
#   Executed:   locally within an R environment
#
################################################################################


setwd("..")

# render core webpages
rmarkdown::render("index.Rmd", encoding="UTF-8")
rmarkdown::render("search.Rmd")
rmarkdown::render("help.Rmd")
rmarkdown::render("references.Rmd")
rmarkdown::render("contact.Rmd")
rmarkdown::render_site("index.Rmd")

