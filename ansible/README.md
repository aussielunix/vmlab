# KVM Host on an Intel NUC with Ubuntu LTS Server (20.04)

Ansible is used as the automation of choice.  
Build/maintain Intel NUC Ubuntu LTS Server (20.04) install with the following roles:

* Ubuntu LTS Server (20.04) headless
  * libvirt/kvm/virtman/uvtool to manage virtual machines
  * Ethernet (eno1) bridge for local and VM traffic
* configure a dns recursor for the whole network to use that exports /etc/hosts as forwar/reverse dns records
