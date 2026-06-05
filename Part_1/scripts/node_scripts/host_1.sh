#!/bin/sh
H1=$(docker ps --format "{{.Names}}" | grep host-jealefev-1)

docker exec -i "$H1" sh << EOF
ip addr flush dev eth0
ip addr add 192.168.1.10/24 dev eth0
ip link set eth0 up

ip route del default 2>/dev/null

ip route add default via 192.168.1.1

ip addr
ip route
ping -c 2 192.168.1.1
EOF
