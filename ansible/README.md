# KVM Host on an Intel NUC with Ubuntu 20.04

Ansible is used as the automation of choice.  
Build/maintain Intel NUC Ubuntu server install with the following roles:

* Ubuntu Server 20.04 headless
  * libvirt/kvm/virtman/uvtool to manage virtual machines
  * Network bridge for local and VM traffic
* configure a dns vm that exports /etc/hosts as dns records
