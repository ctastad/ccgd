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
#               site directory.
#   Requires:   existence of the swadm site dir
#   Executed:   server-side
#
################################################################################


cd /swadm/var/www/backup/site


echo "Starting backup of site directory root"

tar -czf site_root_backup_$(date +%Y%m%d).tar.gz \
    /swadm/var/www/html

echo "Backup of site files complete"

