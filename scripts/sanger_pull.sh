#!/bin/bash

################################################################################
#
#   File:   sanger_pull.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-25
#
#   Function:   This script performs the source file download from Sanger for
#               the COSMIC and cancer gene census exports.
#   Requires:   Sanger JSON auth token /table_app/json_token_cosmic.txt
#   Executed:   server-side
#
################################################################################

set -euo pipefail

function on_failure {
    echo "${0##*/}" "has failed"
    echo "The script" "${0##*/}" "has failed" |
        mail -s "CCGD Script Failure `date +%Y-%m-%d_%R`" ctastad@gmail.com
}

trap on_failure ERR

cd /swadm/var/www/ccgd/table_app
token=$(<json_token_cosmic.txt)

# perform cgc source download and trim
curl -H "Authorization: Basic $token" \
    https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v90/cancer_gene_census.csv |
    sed -e 's/.*url\"\:\(.*\)\}.*/\1/' |
    xargs curl |
    cut -d "," -f 1 > cgc_trim.txt

# perform cosmic source download and trim
curl -H "Authorization: Basic $token" \
    https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v90/CosmicMutantExport.tsv.gz |
    sed -e 's/.*url\"\:\(.*\)\}.*/\1/' |
    xargs curl |
    gunzip |
    cut -f 1 | awk '$1 !~ /_ENST/' > cosmic_trim.txt

echo "${0##*/}" "is complete `date +%Y-%m-%d_%R`"
