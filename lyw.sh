#!/bin/sh

# The list of Xaomi LYWSD03MMC sensors
# A4:C1:38:0B:81:47 -> salon
# A4:C1:38:E9:7A:4A -> sypialnia
# A4:C1:38:8D:29:E0 -> Zosia

#cd `dirname "$0"`
cd $HOME/LYWSD03MMC-MQTT

devices='LYWSD03MMC 0x001b 0x0038 0x0036
LYWSD02 0x0052 0x004c 0x004b'

! [ -f mqtt.conf ] && echo "Fail to find mqtt.conf file" && exit 1
. ./mqtt.conf
mqtt="mosquitto_pub -h $host -p $port"
[ -n "$user$pass" ] && mqtt="$mqtt -u $user -P $pass"

for mac in $*; do
    echo "============ $(date +'%F %T') ============="
    if handle=`gatttool -b "$mac" --characteristics | sed '/ebe0ccc1/!d;s/^.*char value handle = //;s/, .*//'` 2>/dev/null; then
        if [ -z "$handle" ]; then
            echo "Device with mac $mac doesn't have needed handle or connection is failed, skipping"
        else
            device="$(echo "$devices" | sed '/ '"$handle"'$/!d')"
            if [ -n "$device" ]; then
                echo "DEVICE FOUND: ${device%% *} ($mac)"
                if [ "$mac" = "A4:C1:38:0B:81:47" ]; then
                  idx=151
                elif [ "$mac" = "A4:C1:38:E9:7A:4A" ]; then
                  idx=152
                elif [ "$mac" = "A4:C1:38:8D:29:E0" ]; then
                  idx=153
                fi
                mqttc="$mqtt -m '{ \"idx\" : "
                mqttc="$mqttc $idx"
                mqttc="$mqttc , \"nvalue\" : 0, \"svalue\" : "
                chkhnd="${device##* }"
                nothnd=`echo "$device" | cut -d " " -f 3`
                battery=`echo "$mac $device" | awk '{print "gatttool -b "$1" --char-read -a "$3}' | sh | awk '{ print "ibase=16; "toupper($NF) }' | bc`
                echo "Battery: $battery"
                gatttool -b "$mac" --char-write-req --handle="$nothnd" --value 0100 --listen |
                    while IFS= read -r line; do
                        res=`echo "$line" | awk '{
                            if ($0~/Notification handle = '"$chkhnd"' value/) {print "ibase=16; "toupper($7$6)"\nibase=16; "toupper($8)}
                        }'`
                        if [ -n "$res" ]; then
                            temp=`echo "$res" | sed '1!d' | bc`
                            hum=`echo "$res" | sed '2!d' | bc`
                            temp_ok=`echo "$temp " | awk '{print $1/100}'`
                            echo "Temperature: $temp_ok"
                            hum_ok=`echo "$hum " | awk '{print $1}'`
                            echo "Humidity: $hum_ok"
                            mqttc="$mqttc \"$temp_ok;$hum_ok %;1\", \"Battery\" :  $battery, \"RSSI\" : 12 }' -t 'domoticz/in'"
                            echo "$mqttc" | sh
                            exit 0
                        fi
                    done
            else
                echo "Device with mac $mac does not supported, skipping"
            fi
        fi
     else
         echo "Fail to connect to device with mac $mac"
     fi
done
