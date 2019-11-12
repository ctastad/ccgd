#!/bin/bash


cd /swadm/var/www/backup/site


echo "Starting backup of site directory root"

tar -czf site_root_backup_$(date +%Y%m%d).tar.gz \
    /swadm/var/www/html

echo "Backup of site files complete"

