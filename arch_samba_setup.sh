#!/bin/bash
# this is for arch linux pacman to 
#  apt-get install wsdd
# 1) create user and group for samba share
# 2) create sambashare/public in root /
# 3) create config file in etc/smb/config.



# Enable exit on error and command output:
set -eux

sudo mkdir -p /sambashare/public
sudo groupadd --system smbgroup
sudo useradd --system --no-create-home --group smbgroup -s /bin/false smbuser
sudo chown -R smbuser:smbgroup /sambashare
sudo chmod -R g+w /sambashare

echo "They didn't add 777 but the samba config has 777?"

sudo chmod -R 777 /sambashare

sudo pacman -Sy --noconfirm samba smbclient wsdd
sudo tee /etc/samba/smb.conf <<'EOF'
[global]
server string = File Share
workgroup = WORKGROUP
security = user
map to guest = Bad User
public = yes
guest ok = yes
guest account = nobody
name resolve order = bcast host
[Public_Files]
comment = My Share
path = /sambashare/public
force user = smbuser
guest ok = yes
force group = smbgroup
create mask = 0777
force create mode = 0777
directory mask = 0777
force directory mode = 0755 
public = yes
writable = yes
browsable = yes

EOF

sudo systemctl enable --now smb

sudo systemctl enable --now wsdd

echo "Who made this script they didn't add bash's safety features\n"
echo "fixed by Alvin\n"
