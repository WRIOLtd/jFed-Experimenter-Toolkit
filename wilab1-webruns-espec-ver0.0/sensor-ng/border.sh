#!/bin/bash
set +x

SCRIPT_PATH=${BASH_SOURCE%/*}

echo "Cycling power of motes"

#cycle power of motes
sudo /share/yepkit-USB-hub/ykushcmd -d 1
sudo /share/yepkit-USB-hub/ykushcmd -d 2
sudo /share/yepkit-USB-hub/ykushcmd -d 3
sleep 5
sudo /share/yepkit-USB-hub/ykushcmd -u 1
sudo /share/yepkit-USB-hub/ykushcmd -u 2
sudo /share/yepkit-USB-hub/ykushcmd -u 3
sleep 5

echo "Finished cycling power of motes"


#start the tunnel
coproc ts6 { /opt/contiki-ng/tools/serial-io/tunslip6 -s /dev/ttyUSB0 cccc::1/64 ; }
echo "Started tunslip6"

IPV6_REGEX="cccc:(:[0-9a-f]{1,4}){4}"

#retrieve the border router IP from the output of tunslip6
BORDER_ROUTER_IP=""
while read -ru ${ts6[0]} line; do
   if [[ "$line" =~ $IPV6_REGEX ]]; then
        BORDER_ROUTER_IP="${BASH_REMATCH[0]}"
        echo "Found border router IP: $BORDER_ROUTER_IP"
        break
   else
      echo "No match in '$line'"
   fi
done

#now try to retrieve the sensor IP

SENSOR_IP_REGEX="<li>($IPV6_REGEX)"
SENSOR_IP=""

while [ -z "$SENSOR_IP" ]; do
        ROUTER_OUTPUT=$(curl -s "http://[${BORDER_ROUTER_IP}]") 
        if [[ "$ROUTER_OUTPUT" =~ $SENSOR_IP_REGEX ]]; then
          SENSOR_IP="${BASH_REMATCH[1]}"
        else
		  echo "Looking for sensor IP..."
          sleep 1
        fi
done

echo "Found sensor IP: ${SENSOR_IP}"
wait $ts6_PID
