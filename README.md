# Provisioned-Infrastructure
Provisioned Infra with LVM + RAID + Ansible + Monitoring

## Disk Image Creation (Optional)
Sparse partitioning was used to create 2 GB disk image files, which were then mounted for the RAID setup.
You can skip this step if you already have disks available.
Run the Script: 
```bash
./create_disk_img.sh
```
## LVM & RAID Configuration
**lvm_raid_config.sh** Script includes the setup of RAID 5 setup of 3 disks 2GB (6GBin Total) and an LVM having

|    RAID Setup         |       LVM Configuration                |  Directory Usage **(Update the script if you wish to change the application file names)**               |
|-----------------------|----------------------------------------|-------------------------------------------------------------------------------------------------------|
| Type: RAID 5          | Volume Group: 2 GB pool                | /mnt/app Contains application files eg. docker-compose.yml & app.py.                                      |
| Disks: 3 × 2 GB       |      Logical Volumes                   | /mnt/logs/app_logs Dedicated to storing container application logs for easier monitoring and maintenance. |
| Total Capacity: 6 GB  | . /mnt/app → 2 GB ./mnt/logs → 1.9 GB  |  
Run the Script: 
```bash
./lvm_raid_config.sh
```
## Deploy app Stack in ansible
Adjust the playbook.yml file it contains 
- Installs packages (curl, gnupg, prometheus, docker.io, grafana, node_exporter)
- Configures firewall
- Creates users (admin)
- Deploys Docker containers
- Starts services

**NOTE: Copy app files to { ./app } **
```bash
./app/ansible-proj/playbook.yml
```

## Monitoring the storage 
start Gr



