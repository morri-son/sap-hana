#!/bin/bash

set -e

if [ $# -eq 0 ]; then

file="./parameters.conf"

function prop {
    grep "${1}" ${file} | cut -d'=' -f2
}

  sid = ${prop 'sid'}
  instance = ${prop 'instance'}
  hana_url = ${prop 'hana_url'}
  sapcar_url = ${prop 'sapcar_url'}

  echo $sid
  echo $instance
  echo $hana_url
  echo $sapcar_url
else
  sid = $1
  instance = $2
  hana_url = $3
  sapcar_url = $4
fi

echo 
zypper --non-interactive refresh
zypper --non-interactive install curl vim libaio libnuma1 libltdl7 libatomic1 syslog hwinfo sudo tar psmisc wget insserv-compat
zypper clean

mkdir -p /usr/sap
mkdir /install

cd /install

curl -sSf -o hana.sar "$hana_url"
curl -sSf -o sapcar "$sapcar_url"
chmod a+x sapcar
./sapcar -xvf hana.sar
rm -f hana.sar

hana_dir=SAP_HANA_DATABASE
cd "$hana_dir"

master_port=3"$instance"13

timeout -k 2 3600 ./hdblcm \
  --batch \
  --action=install \
  --components=server \
  --sid "$sid" \
  --number="$instance" \
  --sapmnt=/hana/shared \
  --datapath=/hana/data \
  --logpath=/hana/log \
  -sapadm_password Init1234 \
  -password Init1234 \
  -system_user_password manager \
  --hdbinst_server_ignore=check_min_mem,check_platform,check_diskspace \
  --custom_cfg=/build/scripts/custom_config \
  --ignore=check_signature_file \
  $additional_parameters

cat > /root/passwords.xml <<-END
<?xml version="1.0" encoding="UTF-8"?>
<Passwords>
<password><![CDATA[Init1234]]></password>
<sapadm_password><![CDATA[Init1234]]></sapadm_password>
</Passwords>
END

sidadm=$(echo $sid| tr '[:upper:]' '[:lower:]')adm

sudo -i -u $sidadm hdbuserstore set SYSTEM 127.0.0.1:$master_port SYSTEM manager

# cp /build/files/init.sh /init.sh
# chmod 755 /init.sh

# sed -i s/__SID__/$sid/g /init.sh
# sed -i s/__INSTANCE__/$instance/g /init.sh
# sed -i s/__SIDADM__/$sidadm/g /init.sh

rm -rf /build/data/*

exit 0

