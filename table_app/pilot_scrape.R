library(tidyverse)

df <- read.csv("ccgd_export.csv")
upload <- read.csv("ccgd_upload.csv")
upload <- data.frame(Mouse.ID = upload$mouse_id)

homo <- read.table("../../pl/homologene.txt", sep = "\t")
colnames(homo) <- c(
  "homologene id",
  "taxonomy_id",
  "gene_id",
  "gene_name",
  "gi_number",
  "refseq"
)

ortho <- read.table("../../pl/orthologs.txt", sep = "\t", header = T)

tax_ids <- c(10090, 9606, 4932, 7227, 7955, 10116)

ccgd_table <- upload %>%
  inner_join(ortho, by = c("Mouse.ID" = "Other_GeneID")) %>%
  select(Mouse.ID, Human.ID = GeneID) %>%
  inner_join(ortho, by = c("Human.ID" = "GeneID")) %>%
  filter(Other_tax_id %in% tax_ids) %>%
  select(Mouse.ID, Human.ID, Other_tax_id, Other_GeneID) %>%
  spread(Other_tax_id, Other_GeneID)
