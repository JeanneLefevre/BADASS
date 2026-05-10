#image 2
FROM alpine:latest

# Installation des outils
RUN apk update && apk add --no-cache \
    busybox \
    frr \
    bash

# Création des dossiers FRR
RUN mkdir -p /etc/frr

# Copie de la configuration
COPY daemons /etc/frr/daemons
COPY frr.conf /etc/frr/frr.conf

# Permissions
RUN chown -R frr:frr /etc/frr

# Lancement de FRR
CMD ["/bin/sh", "-c", "zebra -d && bgpd -d && ospfd -d && isisd -d && tail -f /dev/null"]