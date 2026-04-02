#!/bin/bash
# this is for arch linux pacman to 
#  apt-get install wsdd
# 1) create user and group for samba share
# 2) create sambashare/public in root /
# 3) create config file in etc/smb/config.



# Enable exit on error and command output:
set -eux

 mkdir -p /sambashare/public
 groupadd --system smbgroup
 useradd --system --no-create-home --group smbgroup -s /bin/false smbuser
 chown -R smbuser:smbgroup /sambashare
 chmod -R g+w /sambashare

echo "They didn't add 777 but the samba config has 777?"

 chmod -R 777 /sambashare

 pacman -Sy --noconfirm --disable-sandbox samba smbclient wsdd
 tee /etc/samba/smb.conf <<'EOF'
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

 systemctl enable --now smb

 systemctl enable --now wsdd

echo "allow firewall\n"

 ufw allow 137/udp
 ufw allow 138/udp

 ufw allow 137/tcp
 ufw allow 138/tcp

 ufw allow from 192.168.1.0/24
 ufw allow from 192.168.1.0/16

 ufw reload

echo "Who made this script they didn't add bash's safety features\n"
echo "fixed by Alvin\n"