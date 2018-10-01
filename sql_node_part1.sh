#!/bin/bash

# OS: linux 64bit
# mysql-cluster7.5

confirm=""
while [[ ! "$confirm" =~ ^[Y|y|N|n] ]]
do
  read -p "Do you want to install ndbd env, part1 ? [y/n]" confirm
  if [[ "$confirm" =~ ^[N|n] ]]; then
    echo "Exit installation."
    exit
  fi
done

groupadd mysql
useradd -g mysql -s /bin/false mysql
cd /var/tmp
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.5/mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64.tar.gz
tar -C /usr/local -xzvf mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64.tar.gz
ln -s /usr/local/mysql-cluster-gpl-7.5.11-linux-glibc2.12-x86_64/ /usr/local/mysql
