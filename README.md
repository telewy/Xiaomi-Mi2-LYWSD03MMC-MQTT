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
