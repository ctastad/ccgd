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
#   Options:    -b build (TRUE,FALSE) -s full proj dir sync (TRUE,FALSE)
#               -t table upload file -r reference upload file
#               -k (TURE,FALSE) render site files
#
################################################################################


# pass arguments from cli
while getopts b:t:r:s: option
do
    case "${option}"
        in
        b) build=${OPTARG};;
        t) table=${OPTARG};;
        r) refs=${OPTARG};;
        s) sync=${OPTARG};;
    esac
done

# point to project dir
root=/swadm/var/www/ccgd
servDest=swadm@hst-ccgd-prd-web.oit.umn.edu
scriptDir=$PWD

# run backup server side
ssh $servDest \
    $root/scripts/backup.sh

# transfer source files to proprer dirs
if [ -z "$table" ]
then
    echo "No table source file supplied"
else
    echo "Putting table source file in place"
    cp $table $scriptDir/../table_app/ccgd_export.csv
    scp $table $servDest:$root/table_app
    scp $table $servDest:$root/_site/table_app
fi

if [ -z "$refs" ]
then
    echo "No reference source file supplied"
else
    echo "Putting reference source file in place"
    cp $refs $scriptDir/../refs/ccgd_refs.csv
    scp $refs $servDest:$root/refs
    scp $refs $servDest:$root/_site/refs
fi

# render website locally and sync to server
echo "Rendering site"
Rscript knit_site.R
# clean site dir
cd $scriptDir/../_site
rm -rf \
    ../*.html \
    scripts \
    vm_application \
    refs/* \
    table_app/*
cd $scriptDir/..
cp table_app/ccgd_export.csv table_app/legend.csv _site/table_app
cp refs/ccgd_refs.csv refs/ccgd_paper.bib _site/refs
rsync -aPH --stats  _site $servDest:$root
echo
echo "##### Website render complete #####"
echo

# sync project dir contents to ccgd server
cd $scriptDir/..

if [[ $sync == "TRUE" ]]
then
    echo "Executing full project dir sync"
    rsync -ah \
        ./* \
        $servDest:$root
    echo
    echo "##### Sync complete #####"
    echo
else
    echo "Skipping full dir sync"
fi

# rebuild table server-side
if [[ $build == "TRUE" ]]
then
    ssh $servDest \
        $root/scripts/build_table.sh
else
    echo "Skipping app rebuild"
fi

echo
echo "##### All processes complete #####"
echo
