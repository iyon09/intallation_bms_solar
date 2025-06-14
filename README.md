🔋 RS485 Solar Battery Monitoring on OpenWRT
This project provides a lightweight battery monitoring system for OpenWRT-based routers or gateways that are equipped with RS485 serial ports. It is designed to read data from a battery management system (BMS) using the RS485 interface and publish the result to an MQTT broker for monitoring or integration into a smart dashboard.


Installation step by step
1. ssh root@<gateway_ip> //Get inside Gateway
2. cd /root
3. wget https://raw.githubusercontent.com/iyon09/intallation_bms_solar/main/SolarData.sh -O SolarData.sh // install the .sh file from github
4. chmod +x SolarData.sh // give permision 
5. ./SolarData.sh // run the service

To Confirm the service is running
bash
/etc/init.d/mybmsread status

you shouls see
bash
running

DATA OUTPUT
Topic: battery/info/<DEVICE_ID>
Broker: cloud.lightsol.net
Payload: Hex string response from RS485 device

