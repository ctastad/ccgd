#!/bin/bash

cd /swadm/var/www/html/table_app

# download reference data for homology
echo "Downloading homology reference data"
wget ftp://ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data
mv homologene.data homologene.txt

# construct table
echo "Running build_table.R"
Rscript build_table.R
echo "Table construction process complete"

# create table build age reference
stat -c %Y /swadm/var/www/html/table_app/ccgd_export.csv | \
    awk '{print strftime("%B %d %Y", $1)}' > \
    /swadm/var/www/html/_site/table_app/table_build_date.txt

# cleanup
echo "Cleaning up"
rm homologene.*
echo "App redeployment complete"

