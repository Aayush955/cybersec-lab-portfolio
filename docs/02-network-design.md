# 02 — Network Design & Virtual Segmentation

## Objective
Create three isolated virtual networks in libvirt — WAN (NAT), LAN, and DMZ — so all traffic between segments flows through pfSense.

---

## Network Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Linux Host (KVM)                  │
│                                                     │
│  ┌──────────┐    ┌─────────────────┐               │
│  │ lab-wan  │    │    pfSense VM   │               │
│  │ (NAT)    │◄──►│  WAN: em0       │               │
│  │ 192.168  │    │  LAN: em1       │               │
│  │ .100.0/24│    │  DMZ: em2       │               │
│  └──────────┘    └────┬───────┬───┘               │
│                       │       │                     │
│               ┌───────┘       └──────┐             │
│          ┌────▼─────┐         ┌─────▼────┐         │
│          │ lab-lan  │         │ lab-dmz  │         │
│          │(isolated)│         │(isolated)│         │
│          │10.0.1.0  │         │10.0.2.0  │         │
│          └────┬─────┘         └─────┬────┘         │
│               │                     │              │
│          ┌────▼─────┐         ┌─────▼────┐         │
│          │Kali Linux│         │  Ubuntu  │         │
│          │10.0.1.10 │         │  Server  │         │
│          └──────────┘         │10.0.2.10 │         │
│                               └──────────┘         │
└─────────────────────────────────────────────────────┘
```

---

## Step 1 — Define Virtual Networks via XML

### WAN Network (NAT mode — pfSense gets internet via host)

```bash
cat > /tmp/lab-wan.xml << 'EOF'
<network>
  <name>lab-wan</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr-wan' stp='on' delay='0'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.100.2' end='192.168.100.50'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /tmp/lab-wan.xml
virsh net-start lab-wan
virsh net-autostart lab-wan
```

### LAN Network (Isolated — no host routing)

```bash
cat > /tmp/lab-lan.xml << 'EOF'
<network>
  <name>lab-lan</name>
  <bridge name='virbr-lan' stp='on' delay='0'/>
</network>
EOF

virsh net-define /tmp/lab-lan.xml
virsh net-start lab-lan
virsh net-autostart lab-lan
```

### DMZ Network (Isolated — separate segment)

```bash
cat > /tmp/lab-dmz.xml << 'EOF'
<network>
  <name>lab-dmz</name>
  <bridge name='virbr-dmz' stp='on' delay='0'/>
</network>
EOF

virsh net-define /tmp/lab-dmz.xml
virsh net-start lab-dmz
virsh net-autostart lab-dmz
```

---

## Step 2 — Verify Networks

```bash
virsh net-list --all
```

Expected:
```
 Name       State    Autostart   Persistent
--------------------------------------------
 lab-dmz    active   yes         yes
 lab-lan    active   yes         yes
 lab-wan    active   yes         yes
```

```bash
# Confirm bridge interfaces exist on host
ip link show | grep virbr
brctl show
```

---

## Step 3 — VM NIC Assignment Plan

| VM | NIC 1 | NIC 2 | NIC 3 |
|----|-------|-------|-------|
| pfSense | lab-wan (WAN) | lab-lan (LAN) | lab-dmz (DMZ) |
| Kali Linux | lab-lan | — | — |
| Ubuntu Server | lab-dmz | — | — |

> pfSense will act as the **only** router between all three segments.

---

## Observations

- Using `isolated` mode in libvirt prevents VMs from accidentally communicating with the host network
- Bridge names (`virbr-lan`, `virbr-dmz`) are visible in `ip link` and can be used with tcpdump on the host for traffic sniffing at the hypervisor level — very useful for capturing raw traffic

---

## Takeaways

- Network segmentation is the foundation of defense-in-depth: even if the DMZ is compromised, the attacker must still break through pfSense to reach the LAN
- Real enterprises use physical VLANs (802.1Q trunking) — this lab mirrors that logic in software
- The host bridge interfaces allow for **out-of-band traffic analysis** — capture on `virbr-dmz` to see all DMZ traffic regardless of firewall state

---

## Next Step → [`03-pfsense-config.md`](./03-pfsense-config.md)
