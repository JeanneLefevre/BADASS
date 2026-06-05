all: open

#If the images have not been created before we can build them from this, and use them in GNS3 (Edit -> Preferences -> Docker Contrainer -> new -> use the images created from there)

build: 
	docker build -t alpin-jealefev -f ./dockerfile/alpine.dockerfile .
	docker build -t frrr-jealefev -f ./dockerfile/frrr.dockerfile .
down:
	- docker stop alpin
	- docker stop frrr
clean:
	- docker rm alpin
	- docker rm frrr

# You can open the GNS3 project, turn everything on and then use make scripts that will setup connection between the router and the host machine

open:
	gns3 ./GNS3_Project/part-1.gns3project
scripts:
	chmod +x ./scripts/node_scripts/router_1.sh \
	         ./scripts/node_scripts/host_1.sh \
	./scripts/node_scripts/router_1.sh
	./scripts/node_scripts/host_1.sh

# You can use the check to ping between the machines so we can show the connection between them
check:
	R1=$$(docker ps --format "{{.Names}}" | grep router_jealefev-1 || true); \
	H1=$$(docker ps --format "{{.Names}}" | grep host_jealefev-1 || true); \
	docker exec -i $$R1 sh << EOF 
	ping 10.1.1.2 
	EOF 
	docker exec -i $$H1 sh << EOF
	ping 192.168.2.10
	EOF

re: build down clean up

.PHONY: all build down clean open scripts check re
