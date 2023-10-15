#!/bin/bash

#Get slave vm id
ID=$(cat /uzenofal/shared/numOfSlaves)
nextID=$(($(($ID))+1))
if [ $((ID)) -le 9 ]; then
	echo -e "ID: ${ID}\tnextID: ${nextID}"
	echo "${nextID}" > /uzenofal/shared/numOfSlaves

	#Start vm
	echo "[LOG] Start VM id: ${ID}"
	ssh root@192.168.50.60 /home/prohi/uzenofal/cmd/startVM.sh $ID >> /uzenofal/log/vm.log
	#Import next vm
	echo "[LOG] Import VM id: ${nextID}"
	ssh root@192.168.50.60 /home/prohi/uzenofal/cmd/importVM.sh $nextID >> /uzenofal/log/vm.log

	echo "[LOG] Static wait for starting"
	sleep 10

	ip=$(sed '$!d' /uzenofal/slaveIPs)

	if [ -z "$ip" ]; then
		echo "[LOG] IP is not given yet. IP: [${ip}]"
		sleep 10
		ip=$(sed '$!d' /uzenofal/slaveIPs)
	else
		echo "[LOG] IP is given. IP: [${ip}]"

	fi
	#Add to server block in /etc/nginx/sites-available/default
	sed -i "/#server_placeholder/a \\\tserver ${ip};" /etc/nginx/sites-available/default
	service nginx reload

	echo "[LOG] Service active on [${ip}]"
else
	echo "[ERROR] Max number of running slaves has reached"
fi
