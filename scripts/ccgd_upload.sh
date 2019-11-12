#!/bin/bash

# pass arguments from cli
while getopts b:t:r: option
do
 case "${option}"
 in
 b) build=${OPTARG};;
 t) table=${OPTARG};;
 r) refs=${OPTARG};;
 esac
done


# point to project dir
root=/swadm/var/www/html
scriptDir=$PWD


# transfer source files to proprer dirs
if [ -z "$table" ]
then
    echo "No table source file supplied"
else
    echo "Putting table source file in place"
    cp $table $scriptDir/../table_app/ccgd_export.csv
fi

if [ -z "$refs" ]
then
    echo "No reference source file supplied"
else
    echo "Putting reference source file in place"
    cp $refs $scriptDir/../refs/ccgd_refs.bib
fi


# render website in rmarkdown
Rscript knit_site.R

echo "Website render complete"


# clean site dir
cd $scriptDir/../_site

echo "Cleaning up a bit"

rm -rf \
    ../*.html \
    pl \
    rsconnect \
    scripts \
    vm_application


# backup site root dir and source files server-side
ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
    $root/scripts/site_backup.sh

ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
    $root/scripts/table_backup.sh


# sync project dir contents to ccgd server
cd $scriptDir/..

echo "Syncing the project directory with the server"

rsync -ah \
    ./* \
    swadm@hst-ccgd-prd-web.oit.umn.edu:$root \
    --delete


# rebuild table server-side
if [ $build == "TRUE" ]
then
ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
    $root/table_app/build_table.sh
else
    echo "Skipping app rebuild"
fi

echo "All processes complete"
