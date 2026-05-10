Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/jammy64"

  config.vm.hostname = "gns3-server"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "gns3-server"

    vb.memory = 16384
    vb.cpus = 8
  end

config.vm.synced_folder ".", "/vagrant", type: "rsync"

config.vm.provision "shell", inline: <<-SHELL

  apt update -y
  apt install -y ca-certificates curl gnupg lsb-release

  # Docker official repo
  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update -y

  # Install Docker
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  systemctl enable docker
  systemctl start docker

  # Add user
  usermod -aG docker vagrant

SHELL

end