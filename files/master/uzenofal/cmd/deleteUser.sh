#!/bin/bash
username="slave_${1}"

deleteCmd="DROP USER ${username};"
echo $deleteCmd

mysql --user="root" --password="oprepass" --database="uzenofal" --execute="${deleteCmd}"

