#!/usr/bin/env bash

# Install and join ZeroTier client
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
zerotier-cli join ${zerotier_network_id}
# Install and setup zerotier systemd manager
wget https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.1.5/zerotier-systemd-manager_0.1.5_linux_amd64.deb
sudo apt install ./zerotier-systemd-manager_0.1.5_linux_amd64.deb
sudo systemctl daemon-reload
sudo systemctl restart zerotier-one
sudo systemctl enable  zerotier-systemd-manager.timer
sudo systemctl enable  zerotier-systemd-manager.service
sudo systemctl restart zerotier-systemd-manager.service

# Install and setup zeroNSD
wget https://github.com/zerotier/zeronsd/releases/download/v0.1.4/zeronsd_0.1.4_amd64.deb
sudo dpkg -i zeronsd_0.1.4_amd64.deb
sudo zeronsd supervise -t /var/lib/zerotier-one/token -f /etc/hosts -d ${domain_name} ${zerotier_network_id}
sudo systemctl start zeronsd-${zerotier_network_id}
sudo systemctl enable zeronsd-${zerotier_network_id}