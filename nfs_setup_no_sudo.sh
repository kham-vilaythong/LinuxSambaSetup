#!/bin/bash
# Enable exit on error and command output:
set -eux
echo "this sh file download nfs-utils and rpcbind and nfs-kernel-server"
echo "download and install nfs-utils\n"
pacman -Sy --noconfirm --disable-sandbox nfs-utils rpcbind
echo "make /nfsshare\n"
mkdir /nfsshare
chown nobody:nogroup /nfsshare
echo "chmod -R 777 /nfsshare\n"
chmod -R 777 /nfsshare
tee /etc/exports <<'EOF'
/nfsshare *(rw,sync,no_subtree_check,insecure)
EOF

exportfs -a
systemctl enable --now rpcbind.socket
echo "start nfs-server"
systemctl enable --now nfs-server.service
echo " ubuntu sudo service nfs-kernel-server start"

echo "now on the client 'mount -t nfs <serverid>:/foldershare clientfolder"
