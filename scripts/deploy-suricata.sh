#!/usr/bin/env bash
# ============================================================
#  deploy-suricata.sh
#  Cybersecurity Home Lab — Suricata IDS Setup (Ubuntu target)
#  Author: [Your Name]
#  Description: Installs and configures Suricata IDS on Ubuntu
#               Server. Run this ON the Ubuntu Server VM.
#               Monitors the primary interface for threats.
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()   { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

IFACE="${1:-ens3}"   # Pass interface as arg, default ens3
RULES_DIR="/etc/suricata/rules"
LOG_DIR="/var/log/suricata"

log "Target interface: $IFACE"
log "Checking root..."
[[ $EUID -eq 0 ]] || error "Run as root: sudo $0"

# ---- Install Suricata ----------------------------------------
log "Adding Suricata PPA and installing..."
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update -q
apt-get install -y suricata suricata-update jq
ok "Suricata installed: $(suricata --build-info | grep 'Version' | head -1)"

# ---- Update Rules --------------------------------------------
log "Updating rule sets via suricata-update..."
suricata-update update-sources
suricata-update enable-source et/open          # Emerging Threats (free)
suricata-update enable-source ptresearch/master
suricata-update
ok "Rules updated and compiled."

# ---- Configure Suricata --------------------------------------
log "Configuring /etc/suricata/suricata.yaml..."

# Set HOME_NET to local subnets
sed -i 's|HOME_NET: .*|HOME_NET: "[10.0.0.0/8,192.168.0.0/16,172.16.0.0/12]"|' \
  /etc/suricata/suricata.yaml

# Set the monitored interface
sed -i "/af-packet:/,/^[^ ]/ s/interface: .*/interface: $IFACE/" \
  /etc/suricata/suricata.yaml

# Enable eve-log JSON output
sed -i 's/enabled: no  # eve-log/enabled: yes  # eve-log/' \
  /etc/suricata/suricata.yaml

ok "suricata.yaml configured for interface $IFACE"

# ---- Validate Config -----------------------------------------
log "Validating configuration..."
suricata -T -c /etc/suricata/suricata.yaml -v && ok "Config valid." \
  || error "Config validation failed. Check /etc/suricata/suricata.yaml"

# ---- Enable and Start Service --------------------------------
log "Enabling Suricata systemd service..."
systemctl enable suricata
systemctl restart suricata
sleep 3
systemctl is-active --quiet suricata && ok "Suricata running." \
  || error "Suricata failed to start. Check: journalctl -u suricata"

# ---- Quick Smoke Test ----------------------------------------
log "Running smoke test (curl to scanme.nmap.org)..."
curl -s http://scanme.nmap.org > /dev/null || true
sleep 2

ALERT_COUNT=$(jq -s '[.[] | select(.event_type=="alert")] | length' \
  "$LOG_DIR/eve.json" 2>/dev/null || echo "0")
log "Alerts in eve.json so far: $ALERT_COUNT (may be 0 at initial setup)"

# ---- Final Summary -------------------------------------------
echo ""
ok "=== Suricata Deployment Complete ==="
echo ""
echo -e "${CYAN}Key paths:${NC}"
echo "  Config:    /etc/suricata/suricata.yaml"
echo "  Rules:     $RULES_DIR"
echo "  JSON log:  $LOG_DIR/eve.json"
echo "  Fast log:  $LOG_DIR/fast.log"
echo ""
echo -e "${CYAN}Useful commands:${NC}"
echo "  Watch alerts live:  sudo tail -f $LOG_DIR/fast.log"
echo "  JSON alert query:   sudo jq 'select(.event_type==\"alert\")' $LOG_DIR/eve.json"
echo "  Reload rules:       sudo suricatasc -c reload-rules"
echo "  Service status:     sudo systemctl status suricata"
echo ""
