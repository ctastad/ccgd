library(tidyverse)
#library(biomaRt)
#
#ensembl <- useMart("ensembl")
#
#dmelanogaster_gene_ensembl
#drerio_gene_ensembl
#scerevisiae_gene_ensembl
#rnorvegicus_gene_ensembl
#hsapiens_gene_ensembl
#mmusculus_gene_ensembl
#
#human <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
#mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")
#fly <- useMart("ensembl", dataset = "dmelanogaster_gene_ensembl")
#fish <- useMart("ensembl", dataset = "drerio_gene_ensembl")
#yeast <- useMart("ensembl", dataset = "scerevisiae_gene_ensembl")
#rat <- useMart("ensembl", dataset = "rnorvegicus_gene_ensembl")




df <- read.csv("ccgd_export.csv")
upload <- read.csv("ccgd_upload.csv")
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

ortho <- read.delim("../../pl/orthologs.txt", sep = "\t", header = T)


# ++9606 human
# --4932 yeast
# --7227 drosophila
# ++7955 zebrafish
# -+10116 rat
# ++10090 mouse

species <- c("Mouse", "Human", "Rat", "Fish", "Fly", "Yeast")
#activeSpecies <- c(1:4)
taxIds <- c(10090, 9606, 10116, 7955, 7227, 4932)
# Mouse (1) and Human (2) are skipped in loop due to earlier processing step
#otherTaxIds <- c(3:4)

sourceList <- homogs %>%
  filter(gId %in% upload$Mouse.ID)

uniqueHomogs <- homogs %>%
    distinct(homologId, taxId, .keep_all = T)





uniqueTable <- homogs %>%
  filter(taxId %in% taxIds & homologId %in% sourceList$homologId,
         gId %in% uniqueHomogs$gId) %>%
  #distinct(homologId, taxId, .keep_all = T) %>%
  select(homologId, taxId, gId, gName) %>%
  pivot_wider(
              names_from = taxId,
              names_prefix = "",
              values_from = c(gId, gName))

dupTable <- homogs %>%
  filter(taxId %in% taxIds & homologId %in% sourceList$homologId,
         !gId %in% uniqueHomogs$gId) %>%
  #distinct(homologId, taxId, .keep_all = T) %>%
  select(homologId, taxId, gId)
  spread(taxId, gId)


  select(homologId, taxId, gId, gName) %>%
  pivot_wider(
              names_from = taxId,
              names_prefix = "",
              values_from = c(gId, gName))


for(i in 1:length(species)) {
        names(tmp) <- gsub(
                           x = names(tmp),
                           pattern = taxIds[i],
                           replacement = species[i])
}

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
