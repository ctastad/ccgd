#!/bin/bash

################################################################################
#
#   File:   site_backup.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This script performs a full site dir compressions and backup
#               for the Candidate Cancer Gene Database to a site outside the 
#               site directory. In addition, it also performs a simple file copy
#               of critical source files.
#   Requires:   existence of the swadm site dir
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

echo "Starting backup of site directory root"


tar -czf site_root_backup_$(date +%Y%m%d).tar.gz \
    /swadm/var/www/html

echo "Backup of site files complete"
