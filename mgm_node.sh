#!/bin/bash

# OS: linux 64bit
# mysql-cluster7.5

# check config.ini
echo "Check config.ini..."
cfg_file="./config.ini"
if [ -f "$cfg_file" ]
then
  echo "ok"
else
  echo "ERROR: config.ini not found."
  exit
fi

confirm=""
while [[ ! "$confirm" =~ ^[Y|y|N|n] ]]
do
  read -p "Do you want to install ndb_mgmd env ? [y/n]" confirm
  if [[ "$confirm" =~ ^[N|n] ]]; then
    echo "Exit installation."
    exit
  fi
done

cd /var/tmp
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.5/mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64.tar.gz
tar -zxvf mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64.tar.gz
cd mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64
cp bin/ndb_mgm* /usr/local/bin
cd /usr/local/bin
chmod +x ndb_mgm*
mkdir -p /var/lib/mysql-cluster
scp ./config.ini /var/lib/mysql-cluster
mkdir -p /usr/local/mysql/mysql-cluster
/usr/local/bin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini --initial
