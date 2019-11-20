#!/bin/bash

################################################################################
#
#   File:   sanger_pull.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-18
#
#   Function:
#   Requires:
#   Executed:
#
################################################################################

set -e

curl -H "Authorization: Basic Y2NnZEB1bW4uZWR1OkNhbmRpZGF0ZSFHZW5lcw==" \
    https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v90/cancer_gene_census.csv |
    sed -e 's/.*url\"\:\(.*\)\}.*/\1/' |
    xargs curl |
    cut -d "," -f 1 > ../table_app/cgc_trim.txt

curl -H "Authorization: Basic Y2NnZEB1bW4uZWR1OkNhbmRpZGF0ZSFHZW5lcw==" \
    https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v90/CosmicMutantExport.tsv.gz |
    sed -e 's/.*url\"\:\(.*\)\}.*/\1/' |
    xargs curl |
    gunzip |
    cut -f 1 | awk '$1 !~ /_ENST/' > ../table_app/cosmic_trim.txt

#rm cosmic.txt cgc.txt
