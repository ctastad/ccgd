library(tidyverse)

df <- read.csv("ccgd_export.csv")

ortho <- read.delim("../../pl/orthologs.txt", sep = "\t", header = T)

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
  filter(gId %in% df$Mouse.ID)

uniqueHomogs <- homogs %>%
  filter(taxId %in% taxIds & homologId %in% sourceList$homologId) %>%
  distinct(homologId, taxId, .keep_all = T) %>%
  mutate(key = paste0(homologId, "_0"))

dupHomogs <- homogs %>%
  filter(
    !gId %in% uniqueHomogs$gId,
    taxId %in% taxIds & homologId %in% sourceList$homologId
  ) %>%
  mutate(key = paste0(homologId, "_", gId))

wideTable <- uniqueHomogs %>%
  bind_rows(dupHomogs) %>%
  select(key, homologId, taxId, gId, gName) %>%
  pivot_wider(
    names_from = taxId,
    values_from = c(gId, gName)
  )

for (i in 1:length(species)) {
  names(wideTable) <- gsub(
    x = names(wideTable),
    pattern = taxIds[i],
    replacement = species[i]
  )
}

tmp <- wideTable %>%
  group_by(homologId) %>%
  filter(n() > 1) %>%
  fill(gId_Mouse:gName_Yeast) %>%
  ungroup()

finTable <- wideTable %>%
  group_by(homologId) %>%
  filter(n() == 1) %>%
  bind_rows(tmp) %>%
  arrange(homologId) %>%
  select(everything(), homologId, -key)





# create base table assigning human gene ID to source mouse ID
ccgd_table <- upload %>%
  inner_join(ortho, by = c("mouse_id" = "Other_GeneID")) %>%
  select(Mouse = mouse_id, Human = GeneID)

# join by orthologs of human gene ID
for (i in c(taxIds[otherTaxIds])) {
  j <- quo_name(i)
  ccgd_table <- ccgd_table %>%
    inner_join(filter(ortho, Other_tax_id == i),
      by = c("Human" = "GeneID")
    ) %>%
    select(-c(relationship, tax_id, Other_tax_id), !!j := Other_GeneID)
}

names(ccgd_table)[1:length(ccgd_table)] <- c(species[activeSpecies])

# incorporate homologene data to each species
for (i in rev(species[activeSpecies])) {
  j <- quo_name(i)
  k <- quo_name("gene_id")
  geneName <- paste0(j, "Name")
  homogs <- homogs %>%
    rename(!!j := !!k)
  ccgd_table <- ccgd_table %>%
    inner_join(homo) %>%
    select(!!j, !!geneName := gene_name, everything())
  homogs <- homogs %>%
    rename(!!k := !!j)
}
