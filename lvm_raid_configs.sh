#!/bin/bash
sudo apt update
sudo apt install mdadm lvm2
set -e

# Directory for configs
CONFIG_DIR=./lvm_raid_configs
mkdir -p $CONFIG_DIR

# Disk files
DISKS=("disk1.img" "disk2.img" "disk3.img")

# Loop devices
LOOPS=()

echo "Attaching sparse files to loop devices..."
for d in "${DISKS[@]}"; do
    losetup -fP $d
    LOOPS+=($(losetup -j $d | awk -F: '{print $1}'))
done

echo "Creating RAID 5 array..."
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 "${LOOPS[@]}"

# Save RAID config
mdadm --detail --scan > $CONFIG_DIR/mdadm.conf

echo "Creating LVM physical volume..."
pvcreate /dev/md0

echo "Creating volume group 'pool'..."
vgcreate pool /dev/md0

echo "Creating logical volumes..."
lvcreate -L 2G -n app pool
lvcreate -L 1.9G -n logs pool

echo "Formatting logical volumes..."
mkfs.ext4 /dev/pool/app
mkfs.ext4 /dev/pool/logs

echo "Creating mount points..."
mkdir -p /mnt/app
mkdir -p /mnt/logs

echo "Mounting logical volumes..."
mount /dev/pool/app /mnt/app
mount /dev/pool/logs /mnt/logs

echo "Setup complete."
echo "Application files go in /mnt/app (e.g., docker-compose.yml, app.py)"
echo "Logs go in /mnt/logs/app_logs"
