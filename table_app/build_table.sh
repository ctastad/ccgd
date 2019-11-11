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

# cleanup
echo "Cleaning up"
rm homologene.*
echo "App redeployment complete"

