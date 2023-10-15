#!/bin/bash

#upadte ID
lastID=$(cat /uzenofal/shared/nextID)
newID=$(($((${lastID}))+1))

sed -i "s/$lastID/$newID/g" /uzenofal/shared/nextID

#update DB
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="FLUSH TABLES WITH READ LOCK;" > /dev/null 2>&1
mysqldump --opt uzenofal > /uzenofal/shared/db.sql 
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="UNLOCK TABLES;" > /dev/null 2>&1 

#update FILE and POS
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="FLUSH TABLES WITH READ LOCK;" > /dev/null 2>&1
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="SHOW MASTER STATUS;" | tail -n +2 | awk -F"\t" '{print $1}' > /uzenofal/shared/masterFILE
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="SHOW MASTER STATUS;" | tail -n +2 | awk -F"\t" '{print $2}' > /uzenofal/shared/masterPOS

mysql --user="root" --password="oprepass" --database="uzenofal" --execute="UNLOCK TABLES;" > /dev/null 2>&1

