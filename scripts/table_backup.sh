#!/bin/bash

root=/swadm/var/www
cd $root/backup/site


echo "Starting backup of CCGD source file and bibliography"

cp $root/html/table_app/ccgd_export.csv \
    $root/backup/table/ccgd_table_$(date +%Y%m%d).csv

cp $root/html/refs/ccgd_refs.bib \
    $root/backup/table/ccgd_refs_$(date +%Y%m%d).bib

echo "Backup of source files complete"

