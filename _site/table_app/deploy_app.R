#!/usr/bin/env Rscript

library(rsconnect)
library(shiny)

deployApp(appDir = getwd(), forceUpdate = T, launch.browser = F)
