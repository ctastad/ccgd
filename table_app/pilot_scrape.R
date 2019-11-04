library(tidyverse)

df <- read.csv("ccgd_export.csv")


homo <- read.table("../../pl/homologene.txt", sep="\t")
colnames(homo) <- c("homologene_id", "taxonomy_id", "gene_id", "gene_name", "gi_number", "refseq")
ortho <- read.table("../../pl/orthologs.txt", sep="\t", header=T)
