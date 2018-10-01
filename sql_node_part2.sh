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
  read -p "Do you want to install ndbd env, part2 ? [y/n]" confirm
  if [[ "$confirm" =~ ^[N|n] ]]; then
    echo "Exit installation."
    exit
  fi
done


# /usr/local/mysql/bin/mysqld --initialize
chown -R root .
chown -R mysql data
chgrp -R mysql .
cp support-files/mysql.server /etc/rc.d/init.d/
chmod +x /etc/rc.d/init.d/mysql.server
chkconfig --add mysql.server
scp ./my.cnf /etc/
/etc/rc.d/init.d/mysql.server start