# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "FACTbox"
  config.disksize.size = "100GB"
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  config.vm.network "forwarded_port", guest: 9191, host: 9191
  config.vm.boot_timeout = 500

  config.ssh.keep_alive = true
  config.ssh.insert_key = false


  config.vm.provider "virtualbox" do |vb|
  #  vb.gui = true
    vb.cpus = 4
    vb.memory = "12288"
   end

  config.vm.provision "shell" do |s|
    s.inline = <<-SHELL
        set -euxo pipefail
        echo "--- Prepare installation for the Firmware Analysis and Comparison Tool (FACT) ---"
        sudo apt update
        sudo apt install -y git python3 python3-pip jq
        sudo mkdir -p /FACT_core
        sudo chown -R vagrant:users /FACT_core
        VERSION_TAG=$(curl --silent "https://api.github.com/repos/fkie-cad/FACT_core/releases/latest"| jq -r .tag_name  | tr -d "v//")
        git clone https://github.com/fkie-cad/FACT_core.git --branch $VERSION_TAG --single-branch /FACT_core
        /FACT_core/src/install/pre_install.sh && sudo mkdir -p /media/data && sudo chown -R $USER /media/data
      SHELL
    s.privileged = false
  end
  config.vm.provision :reload

  config.vm.provision "shell" do |s|
     s.inline = <<-SHELL
        set -euxo pipefail
        echo "--- Install the Firmware Analysis and Comparison Tool (FACT) ---"
        /FACT_core/src/install.py

        echo "--- Enable remote access to webserver ---"
        sed -i "s/127.0.0.1/0.0.0.0/g" /FACT_core/src/config/uwsgi_config.ini

        echo "--- Enable autostart ---"
        echo "[Unit]
         Description=Firmware Analysis and Comparison Tool (FACT).

         [Service]
         Type=Simple
         ExecStart=/FACT_core/start_all_installed_fact_components

         [Install]
         WantedBy=multi-user.target">/tmp/fact.service

        sudo mv /tmp/fact.service /etc/systemd/system/fact.service
        sudo chown 644 /etc/systemd/system/fact.service
        sudo systemctl enable fact.service
        sudo systemctl start fact.service
      SHELL
    s.privileged = false
  end
  config.vm.provision :reload

  config.vm.provision "shell" do |s|
    s.inline = <<-SHELL
      echo "-----------------------------------------------------"
      echo "* ------------ FACT INSTALLED! (Finally) ---------- *"
      echo "|                                                   |"
      echo "|              Let's go and check it out!           |"
      echo "|                                                   |"
      echo "|               http://localhost:5000               |"
      echo "|                                                   |"
      echo "*---------------------------------------------------*"
      echo "-----------------------------------------------------"
    SHELL
  end
 end
