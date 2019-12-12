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
while getopts b:t:r:s:c: option
do
    case "${option}"
        in
        b) build=${OPTARG};;
        t) table=${OPTARG};;
        r) refs=${OPTARG};;
        s) sync=${OPTARG};;
        c) checkout=${OPTARG};;
    esac
done

# point to project dir
root=/swadm/var/www/ccgd
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

# set var for current git branch
curBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

# execute git push
cd $scriptDir/..
if [ -z "$checkout" ]
then
    echo "Starting local git push pull"
    git checkout master
    git add .
    git diff-index --quiet HEAD || git commit -am "source file upload"
    git pull origin master
    git push origin master
    git checkout $curBranch
else
    # custom branch specified
    echo "Starting local git push pull"
    git checkout $checkout
    git add .
    git diff-index --quiet HEAD || git commit -am "source file upload"
    git pull origin $checkout
    git push origin $checkout
    git checkout $curBranch
fi

# backup script to run server-side git pull
ssh swadm@hst-ccgd-prd-web.oit.umn.edu \
    $root/scripts/backup.sh manualMode

# sync project dir contents to ccgd server
cd $scriptDir/..

if [[ $sync == "TRUE" ]]
then
    echo "Executing full project dir sync"
    rsync -ah \
        ./* \
        swadm@hst-ccgd-prd-web.oit.umn.edu:$root
    echo "Sync complete"
else
    echo "Skipping dir sync"
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
