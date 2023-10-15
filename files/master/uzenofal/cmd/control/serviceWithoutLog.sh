#!/bin/bash
IP=`hostname -I`
while true; do
	echo "" > /uzenofal/temp/load_monitor
	for i in {1..20}
	do
		connCnt=`(curl -s 192.168.50.28/stub_status | awk '{print $3}')`
		connCnt=`echo $connCnt | awk '{print $1}'`
		echo $connCnt > /var/www/uzenofal/connectionCount.txt
		echo $connCnt >> /uzenofal/temp/load_monitor
		cp /uzenofal/slaveIPs /var/www/uzenofal/ips.txt
		echo $(($((`cat /uzenofal/shared/numOfSlaves`))-1)) > /var/www/uzenofal/slaveCount.txt
		sleep 3
	done
	value=`cat /uzenofal/shared/numOfSlaves`
	number=$(($((value))-1))

#Reading the data
	let sum=0
	let cnt=0
	while read line
	do
		if [ $(($line)) -ne 0 ]; then
			cnt=$(($cnt+1))
			sum=$(($sum+$(($line))))
		fi
	done </uzenofal/temp/load_monitor

#Calculating the avarage
	let avg=$(($sum / $cnt))

	echo -e `date "+%T"`\\\t$number >> /var/www/uzenofal/slaveDiagram.txt
        echo -e `date "+%T"`\\\t$avg >> /var/www/uzenofal/connDiagram.txt

	if [ $(($number - $avg)) -ge 1 ]; then
			echo [LOG]----------STOP SLAVE---------- at `date "+%F %H:%M:%S"` >> /uzenofal/log/vm.log
			echo [LOG] [`date "+%F %H:%M:%S"`] Stop running slave [Connections: avg: ${avg} numberOfSlaves: $number]
			/uzenofal/cmd/control/removeSlave.sh >> /uzenofal/log/vm.log
                elif [ $(($avg - $number)) -ge 1 ]; then
			echo [LOG]----------START SLAVE---------- at `date "+%F %H:%M:%S"` >> /uzenofal/log/vm.log
			echo [LOG] [`date "+%F %H:%M:%S"`] Start new slave [Connections: avg: ${avg}  numberOfSlaves: $number]
			/uzenofal/cmd/control/startNewSlave.sh >> /uzenofal/log/vm.log
                else
                        #do nothing
			echo [LOG] [`date "+%F %H:%M:%S"`] Void step [Connections: avg: ${avg}  numberOfSlaves: $number]
                fi
	sleep 5
done
