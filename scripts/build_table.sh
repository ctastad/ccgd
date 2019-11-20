#!/bin/bash

################################################################################
#
#   File:   build_table.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This bash script combines the processes of the required data
#               pull and table build for the Candidate Cancer Gene Database.
#               This script will perform a source file backup prior to init.
#   Requires:   build_table.R, table_backup.sh, site_backup.sh
#   Executed:   server-side
#
################################################################################

set -e

cd /swadm/var/www/html/scripts

# backup CCGD source files prior to build
./backup.sh

# download reference data for homology
echo "Downloading homology reference data"
wget ftp://ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data
mv homologene.data homologene.txt

# construct table
echo "Running build_table.R"
Rscript build_table.R
echo "Table construction process complete"

# create table build age reference
stat -c %Y ../table_app/ccgd_export.csv | \
    awk '{print strftime("%B %d %Y", $1)}' > \
    ../_site/build_date.txt

# cleanup
echo "Cleaning up"
rm homologene.*
echo "App redeployment complete"

