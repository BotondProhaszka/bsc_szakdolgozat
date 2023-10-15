#!/bin/bash
oldIP=$(cat /uzenofal/shared/masterIP)
masterIP=$(hostname -I | awk '{gsub(/^ +| +$/,"")} {print $0}')

if [ $oldIP != $masterIP ]; then
	echo "Updating masterIP from ${oldIP} to ${masterIP}"
	echo "${masterIP}" > /uzenofal/shared/masterIP
	sed -i "s/^bind-address.*/bind-address = ${masterIP}/g" /etc/mysql/mysql.conf.d/mysqld.cnf
else
	echo "Update in masterIP not needed"
fi
