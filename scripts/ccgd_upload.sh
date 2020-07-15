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
while getopts b:k:t:r:s:c: option
do
    case "${option}"
        in
        b) build=${OPTARG};;
        k) knit=${OPTARG};;
        t) table=${OPTARG};;
        r) refs=${OPTARG};;
        s) sync=${OPTARG};;
        g) branch=${OPTARG};;
    esac
done

# point to project dir
root=/swadm/var/www/ccgd
servDest=swadm@hst-ccgd-prd-web.oit.umn.edu
scriptDir=$PWD

# render website in rmarkdown
if [[ $knit == "TRUE" ]]
then
    Rscript knit_site.R
    echo
    echo "##### Website render complete #####"
    echo
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
else
    echo "Skipping site knit"
fi

<<<<<<< HEAD

# render website in rmarkdown
if [ -z "$knit" ]
then
    echo "Skipping site knit"
else
    Rscript knit_site.R
    echo "##### Website render complete #####"
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
fi

=======
>>>>>>> dad45049a3948c3af25e9cc729a46e3fb1372e29
# set var for current git branch
curBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

# execute git push
cd $scriptDir/..
if [ -z "$branch" ]
then
    echo "Skipping git push"
else
    # custom branch specified
    echo "Starting local git push pull"
    git checkout $branch
    git add .
    git diff-index --quiet HEAD || git commit -am "source file upload"
    git pull origin $branch
    git push origin $branch
    git checkout $curBranch
fi

# backup script to run server-side git pull
ssh $servDest \
    $root/scripts/backup.sh

# transfer source files to proprer dirs
if [ -z "$table" ]
then
    echo "No table source file supplied"
else
    echo "Putting table source file in place"
    scp $table $servDest:$root/table_app
    scp $table $servDest:$root/_site/table_app
fi

if [ -z "$refs" ]
then
    echo "No reference source file supplied"
else
    echo "Putting reference source file in place"
    scp $table $servDest:$root/refs
    scp $table $servDest:$root/_site/refs
fi

# sync project dir contents to ccgd server
cd $scriptDir/..

if [[ $sync == "TRUE" ]]
then
    echo "Executing full project dir sync"
    rsync -ah \
        ./* \
<<<<<<< HEAD
        swadm@hst-ccgd-prd-web.oit.umn.edu:$root
    echo "##### Sync complete #####"
=======
        $servDest:$root
    echo
    echo "##### Sync complete #####"
    echo
>>>>>>> dad45049a3948c3af25e9cc729a46e3fb1372e29
else
    echo "Skipping dir sync"
fi

# rebuild table server-side
if [[ $build == "TRUE" ]]
then
    ssh $servDest \
        $root/scripts/build_table.sh
else
    echo "Skipping app rebuild"
fi

<<<<<<< HEAD
echo "##### All processes complete #####"
=======
echo
echo "##### All processes complete #####"
echo
>>>>>>> dad45049a3948c3af25e9cc729a46e3fb1372e29
