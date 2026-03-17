# 01 — Environment Setup: KVM + virt-manager

## Objective
Build the virtualization foundation. All VMs will run on a single Linux laptop using KVM/QEMU managed by virt-manager and libvirt.

---

## Prerequisites

- Linux host (Ubuntu 22.04 / Debian 12 / Fedora 38+ recommended)
- CPU with VT-x or AMD-V support (check with `egrep -c '(vmx|svm)' /proc/cpuinfo`)
- At minimum 16 GB RAM, 200 GB free disk
- Internet access for initial downloads

---

## Step 1 — Verify Virtualization Support

```bash
# Check CPU virtualization extensions (output > 0 means supported)
egrep -c '(vmx|svm)' /proc/cpuinfo

# Check KVM module availability
lsmod | grep kvm

# Run full compatibility check
sudo kvm-ok
```

**Expected output:**
```
INFO: /dev/kvm exists
KVM acceleration can be used
```

---

## Step 2 — Install KVM Stack

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  virt-manager \
  virtinst \
  ovmf

# Add your user to the libvirt and kvm groups
sudo usermod -aG libvirt,kvm $USER

# Log out and back in, then verify
groups $USER
```

---

## Step 3 — Start and Enable libvirt

```bash
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd
```

---

## Step 4 — Verify with virsh

```bash
# List available connection URIs
virsh uri

# List all VMs (should be empty at this point)
virsh list --all

# Check default network
virsh net-list --all
```

---

## Step 5 — Launch virt-manager

```bash
virt-manager
```

If running headlessly, use `--no-fork` and ensure X11 forwarding or a display manager is active.

---

## Network Design (Pre-planned)

| Network Name | Type | Subnet | Purpose |
|---|---|---|---|
| `lab-wan` | NAT (to host) | 192.168.100.0/24 | pfSense WAN |
| `lab-lan` | Isolated | 10.0.1.0/24 | Internal LAN |
| `lab-dmz` | Isolated | 10.0.2.0/24 | DMZ segment |

> These will be created in the next phase using `virsh net-define` with custom XML configs.

---

## Observations

- KVM runs at near-native speed for network VMs — pfSense performs well even with limited vCPUs
- libvirt's "Isolated" network mode ensures no accidental host-to-VM routing outside of pfSense
- OVMF (UEFI firmware) is installed for modern OS support

---

## Takeaways

- Always verify VT-x/AMD-V before starting — KVM without hardware acceleration is too slow for this lab
- Group membership (`libvirt`, `kvm`) requires logout/login to take effect
- `virsh` CLI is equally powerful as virt-manager GUI — learn both

---

## Next Step → [`02-network-design.md`](./02-network-design.md)
