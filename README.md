# Xiaomi-Mi2-LYWSD03MMC-MQTT
What is it?

Simple script for getting values of temperature, humidity and battery level from Xiaomi LYWSD03MMC sensors and sending data to Domoticz using MQTT topics. The script is based on source code from this repository https://github.com/alive-corpse/LYWSD02-LYWSD03MMC-MQTT and adapted to my needs.

Why it was made?
In my home I use Domoticz https://www.domoticz.com/ Home Automation Systemfor various IoT devices like temperature sensors, meteo station, PIR devices, etc. For temperature I use DS1820B which is wired solution and recently Xiaomi temperature and humidity sensors (LYWSD03MMC) which works using Bluetooth protocol. As a gateway I use Raspberry Pi Zero 2W. This gateway reads data from sensors and send it to domoticz using mqtt. 

How it works?
After you run script and pass list of mac addresses to it, script will make this actions for each of addresses from list:
Try to detect if device is exists and available
Trying to get UUID of handle that leads to temperature and humidity data
Compare this handle shifting with hardcoded from constants
If handle shifts are equal with one of them scripts print what device is it (LYWSD03MMC or LYWSD02)
For each version of devices it has number of handles to operate with, so it tried to get battery level data with one of handles, decode it, print it and send it to mqtt topic
With another handle it makes request to subscribe for notifications
It waiting of message from device with temperature and humidity data, decode it, print it and send it to mqtt topic

Dependencies
Obliviously, you shoud have bluetooth adapter supported by you operating system. You need also mosquitto-client software. Also you need to install this packets (example for debian-based operating systems):

sudo apt-get install bluez-tools mosquitto-clients

Domoticz server is working, mqtt server side is working. 
In my case when I send mqtt message I use following syntax:

mosquitto_pub -h dodmotczhostIPAddress -p portID -m '{ "idx" : deviceId , "nvalue" : 0, "svalue" : "temperature;humidity %;batteryLevel", "Battery" : batteryVoltage, "RSSI" : 12 }' -t 'domoticzTopic'

where
1. dodmotczhostIPAddress - domoticz server IP address
2. portID - domoticz port number
3. deviceId - deviceID - the number of device assigned in domotucz to the sensor
4. temperature - measured temperature
5. humidity - measured humidity
6. batteryLevel - measured batteryLevel
7. batteryVoltage - measured batteryVoltage

example: 
mosquitto_pub -h 192.168.2.22 -p 1883 -m '{ "idx" : 152 , "nvalue" : 0, "svalue" : "20.12;44 %;1", "Battery" : 99, "RSSI" : 12 }' -t 'domoticz/in'

Installation

wget https://github.com/telewy/Xiaomi-Mi2-LYWSD03MMC-MQTT/archive/refs/heads/main.zip
unzip main.zip
cd LYWSD03MMC-MQTT/

Then edit mqtt.conf file to fill it up with your MQTT credentials. Do not use spaces between equal sign and values/parameters names.

Finding mac addresses of devices

Run following command

sudo hcitool lescan

You will see something like this:
LE Scan ...
3B:21:31:D6:84:6B (unknown)
3B:56:14:16:34:39 (unknown)
A4:C1:38:0B:81:47 (unknown)
A4:C1:38:0B:81:47 LYWSD03MMC
41:8C:30:A9:AA:3A (unknown)
A4:C1:38:E9:7A:4A (unknown)
A4:C1:38:E9:7A:4A LYWSD03MMC
A4:C1:38:8D:29:E0 (unknown)
A4:C1:38:8D:29:E0 LYWSD03MMC

You have to look for the rowsthat contain LYWSD03MMC name. The easies way is to remove battery and activate one by one sensor and mark each. 

On domoticz side
1. go to Setup -> Hardware and add new hardware and name it as "Xiaomi Mijia Temp & Hum" for example. Choose Type = Dummy
2. On the Setup -> Hardware click on "Xiaomi Mijia Temp & Hum" -> Create virtual sensor. Name it as you wish. For sensor type choose: Temp+Hum
3. go to Setup -> Devices, find newrky created device and write down its idx
4. modify script code in the section according mac addresses you got and idx identifiers
  if [ "$mac" = "A4:C1:38:0B:81:47" ]; then
    idx=151
  elif [ "$mac" = "A4:C1:38:E9:7A:4A" ]; then
    idx=152
  elif [ "$mac" = "A4:C1:38:8D:29:E0" ]; then
    idx=153
  fi

Running

First run manually to check if it works properly
1. go to directory where you saved script
2. run following command
   lyw.sh A4:C1:38:0B:81:47 A4:C1:38:E9:7A:4A A4:C1:38:8D:29:E0
3. you should see on the screen something similar to this

   ============ 2024-12-04 18:25:56 =============
   DEVICE FOUND: LYWSD03MMC (A4:C1:38:0B:81:47)
   Battery: 99
   Temperature: 20.69
   Humidity: 43
   ============ 2024-12-04 18:26:11 =============
   DEVICE FOUND: LYWSD03MMC (A4:C1:38:E9:7A:4A)
   Battery: 99
   Temperature: 20.05
   Humidity: 45
   ============ 2024-12-04 18:26:26 =============
   DEVICE FOUND: LYWSD03MMC (A4:C1:38:8D:29:E0)
   Battery: 99
   Temperature: 20.22
   Humidity: 42
4. check in domoticz if data is visible
5. add entry to cron
   
  */10 * * * * timeout 59 $HOME/LYWSD03MMC-MQTT/lyw.sh A4:C1:38:0B:81:47 A4:C1:38:E9:7A:4A A4:C1:38:8D:29:E0 > /dev/null 2>&1
