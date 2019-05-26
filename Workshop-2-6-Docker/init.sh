#!/bin/sh
echo "Step 1: Define IP Address, Timestamp Volume of JMeter Server and JMeter Client"
CLIENT_IP=192.168.100.20
declare -a SERVER_IPS=("192.168.100.10" "192.168.100.11" "192.168.100.10")
timestamp=$(date +%Y%m%d_%H%M%S)
script_path=/home/ubuntu/jmeter-workshop-062019/Workshop-2-6-Docker/jmeter
result_path=/home/ubuntu/jmeter-workshop-062019/Workshop-2-6-Docker/result
jmeter_path=/mnt/jmeter

echo "Step 2: Create JMeter server"
for IPADDR in "${SERVER_IPS[@]}"
do
	docker run --name $IPADDR \
	-dit --net jmeternet --ip $IPADDR \
    --mount type=bind,source=${volume_path},target=${jmeter_path} \
	--rm jmeter -n -s \
	-Jclient.rmi.localport=7000 -Jserver.rmi.localport=60000 \
	-j ${jmeter_path}/server/slave_${timestamp}_${IPADDR:9:3}.log 
done

echo "Step 3: Create JMeter client"
docker run --name JMETERCLIENT\
  --net jmeternet --ip $CLIENT_IP \
  -v "${volume_path}":${jmeter_path} \
  --rm jmeter -n -X \
  -Jclient.rmi.localport=7000 \
  -R $(echo $(printf ",%s" "${SERVER_IPS[@]}") | cut -c 2-) \
  -t ${jmeter_path}/<jmx_script> \
  -l ${jmeter_path}/client/result_${timestamp}.jtl \
  -j ${jmeter_path}/client/jmeter_${timestamp}.log 
 