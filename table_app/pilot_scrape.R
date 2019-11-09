library(tidyverse)

df <- read.csv("ccgd_export_full.csv") %>%
    select(homologId:Cancer)

cgc <- read.delim("../../pl/cgc.txt", sep = ",", header = T)

homogs <- read.delim("../../pl/homologene.txt",
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

activeSpecies <- c(1:4)
# Mouse (1) and Human (2) are skipped in loop due to earlier processing step
otherTaxIds <- c(3:4)

sourceList <- homogs %>%
  filter(
         homologId %in% df$homologId &
         taxId %in% taxIds
     )

uniqueHomogs <- sourceList %>%
  distinct(homologId, taxId, .keep_all = T) %>%
  mutate(key = paste0(homologId, "_0"))

dupHomogs <- sourceList %>%
  filter( !gId %in% uniqueHomogs$gId,) %>%
  mutate(key = paste0(homologId, "_", gId))

homogTable <- uniqueHomogs %>%
  bind_rows(dupHomogs) %>%
  select(
         key,
         homologId,
         taxId,
         gId,
         gName) %>%
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

tmp <- homogTable %>%
  group_by(homologId) %>%
  filter(n() > 1) %>%
  fill(gId_Mouse:gName_Yeast) %>%
  ungroup()

homogTable <- homogTable %>%
  group_by(homologId) %>%
  filter(n() == 1) %>%
  bind_rows(tmp) %>%
  ungroup() %>%
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
         -key)

export <- homogTable %>%
    full_join(df) %>%
    group_by(MouseId) %>%
    distinct(Study, .keep_all = T) %>%
    add_count(name = "Studies")

searchTable <- export %>%
    select(
           MouseName:YeastId,
           Study,
           Effect,
           Rank,
           Cancer,
           Studies
           )

write.csv(export, file = "ccgd_export_full.csv", row.names = F)
write.csv(searchTable, file = "ccgd_search.csv", row.names = F)

#ortho <- read.delim("../../pl/orthologs.txt", sep = "\t", header = T)
#
## create base table assigning human gene ID to source mouse ID
#orthoTable <- df %>%
#  select(MouseId) %>%
#  inner_join(ortho, by = c("MouseId" = "Other_GeneID")) %>%
#  select(Mouse = MouseId, Human = GeneID)
#
## join by orthologs of human gene ID
#for (i in c(taxIds[otherTaxIds])) {
#  j <- quo_name(i)
#  orthoTable <- orthoTable %>%
#    inner_join(filter(ortho, Other_tax_id == i),
#      by = c("Human" = "GeneID")
#    ) %>%
#    select(-c(relationship, tax_id, Other_tax_id), !!j := Other_GeneID)
#}
#
#names(orthoTable)[1:length(orthoTable)] <- c(species[activeSpecies])
#
## incorporate homologene data to each species
#for (i in rev(species[activeSpecies])) {
#  j <- quo_name(i)
#  k <- quo_name("gId")
#  geneName <- paste0(j, "Name")
#  tmpHomogs <- homogs %>%
#    rename(!!j := !!k) %>%
#    select(!!j, gName)
#  orthoTable <- orthoTable %>%
#    inner_join(tmpHomogs) %>%
#    select(!!j, !!geneName := gName, everything())
#}
