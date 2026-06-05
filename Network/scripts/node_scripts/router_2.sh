#!/bin/sh
R2=$(docker ps --format "{{.Names}}" | grep router_jealefev-2)

docker exec -i "$R2" sh -c "
sysctl -w net.ipv4.ip_forward=1
"

docker exec -i "$R2" vtysh << EOF
conf t

interface eth0
ip address 10.1.1.2/30
exit

interface eth1
ip address 192.168.2.1/24
exit

interface lo
ip address 1.1.1.2/32
exit

router ospf
ospf router-id 1.1.1.2
network 10.1.1.0/30 area 0
network 192.168.2.0/24 area 0
network 1.1.1.2/32 area 0

end
write memory
EOF
