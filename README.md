# 🛡️ Enterprise Network Security Lab — Cybersecurity Portfolio

> A hands-on, 3-month project building a fully virtualized enterprise-grade security lab from scratch.  
> Documented for professional portfolio use — covering network architecture, firewall hardening, IDS/IPS, VPN, threat simulation, and incident response.

---

## 📋 Project Overview

| Detail | Info |
|--------|------|
| **Duration** | 3 Months (1 day/week) |
| **Host OS** | Linux (KVM + virt-manager) |
| **Firewall** | pfSense |
| **Attacker** | Kali Linux |
| **Target** | Ubuntu Server 22.04 LTS |
| **Goal** | Simulate a real enterprise LAN with full security monitoring |

---

## 🗺️ Lab Network Diagram

```
[ Internet / WAN ]
        |
   [ pfSense ]  ← Firewall, Router, DHCP, VPN Gateway
   /         \
[LAN 1]     [LAN 2 - DMZ]
Kali         Ubuntu Server
10.0.1.10    10.0.2.10
```

> Full diagram with Wireshark capture points, IDS placement, and VPN tunnel overlay available in [`/diagrams/`](./diagrams/)

---

## 📁 Repository Structure

```
cybersec-portfolio/
├── README.md                  ← You are here
├── docs/
│   ├── 01-environment-setup.md
│   ├── 02-network-design.md
│   ├── 03-pfsense-config.md
│   ├── 04-firewall-rules.md
│   ├── 05-ids-suricata.md
│   ├── 06-vpn-setup.md
│   ├── 07-nmap-scanning.md
│   ├── 08-vulnerability-assessment.md
│   ├── 09-incident-response.md
│   └── 10-final-report.md
├── scripts/
│   ├── setup-kvm-networking.sh
│   ├── deploy-suricata.sh
│   ├── scan-and-log.sh
│   └── incident-response-drill.sh
├── diagrams/
│   ├── network-topology.png
│   └── attack-surface-map.png
└── .github/
    └── CODEOWNERS
```

---

## 🏗️ Project Roadmap

### Phase 1 — Foundation (Month 1, Weeks 1–2)
- [x] Set up KVM + virt-manager on Linux host
- [x] Create isolated virtual networks (virbr interfaces)
- [x] Deploy pfSense with WAN/LAN/DMZ interfaces
- [x] Configure DHCP, DNS resolver, and NTP

### Phase 2 — Security Infrastructure (Month 1–2, Weeks 3–6)
- [ ] Harden pfSense: disable unused services, enable logging
- [ ] Configure stateful firewall rules per network segment
- [ ] Deploy Suricata IDS/IPS inline on pfSense
- [ ] Set up pfSense Dashboard + Logging to syslog

### Phase 3 — Attack Simulation (Month 2, Weeks 7–9)
- [ ] Network reconnaissance with Nmap (SYN scan, OS detection, service enum)
- [ ] Packet capture and analysis with Wireshark + tcpdump
- [ ] Vulnerability scanning with OpenVAS / Greenbone
- [ ] Metasploit exploitation against intentionally vulnerable services

### Phase 4 — Detection & Response (Month 3, Weeks 10–12)
- [ ] Validate Suricata alert triggering on attack traffic
- [ ] Simulate incident response runbook
- [ ] Configure WireGuard VPN for secure remote admin
- [ ] Generate final security assessment report

---

## 🧰 Tools & Technologies

| Category | Tool |
|----------|------|
| Virtualization | KVM, QEMU, virt-manager, libvirt |
| Firewall / Router | pfSense CE 2.7+ |
| IDS/IPS | Suricata (via pfSense package) |
| Attacker Toolkit | Kali Linux, Nmap, Metasploit, Hydra, Gobuster |
| Traffic Analysis | Wireshark, tcpdump |
| Vulnerability Scanning | OpenVAS / Greenbone Community |
| VPN | WireGuard (pfSense plugin) |
| Log Management | Graylog or ELK Stack (Elasticsearch, Logstash, Kibana) |
| Documentation | Markdown, draw.io, Obsidian |

---

## 📈 Skills Demonstrated

- Network architecture and VLAN/segment design
- Linux system administration
- Firewall rule creation and policy enforcement
- Intrusion detection system tuning and alert analysis
- Penetration testing methodology (recon → exploit → post-exploit)
- Vulnerability assessment and CVSS scoring
- VPN configuration and PKI basics
- Incident response documentation and runbook creation
- Security report writing for both technical and executive audiences

---

## 📄 Documentation Standards

Every lab session is documented with:
1. **Objective** — What was the goal?
2. **Commands Used** — All CLI commands with explanations
3. **Screenshots/Captures** — Terminal output, Wireshark captures, alert logs
4. **Observations** — What worked, what didn't, what was unexpected
5. **Takeaways** — Security lessons learned and real-world parallels

---

## 🔗 Author

aayush  
Aspiring Cybersecurity student | Network Security Enthusiast  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/yourusername)

---

> ⚠️ **Disclaimer**: All attack simulations are performed in an isolated, air-gapped virtual environment on hardware I own. This project is for educational purposes only.
