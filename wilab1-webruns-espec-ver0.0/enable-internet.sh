#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "{ \"failed\": true, \"msg\": \"This script should be run using sudo or as the root user\" }"
    exit 1
fi


GW=$(route -n | grep UG | awk '{print $2}')

is_wall1() {
        hostname | grep wall1.ilabt.iminds.be$ > /dev/null
}

SETUP_IGENT_VPN=1


#Physical wall1-machines
if [[ "$GW" = "10.2.15.254" ]]; then
                route del default gw 10.2.15.254 && route add default gw 10.2.15.253
                route add -net 10.11.0.0 netmask 255.255.0.0 gw 10.2.15.254
                route add -net 10.2.32.0 netmask 255.255.240.0 gw 10.2.15.254

#Virtual wall1-machines
elif [[ "$GW" = "172.16.0.1" && is_wall1 ]]; then
                route add -net 10.2.0.0 netmask 255.255.240.0 gw 172.16.0.1
                route del default gw 172.16.0.1 && route add default gw 172.16.0.2

#Physical wall2-machines
elif [[ "$GW" = "10.2.47.254" ]]; then
                route del default gw 10.2.47.254 && route add default gw 10.2.47.253
                route add -net 10.11.0.0 netmask 255.255.0.0 gw 10.2.47.254
                route add -net 10.2.0.0 netmask 255.255.240.0 gw 10.2.47.254

#Virtual wall2-machines
elif [[ "$GW" = "172.16.0.1" && ! is_wall1 ]]; then
                route add -net 10.2.32.0 netmask 255.255.240.0 gw 172.16.0.1
                route del default gw 172.16.0.1 && route add default gw 172.16.0.2
else
        echo "{ \"changed\": false }"
        exit 0
fi

if [[ "$SETUP_IGENT_VPN" ]]
        then
                route add -net 157.193.214.0 netmask 255.255.255.0 gw $GW
                route add -net 157.193.215.0 netmask 255.255.255.0 gw $GW
                route add -net 157.193.135.0 netmask 255.255.255.0 gw $GW
                route add -net 192.168.126.0 netmask 255.255.255.0 gw $GW
fi

echo "{ \"changed\": true, \"msg\": \"OK\" }"
