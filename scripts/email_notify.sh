#!/bin/bash

################################################################################
#
#   File:   email_notify.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-19
#
#   Function:   This script provides a periodic notification about the status of
#               the table build. It relies on a text file that is generated
#               during the build process that indicates the age of the table.
#   Requires:   build_date.txt
#   Executed:   Every Sunday server-cise
#
################################################################################

header=$(cat <<EOF
The most recent table build was completed on:

EOF

cat /swadm/var/www/ccgd/_site/build_date.txt

cat <<EOF


This should match the current date. If it does not, the build has failed.





Sincerely,

The CCGD email bot
EOF
)

echo "${header}" | mail -s "CCGD Health Check `date +%Y-%m-%d`" ctastad@gmail.com

