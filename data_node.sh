#!/bin/bash

# OS: linux 64bit
# mysql-cluster7.5

# check my.cnf
echo "Check my.cnf..."
cfg_file="./my.cnf"
if [ -f "$cfg_file" ]
then
  echo "ok"
else
  echo "ERROR: my.cnf not found."
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
cp bin/ndbd /usr/local/bin/ndbd
cp bin/ndbmtd /usr/local/bin/ndbmtd
cd /usr/local/bin
chmod +x ndb*
scp ./my.cnf /etc/
mkdir -p /usr/local/mysql/data
/usr/local/bin/ndbd
