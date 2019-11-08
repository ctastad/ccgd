library(tidyverse)

df <- read.csv("ccgd_export.csv")
upload <- data.frame(Mouse.ID = df$Mouse.ID)

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

#ortho <- read.delim("../../pl/orthologs.txt", sep = "\t", header = T)

species <- c("Mouse", "Human", "Rat", "Fish", "Fly", "Yeast")
taxIds <- c(10090, 9606, 10116, 7955, 7227, 4932)
#activeSpecies <- c(1:4)
# Mouse (1) and Human (2) are skipped in loop due to earlier processing step
#otherTaxIds <- c(3:4)

sourceList <- homogs %>%
  filter(gId %in% upload$Mouse.ID)

homogs <- homogs %>%
  filter(taxId %in% taxIds & homologId %in% sourceList$homologId)

uniqueHomogs <- homogs %>%
    distinct(homologId, taxId, .keep_all = T) %>%
    mutate(key = paste0(homologId, "_0"))

dupHomogs <- homogs %>%
  filter(!gId %in% uniqueHomogs$gId) %>%
  mutate(key = paste0(homologId, "_", gId))


wideTable <- uniqueHomogs %>%
    bind_rows(dupHomogs) %>%
    select(key, homologId, taxId, gId, gName) %>%
    arrange(homologId) %>%
  pivot_wider(
              names_from = taxId,
              values_from = c(gId, gName)
              )

for(i in 1:length(species)) {
        names(wideTable) <- gsub(
                           x = names(wideTable),
                           pattern = taxIds[i],
                           replacement = species[i])
}




tmp <- wideTable %>%
    group_by(homologId) %>%
    filter(n() > 1)












grouped <- homogs %>%
    group_by(homologId, taxId) %>%
    mutate(
           key = if(n() == 1)
           paste0(homologId, "_0")
       else paste0(homologId, "_", gId
                   )
       )


wholeTable <- keyedHomogs %>%




uniqueTable <- homogs %>%
  filter(taxId %in% taxIds & homologId %in% sourceList$homologId,
         gId %in% uniqueHomogs$gId) %>%
  #distinct(homologId, taxId, .keep_all = T) %>%
  select(homologId, taxId, gId, gName) %>%
  pivot_wider(
              names_from = taxId,
              values_from = c(gId, gName))






  #distinct(homologId, taxId, .keep_all = T) %>%
  pivot_wider(
              names_from = taxId,
              values_from = c(gId, gName))

  spread(taxId, gId)


  select(homologId, taxId, gId, gName) %>%
  pivot_wider(
              names_from = taxId,
              names_prefix = "",
              values_from = c(gId, gName))



geneId_table <- geneId_table %>%
  #filter(taxId %in% taxIds & homologId %in% sourceList$homologId) %>%
  #filter(taxId %in% taxIds) %>%
  #select(homologId, taxId, geneId, geneName)
  spread(taxId, geneName)
  rename(
    MouseId = "10090",
    HumanId = "9606",
    RatId = "10116",
    FishId = "7955",
    FlyId = "7227",
    YeastId = "4932"
  )

joined <- geneId_table %>%
  inner_join(geneName_table) %>%
  filter(MouseId %in% sourceList$geneId)








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
