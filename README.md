# App and Monitoring Stack on LVM RAID
Provisioned Infra with LVM + RAID + Ansible + Monitoring

## Disk Image Creation (Optional)
Sparse partitioning was used to create 2 GB disk image files, which were then mounted for the RAID setup.
You can skip this step if you already have disks available.
Run the Script: 
```bash
./create_disk_img.sh
```
Key Notes
Sparse files: fallocate creates sparse files efficiently without writing zeros across the entire file.
File names: The disks will be named disk1.img, disk2.img, and disk3.img.
Size: Each disk is exactly 2 GB.

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
To start Grafana service and attach [dashboard.json](Dashboard.json)
Run 
```bash
sudo bash monitor.sh
```
what it contains 
|      RAID Layer        |  LVM Layer        |   Docker Layer         |    App Layer     |
|------------------------|-------------------|------------------------|------------------|
| RAID 5 disk Status     | lv_app usage %    | Container CPU & Memory | Requests-per-min |
| RAID Write/Read (MB/s) | lv_logs usage %   | Restarts               | Error Rate       |
<img width="1513" height="502" alt="image" src="https://github.com/user-attachments/assets/7ca2a467-9b84-469b-90c6-4dfcf657dddb" />


### Note :
I noticed defaultly, node_exporter only exposes RAID device metrics (e.g. node_md_disks{device="md0"}) and does not provide per-disk metrics within the array (e.g. you cannot filter disk="loop19" for a specific member of md0).
To work around this, I created a small Bash script [md_loop_exporter.sh](md_loop_exporter.sh) that generates custom per-disk RAID metrics and writes them to the textfile collector directory, allowing Prometheus to scrape them.
### Setup
```bash
sudo nano /usr/local/bin/md_loop_exporter.sh
sudo chmod +x /usr/local/bin/md_loop_exporter.sh

sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector
sudo chmod 755 /var/lib/node_exporter/textfile_collector

# Test
sudo /usr/local/bin/md_loop_exporter.sh
cat /var/lib/node_exporter/textfile_collector/md_loop.prom

# Run every minute
sudo crontab -e -u node_exporter
* * * * * /usr/local/bin/md_loop_exporter.sh
```
<img width="250" height="286" alt="image" src="https://github.com/user-attachments/assets/f27d061c-40a4-4ce3-b190-4957a95be284" />






