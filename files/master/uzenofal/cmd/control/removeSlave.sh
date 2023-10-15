#!/bin/bash
IP=$(tail -n 1 /uzenofal/slaveIPs)

#Get slave vm id
ID=$(cat /uzenofal/shared/numOfSlaves)
prevID=$(($((${ID}))-1))

if [ $(($ID)) -lt 3 ]; then

	echo "[ERROR] At least one slave VM has to run. Actual number of running slave VMs: ${prevID}"

	else

	echo "[LOG] Removing from backend block. IP: [${IP}]"
	sed -i "/$IP/d" /etc/nginx/sites-available/default
	sed -i "/$IP/d" /uzenofal/slaveIPs
	echo "[LOG] Removing the imported slave VM."
	ssh root@192.168.50.60 /home/prohi/uzenofal/cmd/stopVM.sh $ID >> /uzenofal/log/vm.log

	echo "[LOG] Removing the last started running slave."
	ssh root@192.168.50.60 /home/prohi/uzenofal/cmd/stopVM.sh $prevID >> /uzenofal/log/vm.log

	echo "[LOG] Import the next VM to be ready to start."
	ssh root@192.168.50.60 /home/prohi/uzenofal/cmd/importVM.sh $prevID >> /uzenofal/log/vm.log

	echo "[LOG] Updating the next slave ID to ${prevID}"
	echo "${prevID}" > /uzenofal/shared/numOfSlaves

	echo "[LOG] Reloading nginx"
	service nginx reload
fi
