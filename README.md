# VM Lab Automation

A monorepo of automation and notes to build and maintain a VM Lab upon Ubuntu Server LTS and libvirt/kvm.  
Ansible is used as the automation of choice. (with a little bash)

## Outcome

An Ubuntu LTS Server install with the following capabilities:

* libvirt/kvm configured ready to host VMs
* br0 bridge for local and VM traffic (eno1/ethernet only)
* opinionated scripts wrapping uvtool to manage virtual machines
* configure a VM as a simple dns authortative server

## Tutorial

This assumes you have an Ubuntu Server LTS (20.04/Focal) install and direct console access.  
**Tested on an Intel Skull Canyon NUC (NUC6i7KYB)**

```bash
git clone ...
ansible-playbook networking.yml
ansible-playbook virt.yml
```

Before you can create any VMs you will need to sync the latest cloud image to your host.  
This will take some time.
```bash
uvt-simplestreams-libvirt sync release=focal arch=amd64
```

Now create a cluster of VMs

* declare the cluster in `etc/cluster.cfg`
  `NAME,IP,DISK,RAM,CPU`

```
lb01,192.168.20.10,20,4,1
master01,192.168.20.11,20,4,1
master02,192.168.20.12,20,4,1
master03,192.168.20.13,20,4,1
worker01,192.168.20.21,100,4,1
worker02,192.168.20.22,100,4,1
worker03,192.168.20.23,100,4,1
```
* tune [dns](https://github.com/aussielunix/homelab/blob/master/ansible/files/etc_hosts) to match `etc/cluster.cfg`

```bash
cd ansible
ansible-playbook dns.yml
cd ../
bin/cluster up
creating cluster declared in etc/cluster.cfg

Creating lb01 with 20GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.10
.......................
Creating master01 with 20GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.11
..................
Creating master02 with 20GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.12
................
Creating master03 with 20GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.13
.................
Creating worker01 with 100GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.21
...................
Creating worker02 with 100GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.22
..................
Creating worker03 with 100GB of disk, 4096 of RAM, 1 cpu cores and a static ip 192.168.20.23
..................
```

You can destroy the whole cluster with a simple command too but be very careful.

```bash
bin/cluster down
```

## Repo Layout

```
.
├── ansible
├── bin
├── cluster.cfg
├── lib
```

### ansible

A collection of Ansible playbooks and roles to configure your VM Lab.

### bin

A directory with a collection of shell scripts.  
I write bash much quicker than Ansible so this is my go to place for speed of development.  
These should likely be ansible plays one day.

### etc/cluster.cfg

This is a list of VMs to create and their details.  
**Currently only one VM name and static IP, separated by a comma, per line.**  
**Note: you must make sure [dns](https://github.com/aussielunix/homelab/blob/master/ansible/files/etc_hosts) is setup for each host in the cluster**

```
worker01,192.168.20.21
worker02,192.168.20.22
```

### lib

bash library for creating/destroying VMs using uvtool and template for userdata.

## Notes

Replace bash for creating VMs with ansible.
https://github.com/zdw/platform-install/blob/master/roles/create-vms/tasks/main.yml

Awesome collection of ansible and bash
https://github.com/jerrywardlow/devops-playground
