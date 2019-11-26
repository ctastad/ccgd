#!/bin/bash

################################################################################
#
#   File:   ccgd_upload.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-25
#
#   Function:   This script combines several disparate steps in the process of
#               uploading files to the Candidate Cancer Gene Database server.
#               The intention is to simplify the process of introducing new data
#               While bringing the server current and complete.
#   Requires:   knit_site.R, backup.sh, key access to the
#               CCGD server, build_table.sh, Optional (ccgd_export.csv,
#               ccgd_refs.csv upload files)
#   Executed:   locally from the CCGD project dir
#   Options:    -b build (TRUE,FALSE) -f full proj dir sync (TRUE,FALSE)
#               -t table upload file -r reference upload file
#
################################################################################


# pass arguments from cli
while getopts b:t:r:f: option
do
    case "${option}"
        in
        b) build=${OPTARG};;
        t) table=${OPTARG};;
        r) refs=${OPTARG};;
        f) fullSync=${OPTARG};;
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
    cp $refs $scriptDir/../refs/ccgd_refs.csv
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
    vm_application \
    refs/* \
    table_app/*

cd $scriptDir/..

cp table_app/ccgd_export.csv table_app/legend.csv _site/table_app
cp refs/ccgd_refs.csv refs/ccgd_paper.bib _site/refs

# backup site root dir and source files server-side
ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
    $root/scripts/backup.sh


# sync project dir contents to ccgd server
cd $scriptDir/..

if [[ $fullSync == "TRUE" ]]
then
    # all files synced
    echo "Executing full project dir sync"
    rsync -ah \
        ./* \
        swadm@hst-ccgd-prd-web.oit.umn.edu:$root
    echo "Sync complete"
elif [ -z "$refs" ] || [ -z "$table" ]
then
    # only site root synced - no source files
    echo "Executing partial project dir sync - site root only"
    rsync -ah \
        _site \
        --exclude '_site/refs/ccgd_refs.csv' \
        --exclude '_site/table_app/ccgd_export.csv' \
        swadm@hst-ccgd-prd-web.oit.umn.edu:$root
    echo "Sync complete"
else
    # only site root and source file synced
    echo "Executing partial project dir sync - site root and source files only"
    rsync -ahR \
        _site \
        refs/ccgd_refs.csv \
        table_app/ccgd_export.csv \
        swadm@hst-ccgd-prd-web.oit.umn.edu:$root
    echo "Sync complete"
fi


# rebuild table server-side
if [[ $build == "TRUE" ]]
then
    ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
        $root/scripts/build_table.sh
else
    echo "Skipping app rebuild"
fi

echo "All processes complete"
