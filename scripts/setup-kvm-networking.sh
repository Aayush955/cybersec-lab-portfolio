#!/usr/bin/env bash
# ============================================================
#  setup-kvm-networking.sh
#  Cybersecurity Home Lab — Virtual Network Bootstrap Script
#  Author: [Your Name]
#  Description: Creates the three isolated virtual networks
#               (WAN/NAT, LAN isolated, DMZ isolated) required
#               for the pfSense-based lab environment.
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()     { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---- Preflight checks ----------------------------------------

log "Checking dependencies..."
command -v virsh      >/dev/null 2>&1 || error "virsh not found. Install libvirt-clients."
command -v brctl      >/dev/null 2>&1 || error "brctl not found. Install bridge-utils."

if ! systemctl is-active --quiet libvirtd; then
  warn "libvirtd is not running. Attempting to start..."
  sudo systemctl start libvirtd || error "Failed to start libvirtd."
fi
ok "libvirtd is running."

# ---- Helper: define and start a network ----------------------

define_network() {
  local NAME="$1"
  local XML="$2"

  if virsh net-info "$NAME" >/dev/null 2>&1; then
    warn "Network '$NAME' already exists — skipping definition."
  else
    echo "$XML" | virsh net-define /dev/stdin
    ok "Defined network: $NAME"
  fi

  if ! virsh net-info "$NAME" | grep -q "Active:.*yes"; then
    virsh net-start "$NAME"
    ok "Started network: $NAME"
  else
    warn "Network '$NAME' already active."
  fi

  virsh net-autostart "$NAME"
  ok "Autostart enabled: $NAME"
}

# ---- Network Definitions -------------------------------------

log "Creating lab-wan (NAT mode — pfSense WAN)..."
define_network "lab-wan" '
<network>
  <name>lab-wan</name>
  <forward mode="nat">
    <nat>
      <port start="1024" end="65535"/>
    </nat>
  </forward>
  <bridge name="virbr-wan" stp="on" delay="0"/>
  <ip address="192.168.100.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.100.2" end="192.168.100.50"/>
    </dhcp>
  </ip>
</network>'

log "Creating lab-lan (Isolated — Internal LAN)..."
define_network "lab-lan" '
<network>
  <name>lab-lan</name>
  <bridge name="virbr-lan" stp="on" delay="0"/>
</network>'

log "Creating lab-dmz (Isolated — DMZ segment)..."
define_network "lab-dmz" '
<network>
  <name>lab-dmz</name>
  <bridge name="virbr-dmz" stp="on" delay="0"/>
</network>'

# ---- Verification --------------------------------------------

echo ""
log "=== Network Status ==="
virsh net-list --all

echo ""
log "=== Bridge Interfaces on Host ==="
ip link show | grep virbr || warn "No virbr interfaces found yet."

echo ""
ok "All lab networks configured successfully."
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Deploy pfSense ISO via virt-manager"
echo "     Attach NICs: lab-wan (em0), lab-lan (em1), lab-dmz (em2)"
echo "  2. Deploy Kali Linux — attach to lab-lan"
echo "  3. Deploy Ubuntu Server — attach to lab-dmz"
echo "  4. Follow docs/03-pfsense-config.md for firewall setup"
echo ""
