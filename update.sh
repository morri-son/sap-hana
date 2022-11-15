#!/bin/bash

set -e

cd /install/rev65
/install/sapcar -xvf SAP_HANA_DATABASE200_65_Linux_on_x86_64.SAR

hana_dir=SAP_HANA_DATABASE
cd "$hana_dir"

timeout -k 2 3600 ./hdblcm \
 --batch \
 --action=update \
 --sid=AWS \
 --system_user=SYSTEM \
 --system_user_password=manager \
 --password=Init1234 \
 -sapadm_password=Init1234 \
 --component_dirs=/update/SAP_HANA_DATABASE/ \
 --components=server
