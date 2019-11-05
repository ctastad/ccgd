library(tidyverse)

df <- read.csv("ccgd_export.csv")
upload <- read.csv("ccgd_upload.csv")
upload <- data.frame(Mouse.ID = df$Mouse.ID)

homo <- read.table("../../pl/homologene.txt", sep = "\t")
homo <- homo[c(1,3,4)]
colnames(homo) <- c(
  "homologene id",
  "gene_id",
  "gene_name"
)

ortho <- read.table("../../pl/orthologs.txt", sep = "\t", header = T)

# ++9606 human
# --4932 yeast
# --7227 drosophila
# ++7955 zebrafish
# -+10116 rat
# ++10090 mouse

species <- c("Mouse", "Human", "Rat", "Zebrafish", "Fly", "Yeast")
activeSpecies <- c(1:4)
taxIds <- c(10090, 9606, 10116, 7955, 7227, 4932)
# Mouse (1) and Human (2) are skipped in loop due to earlier processing step
otherTaxIds <- c(3:4)

#tax_ids <- c(7955, 10116)
#
#  inner_join(ortho, by = c("Human.ID" = "GeneID")) %>%
#  filter(Other_tax_id %in% tax_ids) %>%
#  select(Mouse.ID, Human.ID, Other_tax_id, Other_GeneID)
#  spread(unique(Other_tax_id), Other_GeneID)

ccgd_table <- upload %>%
  inner_join(ortho, by = c("Mouse.ID" = "Other_GeneID")) %>%
  select(Mouse = Mouse.ID, Human = GeneID)

for(i in c(taxIds[otherTaxIds])){
  ccgd_table <- ccgd_table %>%
      inner_join(filter(ortho, Other_tax_id == i),
                 by = c("Human" = "GeneID")) %>%
      select(-c(relationship, tax_id, Other_tax_id))
}

names(ccgd_table)[1:length(ccgd_table)] <- c(species[activeSpecies])

for(i in c(taxIds[otherTaxIds])){
  ccgd_table %>%
      inner_join(., homo, by = c(!!i = "gene_id"))
  paste(i)
}

x <- "Mouse"
y <- "gene_id"
x <- enquo(x)
ccgd_table <- ccgd_table %>%
    inner_join(ccgd_table, homo, by = c({{x}} = "gene_id"))

