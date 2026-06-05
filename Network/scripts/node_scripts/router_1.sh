#!/bin/sh
R1=$(docker ps --format "{{.Names}}" | grep router_jealefev-1)

echo $R1

docker exec -i "$R1" sh -c "
sysctl -w net.ipv4.ip_forward=1
"

docker exec -i "$R1" vtysh << EOF
conf t

interface eth0
ip address 10.1.1.1/30
exit

interface eth1
ip address 192.168.1.1/24
exit

interface lo
ip address 1.1.1.1/32
exit

router ospf
ospf router-id 1.1.1.1
network 10.1.1.0/30 area 0
network 192.168.1.0/24 area 0
network 1.1.1.1/32 area 0
exit

end
write memory
EOF
