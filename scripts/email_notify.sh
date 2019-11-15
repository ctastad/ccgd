#!/bin/bash

################################################################################
#
#   File:   ccgd_upload.sh
#   Author: Christopher Tastad (tasta005)
#   Group:  Starr Lab - University of Minnesota
#   Date:   2019-10-13
#
#   Function:   This script combines several disparate steps in the process of
#               uploading files to the Candidate Cancer Gene Database server.
#               The intention is to simplify the process of introducing new data
#               While bringing the server current and complete.
#   Requires:   knit_site.R, site_backup.sh, table_backup.sh, key access to the
#               CCGD server, build_table.sh, Optional (ccgd_export.csv,
#               ccgd_refs.bib upload files)
#   Executed:   locally from the CCGD project dir
#   Options:    -b build (TRUE,FALSE) -t table upload file -r reference upload
#               file
#
################################################################################

header=$(cat <<EOF
The most recent table build was completed on:

EOF

cat ../_site/table_app/build_date.txt

cat <<EOF


This should match the current date. If it does not, the build has failed.





Sincerely,

The CCGD email bot
EOF
)

echo "${header}" | mail -s "CCGD Health Check `date +%Y-%m-%d`" ctastad@gmail.com

