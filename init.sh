#!/usr/bin/env bash
#
# Installation automatique :
# Debian 13 / GNS3 / Docker / OpenTofu / Ansible
#
# Utilisation : sudo bash install-devops.sh

set -Eeuo pipefail

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
    exit 1
}

# Vérification root
if [[ "$EUID" -ne 0 ]]; then
    error "Lance ce script avec sudo."
fi

# Vérification Debian
source /etc/os-release

if [[ "$ID" != "debian" || "$VERSION_ID" != "13" ]]; then
    error "Ce script est prévu pour Debian 13 uniquement."
fi

# Utilisateur qui exécutera les outils
TARGET_USER="${SUDO_USER:-}"

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    error "Connecte-toi avec un utilisateur normal et utilise sudo."
fi

id "$TARGET_USER" >/dev/null 2>&1 || error "Utilisateur introuvable."

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
ARCH="$(dpkg --print-architecture)"

info "Installation sur Debian $VERSION_ID ($ARCH)"
info "Utilisateur : $TARGET_USER"

# --------------------------------------------------
# 1. Dépendances système
# --------------------------------------------------

info "Installation des dépendances système..."

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    apt-transport-https \
    git \
    unzip \
    zip \
    tar \
    xz-utils \
    jq \
    vim \
    nano \
    htop \
    net-tools \
    iproute2 \
    iputils-ping \
    traceroute \
    dnsutils \
    tcpdump \
    nmap \
    openssh-client \
    openssh-server \
    build-essential \
    make \
    cmake \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    pipx \
    python3-setuptools \
    python3-wheel \
    python3-pyqt6 \
    python3-pyqt6.qtwebsockets \
    python3-pyqt6.qtsvg \
    libpcap-dev \
    libelf-dev \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    qemu-system-x86 \
    qemu-utils \
    qemu-kvm \
    libvirt-clients \
    libvirt-daemon-system \
    virtinst \
    virt-manager \
    bridge-utils \
    vpcs \
    wireshark \
    acl \
    sudo

success "Dépendances système installées."

# --------------------------------------------------
# 2. Virtualisation et services
# --------------------------------------------------

info "Activation des services de virtualisation..."

systemctl enable --now libvirtd || true
systemctl enable --now ssh || true

# --------------------------------------------------
# 3. Installation de Docker officiel
# --------------------------------------------------

info "Installation de Docker Engine..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: trixie
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable --now docker

success "Docker et Docker Compose installés."

# --------------------------------------------------
# 4. Installation OpenTofu
# --------------------------------------------------

info "Installation d'OpenTofu..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://get.opentofu.org/opentofu.gpg \
    -o /etc/apt/keyrings/opentofu.gpg

curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey \
    | gpg --no-tty --batch --dearmor \
        -o /etc/apt/keyrings/opentofu-repo.gpg

chmod a+r \
    /etc/apt/keyrings/opentofu.gpg \
    /etc/apt/keyrings/opentofu-repo.gpg

cat > /etc/apt/sources.list.d/opentofu.list <<EOF
deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
EOF

apt-get update
apt-get install -y tofu

success "OpenTofu installé."

# --------------------------------------------------
# 5. Installation Ansible
# --------------------------------------------------

info "Installation d'Ansible..."

apt-get install -y ansible

success "Ansible installé."

# --------------------------------------------------
# 6. Installation de uBridge pour GNS3
# --------------------------------------------------

info "Installation de uBridge..."

if ! command -v ubridge >/dev/null 2>&1; then
    BUILD_DIR="$(mktemp -d)"

    git clone --depth 1 \
        https://github.com/GNS3/ubridge.git \
        "$BUILD_DIR/ubridge"

    make -C "$BUILD_DIR/ubridge"

    install -m 0755 \
        "$BUILD_DIR/ubridge/ubridge" \
        /usr/local/bin/ubridge

    rm -rf "$BUILD_DIR"
fi

# Capacités réseau nécessaires à uBridge
setcap cap_net_admin,cap_net_raw+eip /usr/local/bin/ubridge || true

success "uBridge installé."

# --------------------------------------------------
# 7. Installation de GNS3 avec pipx
# --------------------------------------------------

info "Installation de GNS3 Server et GUI..."

runuser -u "$TARGET_USER" -- env \
    HOME="$TARGET_HOME" \
    PATH="/usr/local/bin:/usr/bin:/bin:$TARGET_HOME/.local/bin" \
    bash -c '
        export PIPX_HOME="$HOME/.local/share/pipx"
        export PIPX_BIN_DIR="$HOME/.local/bin"

        pipx install gns3-server
        pipx install gns3-gui

        pipx inject gns3-gui gns3-server PyQt6
    '

success "GNS3 Server et GNS3 GUI installés."

# --------------------------------------------------
# 8. Configuration des groupes utilisateur
# --------------------------------------------------

info "Configuration des permissions utilisateur..."

for GROUP in docker libvirt kvm wireshark ubridge; do
    if getent group "$GROUP" >/dev/null 2>&1; then
        usermod -aG "$GROUP" "$TARGET_USER"
        success "Utilisateur ajouté au groupe $GROUP"
    fi
done

# --------------------------------------------------
# 9. Création des dossiers de travail
# --------------------------------------------------

info "Création des dossiers DevOps..."

install -d -o "$TARGET_USER" -g "$TARGET_USER" \
    "$TARGET_HOME/devops" \
    "$TARGET_HOME/devops/docker" \
    "$TARGET_HOME/devops/opentofu" \
    "$TARGET_HOME/devops/ansible" \
    "$TARGET_HOME/devops/gns3" \
    "$TARGET_HOME/devops/scripts"

# Inventaire Ansible de départ
cat > "$TARGET_HOME/devops/ansible/inventory.ini" <<EOF
[local]
localhost ansible_connection=local
EOF

chown "$TARGET_USER:$TARGET_USER" \
    "$TARGET_HOME/devops/ansible/inventory.ini"

# --------------------------------------------------
# 10. Vérification des installations
# --------------------------------------------------

echo
info "Vérification des installations..."

echo "--------------------------------------"

docker --version
docker compose version
tofu version
ansible --version | head -n 2
/usr/local/bin/ubridge -v || true

runuser -u "$TARGET_USER" -- env \
    HOME="$TARGET_HOME" \
    PATH="$TARGET_HOME/.local/bin:/usr/local/bin:/usr/bin:/bin" \
    bash -c '
        gns3server --version
        gns3 --version
    '

echo "--------------------------------------"

success "Installation terminée !"

echo
echo "Outils installés :"
echo " - GNS3 Server"
echo " - GNS3 GUI"
echo " - Docker Engine"
echo " - Docker Compose"
echo " - OpenTofu"
echo " - Ansible"
echo " - QEMU / KVM / libvirt"
echo " - uBridge / VPCS"

echo
echo "Dossiers de travail : $TARGET_HOME/devops"

echo
echo "IMPORTANT : redémarre la VM pour appliquer les groupes utilisateur."
echo "Commande : sudo reboot"
