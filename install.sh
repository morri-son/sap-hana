#!/bin/bash

set -e

sid=AWS

# zypper --non-interactive refresh
# zypper --non-interactive install libaio libnuma1 libltdl7 libatomic1 syslog hwinfo sudo psmisc insserv-compat
# zypper clean

mkdir -p /usr/sap

cd /install
chmod a+x SAPCAR

cd /install/rev64
/install/SAPCAR -xvf SAP_HANA_DATABASE200_64_Linux_on_x86_64.SAR
rm SAP_HANA_DATABASE200_64_Linux_on_x86_64.SAR

hana_dir=SAP_HANA_DATABASE
cd "$hana_dir"

master_port=30013

timeout -k 2 3600 ./hdblcm \
  --batch \
  --action=install \
  --components=server \
  --sid AWS \
  --number=00 \
  --sapmnt=/hana/shared \
  --datapath=/hana/data \
  --logpath=/hana/log \
  -sapadm_password Init1234 \
  -password Init1234 \
  -system_user_password manager \
  --hdbinst_server_ignore=check_min_mem,check_platform,check_diskspace \
  --ignore=check_signature_file

cat > /root/passwords.xml <<-END
<?xml version="1.0" encoding="UTF-8"?>
<Passwords>
<password><![CDATA[Init1234]]></password>
<sapadm_password><![CDATA[Init1234]]></sapadm_password>
</Passwords>
END

sidadm=$(echo $sid| tr '[:upper:]' '[:lower:]')adm

sudo -i -u $sidadm hdbuserstore set SYSTEM 127.0.0.1:$master_port SYSTEM manager

exit 0