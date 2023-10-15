#!/bin/bash
username="slave_${1}"

createCmd="GRANT REPLICATION SLAVE ON *.* TO '${username}'@'%' IDENTIFIED BY 'H3rhMmQX0tQM';"
rightsCmd="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER on uzenofal.* TO ${username}@'%';"
echo $createCmd
echo $rightsCmd

mysql --user="root" --password="oprepass" --database="uzenofal" --execute="${createCmd}"
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="${rightsCmd}"
mysql --user="root" --password="oprepass" --database="uzenofal" --execute="FLUSH PRIVILEGES;"
