library(tidyverse)

df <- read.csv("ccgd_export.csv")
upload <- data.frame(df$Mouse.ID)


homo <- read.table("../../pl/homologene.txt", sep="\t")
colnames(homo) <- c("homologene id", "taxonomy_id", "gene_id", "gene_name", "gi_number", "refseq")
ortho <- read.table("../../pl/orthologs.txt", sep="\t", header=T)
