#!/usr/bin/env Rscript

setwd("..")

# render core webpages
rmarkdown::render("index.Rmd")
rmarkdown::render("search.Rmd")
rmarkdown::render("help.Rmd")
rmarkdown::render("references.Rmd")
rmarkdown::render("contact.Rmd")
rmarkdown::render_site("index.Rmd")


