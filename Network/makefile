SUFFIX ?= jealefev


all: build

build: 
	docker build -t alpin-${SUFFIX} -f ./dockerfile/alpine.dockerfile .
	docker build -t frrr-${SUFFIX} -f ./dockerfile/frrr.dockerfile .
down:
	- docker stop alpin
	- docker stop frrr
	
clean:
	- docker rm alpin
	- docker rm frrr
	
network:
	-docker network create \
		--driver bridge \
		--subnet 192.168.1.0/24 \
		labnet

up: network
	docker run --name alpin \
		--network labnet \
		--ip 192.168.1.10 \
		-d --rm --privileged \
		alpin-${SUFFIX}

	docker run --name frrr \
		--network labnet \
		--ip 192.168.1.20 \
		-d --rm --privileged \
		frrr-${SUFFIX}

	chmod +x confi.sh
	./scripts/node_scripts/confi.sh

open:
	gns3 ./GNS3_Project/part-1.gns3project

scripts:
	chmod +x ./scripts/node_scripts/router_1.sh \
	         ./scripts/node_scripts/router_2.sh \
	         ./scripts/node_scripts/host_1.sh \
	         ./scripts/node_scripts/host_2.sh
	./scripts/node_scripts/router_1.sh
	./scripts/node_scripts/router_2.sh
	./scripts/node_scripts/host_1.sh
	./scripts/node_scripts/host_2.sh

check:
	R1=$$(docker ps --format "{{.Names}}" | grep router_jealefev-1 || true); \
	R2=$$(docker ps --format "{{.Names}}" | grep router_jealefev-2 || true); \
	H1=$$(docker ps --format "{{.Names}}" | grep host_jealefev-1 || true); \
	H2=$$(docker ps --format "{{.Names}}" | grep host_jealefev-2 || true); \
	docker exec -i $$R1 sh << EOF 
	ping 10.1.1.2 
	EOF 
	docker exec -i $$R2 sh << EOF 
	ping 10.1.1.1 
	EOF 
	docker exec -i $$H1 sh << EOF
	ping 192.168.2.10
	EOF
	docker exec -i $$H2 sh << EOF
	ping 192.168.1.10
	EOF

re: build down clean up

.PHONY: all build down clean network up open scripts check re
