#!/bin/bash
rm -rf /var/www/uzenofal

#server_uuid
echo "[LOG] Removing auto.cnf - server_uuid"
rm /var/lib/mysql/auto.cnf

#Setting IP's
masterIP=$(cat /uzenofal/masterIP)
slaveIP=$(hostname -I | awk '{gsub(/^ +| +$/,"")} {print $0}')
slave_name=$(hostname -I | awk '{gsub(/^ +| +$/,"")} {print $0}' | awk -F'.' '{print $4}')
echo "[LOG] IP adresses and names defined, MASTER IP: [${masterIP}] SLAVE IP: [${slaveIP}] SLAVE NAME: [slave_${slave_name}]"

#CONNECT TO MASTER
ssh root@${masterIP} /uzenofal/cmd/updateFiles.sh
mount ${masterIP}:/uzenofal/shared /uzenofal/shared
echo "[LOG] Mounted to master"
sleep 2

#Unzip files
echo "[LOG] Unzipping uzenofal's files to /var/www/uzenofal" 
unzip /var/www/uzenofal-demo.zip -d /var/www/uzenofal > /dev/null

#Load DB
echo "[LOG] Load database"
mysql uzenofal < db.sql

#Create User on master
echo "[LOG] Create user on master"
ssh root@${masterIP} /uzenofal/cmd/createUser.sh ${slave_name}

#Change serverID
nextID=$(cat /uzenofal/shared/nextID)
echo "[LOG] Change server ID to ${nextID} in /etc/mysql/mysql.conf.d/mysqld.cnf"
sed -i "s/000000/${nextID}/g" /etc/mysql/mysql.conf.d/mysqld.cnf

#Change masterIP
echo "[LOG] Change master IP in /var/www/uzenofal/db.php to ${masterIP}"
originalMas="master_db_host = 'localhost';"
newMas="master_db_host = '${masterIP}';"
sed -i "s/$originalMas/$newMas/g" /var/www/uzenofal/db.php

#Restart mysql
echo "[LOG] Restart service mysql"
service mysql restart

#Change master user
originalMasUser="master_db_user = 'uzenofal';"
newMasUser="master_db_user = 'slave_${slave_name}';"
echo "[LOG] Change username in /var/www/uzenofal/db.php to 'slave_${slave_name}'"
sed -i "s/$originalMasUser/$newMasUser/g" /var/www/uzenofal/db.php

#Change master in mysql cmd line
masterFile=$(cat /uzenofal/shared/masterFILE)
masterPos=$(cat /uzenofal/shared/masterPOS)
echo "[LOG] master file: ${masterFile}\t master pos: ${masterPos}"

cmd="CHANGE MASTER TO MASTER_HOST='${masterIP}',MASTER_USER='slave_${slave_name}',MASTER_PASSWORD='H3rhMmQX0tQM',MASTER_LOG_FILE='${masterFile}',MASTER_LOG_POS=${masterPos};"
echo "[LOG] Command to execute on master mysql: '${cmd}'"
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="stop slave;"
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="${cmd}"
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="start slave;"

#Register slave on master
echo "[LOG] Register slave on master"
ssh root@${masterIP} /uzenofal/cmd/addSlave.sh ${slaveIP}

#Restart service
echo "[LOG] MYSQL restarting"
service mysql restart
echo "[LOG] Uzenofal active on ${slaveIP}"
