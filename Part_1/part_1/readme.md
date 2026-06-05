# BADASS - GNS3 Network Automation

## Overview

BADASS is a network automation project built with Docker and GNS3.

The goal is to deploy and configure a simple network topology composed of:

* One host machine
* One FRRouting router
* Automated configuration scripts
* A GNS3 project ready to launch

The project uses Docker containers as network nodes and shell scripts to automatically configure IP addressing and routing.

---

## Network Topology

```text
+--------------------+          +----------------------+
| Host               |          | Router (FRRouting)   |
|                    |          |                      |
| 192.168.1.10/24    | <------> | 192.168.1.1/24       |
| Gateway            |          | eth1                 |
| 192.168.1.1        |          |                      |
+--------------------+          +----------------------+
```

### Addressing Plan

| Device          | Interface | IP Address      |
| --------------- | --------- | --------------- |
| Host            | eth0      | 192.168.1.10/24 |
| Router          | eth1      | 192.168.1.1/24  |
| Router Loopback | lo        | 1.1.1.1/32      |

---

## Requirements

* Docker
* GNS3
* GNU Make

---

## Project Structure

```text
.
├── dockerfile/
│   ├── alpine.dockerfile
│   └── frrr.dockerfile
│
├── scripts/
│   └── node_scripts/
│       ├── host_1.sh
│       └── router_1.sh
│
├── GNS3_Project/
│   └── part-1.gns3project
│
└── makefile
```

---

## Build Docker Images

Build the Docker images used by GNS3:

```bash
make build
```

This creates:

```text
alpin-jealefev
frrr-jealefev
```

These images can then be imported into GNS3 through:

```text
Edit → Preferences → Docker Containers
```

---

## Open the GNS3 Project

```bash
make open
```

This opens:

```text
GNS3_Project/part-1.gns3project
```

Once opened:

1. Start all nodes.
2. Wait until containers are running.
3. Execute the automation scripts.

---

## Configure the Network

Run:

```bash
make scripts
```

This command:

### Router Configuration

* Enables IP forwarding
* Configures interfaces
* Configures loopback

Example:

```text
eth1 -> 192.168.1.1/24
lo   -> 1.1.1.1/32
```

### Host Configuration

* Configures host address

```text
192.168.1.10/24
```

* Configures default gateway

```text
192.168.1.1
```

---

## Connectivity Verification

To verify communication between nodes:

```bash
make check
```

The command performs ICMP tests between the configured devices.

---

## Useful Docker Commands

List running containers:

```bash
docker ps
```

Access the host container:

```bash
docker exec -it <host_container> sh
```

Access the router container:

```bash
docker exec -it <router_container> sh
```

Open FRRouting shell:

```bash
docker exec -it <router_container> vtysh
```

Display interface configuration:

```bash
ip addr
```

Display routing table:

```bash
ip route
```

Display neighbors:

```bash
ip neigh
```

---

## Cleaning

Stop containers:

```bash
make down
```

Remove containers:

```bash
make clean
```

Rebuild everything:

```bash
make re
```

---

## Notes

The project is designed to demonstrate:

* Docker-based network emulation
* GNS3 integration
* FRRouting configuration
* Automated deployment using shell scripts
* Basic Layer 3 communication between a host and a router

Future improvements may include:

* OSPF routing
* Multi-router topologies
* Additional hosts
* Dynamic routing validation
* Automated network testing

