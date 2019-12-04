#!/bin/bash

################################################################################
#
#   File:   site_backup.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-25
#
#   Function:   This script performs a full site dir compressions and backup
#               for the Candidate Cancer Gene Database to a site outside the
#               site directory. In addition, it also performs a simple file copy
#               of critical source files.
#   Requires:   existence of the swadm site dir
#   Executed:   server-side
#
################################################################################

set -eo pipefail

function on_failure {
    echo "${0##*/}" "has failed"
    echo "The script" "${0##*/}" "has failed" |
        mail -s "CCGD Script Failure `date +%Y-%m-%d`" ctastad@gmail.com
}

trap on_failure ERR

root=/swadm/var/www
cd $root/backup/site

echo "Starting backup of CCGD source file and bibliography"
cp $root/ccgd/table_app/ccgd_export.csv \
    $root/backup/source_files/table/ccgd_table_$(date +%Y%m%d).csv
cp $root/ccgd/refs/ccgd_refs.csv \
    $root/backup/source_files/refs/ccgd_refs_$(date +%Y%m%d).csv
echo "Backup of source files complete"

echo "Starting backup of site directory root"
tar -czf proj_root_archive_$(date +%Y%m%d).tar.gz \
    /swadm/var/www/ccgd
echo "Backup of project files complete"
tar -czf site_root_backup_$(date +%Y%m%d).tar.gz \
    /swadm/var/www/ccgd
echo "Backup of site files complete"

echo "Backup process complete"
echo "Syncronizing backup dir with offsite server"
rsync -ah \
    /swadm/var/www/backup/* \
    swadm@hst-starrnotes-prd-web.oit.umn.edu:/swadm/var/www/backup/ccgd \
    --delete-after
# clear out old files at offsite backup directory
ssh swadm@hst-starrnotes-prd-web.oit.umn.edu \
    /swadm/var/www/backup/ccgd/clear_files.sh
echo "Offsite sync complete"

echo "Clearing out old files"
find /swadm/var/www/backup/source_files -type f -mtime +180 -exec rm -f {} \;
find /swadm/var/www/backup/site -type f -mtime +180 -exec rm -f {} \;

# execute git push
cd $root/ccgd
echo "Starting server-side git push pull"
if [ -z "$1" ]
then
    git checkout master
    git add .
    git commit -am "auto backup push"
    git pull origin master
    git push origin master
else
    # custom branch specified
    git checkout $1
    git add .
    git commit -am "auto backup push"
    git pull origin $1
    git push origin $1
fi

echo "All archive processes complete"


