#!/bin/bash

################################################################################
#
#   File:   table_backup.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This script performs a simple file copy of critical source files
#               for the Candidate Cancer Gene Database to a site outside the 
#               site directory.
#   Requires:   ccgd_export.csv, ccgd_refs.bib
#   Executed:   server-side
#
################################################################################


root=/swadm/var/www
cd $root/backup/site


echo "Starting backup of CCGD source file and bibliography"

cp $root/html/table_app/ccgd_export.csv \
    $root/backup/table/ccgd_table_$(date +%Y%m%d).csv

cp $root/html/refs/ccgd_refs.bib \
    $root/backup/table/ccgd_refs_$(date +%Y%m%d).bib

echo "Backup of source files complete"

