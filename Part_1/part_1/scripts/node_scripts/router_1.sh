#!/bin/sh
R1=$(docker ps --format "{{.Names}}" | grep router_jealefev-1)

echo $R1

docker exec -i "$R1" sh -c "
sysctl -w net.ipv4.ip_forward=1
ip addr add 192.168.1.1/24 dev eth0
"
