# Phase 1 - Environment Setup

## Objective
Set up KVM virtualization on Linux host
to run the security lab virtual machines.

## Date
2024-03-17

## Tools Used
- Linux host OS
- KVM + virt-manager
- libvirt

## Steps Taken

### 1. Check CPU supports virtualization
egrep -c '(vmx|svm)' /proc/cpuinfo

### 2. Install KVM
sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager

### 3. Start libvirt service
sudo systemctl enable --now libvirtd

### 4. Add user to libvirt group
sudo usermod -aG libvirt $USER

## Observations
- CPU supports virtualization
- libvirtd running successfully
- virt-manager GUI working

## Issues Encountered
None

## Takeaways
- KVM runs at near native speed
- User must log out after adding to libvirt group

## Next Steps
- Create virtual networks
- Deploy pfSense firewall VM
