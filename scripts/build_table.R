#!/usr/bin/env Rscript

################################################################################
#
#   File:   build_table.R
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-19
#
#   Function:   This script is the central etl process in building the source
#               content of the Candidate Cancer Gene Database. It takes a source
#               file input and merges that data with gene homolog data from
#               external references.
#   Requires:   ccgd_export.csv, homologene and ortholog ncbi ftp downloads,
#               libraries (tidyverse, rsconnect, shiny)
#   Executed:   server-side
#
################################################################################


library(tidyverse)
library(rsconnect)
library(shiny)

df <- read.csv("../table_app/ccgd_export.csv") %>%
  select(homologId:Cancer)

cgc <- scan("../table_app/cgc_trim.txt", "")
cosmic <- scan("../table_app/cosmic_trim.txt", "")

homogs <- read.delim("homologene.txt",
  sep = "\t",
  col.names = c(
    "homologId",
    "taxId",
    "gId",
    "gName",
    "giId",
    "refSeq"
  )
)

species <- c(
  "Mouse",
  "Human",
  "Rat",
  "Fish",
  "Fly",
  "Yeast"
)

taxIds <- c(
  10090,
  9606,
  10116,
  7955,
  7227,
  4932
)

sourceList <- homogs %>%
  filter(
    homologId %in% df$homologId &
      taxId %in% taxIds
  )

uniqueHomogs <- sourceList %>%
  distinct(homologId, taxId, .keep_all = T) %>%
  mutate(key = paste0(homologId, "_0"))

dupHomogs <- sourceList %>%
  filter(!gId %in% uniqueHomogs$gId, ) %>%
  mutate(key = paste0(homologId, "_", gId))

homogTable <- uniqueHomogs %>%
  bind_rows(dupHomogs) %>%
  select(
    key,
    homologId,
    taxId,
    gId,
    gName
  ) %>%
  pivot_wider(
    names_from = taxId,
    values_from = c(gId, gName)
  )

for (i in 1:length(species)) {
  names(homogTable) <- gsub(
    x = names(homogTable),
    pattern = taxIds[i],
    replacement = species[i]
  )
}

message("Filling NA values...This could take several minutes")

tmp <- homogTable %>%
  group_by(homologId) %>%
  filter(n() > 1) %>%
  fill(gId_Mouse:gName_Yeast)

homogTable <- homogTable %>%
  group_by(homologId) %>%
  filter(n() == 1) %>%
  bind_rows(tmp) %>%
  select(
    MouseName = gName_Mouse,
    MouseId = gId_Mouse,
    HumanName = gName_Human,
    HumanId = gId_Human,
    RatName = gName_Rat,
    RatId = gId_Rat,
    FlyName = gName_Fly,
    FlyId = gId_Fly,
    FishName = gName_Fish,
    FishId = gId_Fish,
    YeastName = gName_Yeast,
    YeastId = gId_Yeast,
    homologId,
    -key
  )

export <- homogTable %>%
  full_join(df) %>%
  group_by(MouseId) %>%
  distinct(Study, .keep_all = T) %>%
  add_count(name = "Studies") %>%
  ungroup() %>%
  mutate(CGC = HumanName %in% cgc) %>%
  mutate(COSMIC = HumanName %in% cosmic)

write.csv(export, file = "../table_app/ccgd_export.csv", row.names = F)

deployApp(appDir = "../table_app", forceUpdate = T, launch.browser = F)

# ortho <- read.delim("../../pl/orthologs.txt", sep = "\t", header = T)
#
# activeSpecies <- c(1:4)
## Mouse (1) and Human (2) are skipped in loop due to earlier processing step
# otherTaxIds <- c(3:4)
#
## create base table assigning human gene ID to source mouse ID
# orthoTable <- df %>%
#  select(MouseId) %>%
#  inner_join(ortho, by = c("MouseId" = "Other_GeneID")) %>%
#  select(Mouse = MouseId, Human = GeneID)
#
## join by orthologs of human gene ID
# for (i in c(taxIds[otherTaxIds])) {
#  j <- quo_name(i)
#  orthoTable <- orthoTable %>%
#    inner_join(filter(ortho, Other_tax_id == i),
#      by = c("Human" = "GeneID")
#    ) %>%
#    select(-c(relationship, tax_id, Other_tax_id), !!j := Other_GeneID)
# }
#
# names(orthoTable)[1:length(orthoTable)] <- c(species[activeSpecies])
#
## incorporate homologene data to each species
# for (i in rev(species[activeSpecies])) {
#  j <- quo_name(i)
#  k <- quo_name("gId")
#  geneName <- paste0(j, "Name")
#  tmpHomogs <- homogs %>%
#    rename(!!j := !!k) %>%
#    select(!!j, gName)
#  orthoTable <- orthoTable %>%
#    inner_join(tmpHomogs) %>%
#    select(!!j, !!geneName := gName, everything())
# }
