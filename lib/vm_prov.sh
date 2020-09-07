#!/usr/bin/env bash

## Usage guide
#
usage() {
  echo "Usage: $(basename $0) [options]

  Options:

        up: Create cluster
        down: Destroy cluster
  "
}

# generate a userdata file from template
# @NODE - *required* - the name of the new VM
#
create_userdata() {
  declare NODE="$1"
  echo -e "#cloud-config\nhostname: ${NODE}\nfqdn: ${NODE}.lunix.lan" >> tmp/${NODE}.cfg
  cat lib/templates/user_data.tmpl >> tmp/${NODE}.cfg
}

# generate a static network config ile from template
# @NODE - *required* - the name of the new VM
# @IPADDRESS - *required* - the static ip address of the new VM
#
create_network_conf() {
  declare NODE="$1"
  declare IPADDRESS="$2"
cat <<EOF >> tmp/${NODE}.netplan
version: 2
ethernets:
  enp1s0:
     dhcp4: false
     # default libvirt network
     addresses: [ ${IPADDRESS}/24 ]
     gateway4: 192.168.20.1
     nameservers:
       addresses: [ 192.168.20.250 ]
       search: [ lunix.lan ]
EOF
}

# Create userdata, static network config and then a new VM
# @NODE - *required* - the name of the new VM
# @IPADDRESS - *required* - the static ip address of the new VM
create_vm() {
  declare NODE="$1"
  declare IPADDRESS="$2"
  declare DISK="$3"
  declare RAM="$4"
  declare CPU="$5"

  echo "Creating ${NODE} with static ip ${IPADDRESS}"

  create_userdata ${NODE}
  create_network_conf ${NODE} ${IPADDRESS}
  uvt-kvm create ${NODE} --disk ${DISK} --memory ${RAM} --cpu ${CPU} --bridge br0 --network-config tmp/${NODE}.netplan --user-data tmp/${NODE}.cfg
}

# Wait for VM to finish
# @NODE - *required* - the name of the new VM
#
wait_vm() {
  declare NODE="$1"

  until host ${NODE} >/dev/null && ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${NODE} "cat .ready" 1>/dev/null 2>/dev/null
  do
    echo -n "."
    sleep 2
  done
  echo "."
}

# Destroy VM, userdata and network config
# @NODE - *required* - the name of the new VM
#
destroy_vm() {
  declare NODE="$1"

  echo "Destroying ${NODE}"
  rm -f tmp/${NODE}.netplan
  rm -f tmp/${NODE}.cfg
  uvt-kvm destroy $NODE
}

# Loop over etc/cluster.cfg and create VMs
#
create_cluster() {
  echo "creating cluster declared in etc/cluster.cfg"
  echo
  for VM in $(cat etc/cluster.cfg)
  do
    VMD=(${VM//,/ })
    create_vm ${VMD[0]} ${VMD[1]} ${VMD[2]} ${VMD[3]} ${VMD[4]}
  done
  echo
}

# Loop over etc/cluster.cfg and destroy VMs
#
destroy_cluster() {
  echo "destroying cluster declared in etc/cluster.cfg"
  echo
  for VM in $(cat etc/cluster.cfg)
  do
    VMD=(${VM//,/ })
    destroy_vm ${VMD[0]} ${VMD[1]}
  done
  echo
}
