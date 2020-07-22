#!/bin/bash

################################################################################
#
#   File:   build_table.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-25
#
#   Function:   This bash script combines the processes of the required data
#               pull and table build for the Candidate Cancer Gene Database.
#               This script will perform a source file backup prior to init.
#   Requires:   build_table.R, backup.sh
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

cd /swadm/var/www/ccgd/scripts

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

echo
echo "##### App redeployment complete `date +%Y-%m-%d_%R` #####"
echo
