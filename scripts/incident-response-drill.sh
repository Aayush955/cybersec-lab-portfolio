#!/usr/bin/env bash
# ============================================================
#  incident-response-drill.sh
#  Cybersecurity Home Lab — IR Simulation Playbook (Attacker)
#  Author: [Your Name]
#  Description: Runs a structured, logged attack simulation
#               from Kali Linux against the Ubuntu target.
#               Each phase is time-stamped for correlation
#               with IDS alerts and firewall logs.
#               TARGET: 10.0.2.10 (Ubuntu Server in DMZ)
# ============================================================

set -euo pipefail

TARGET="${1:-10.0.2.10}"
LOGFILE="$HOME/ir-drill-$(date +%Y%m%d-%H%M%S).log"
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

banner() {
  echo -e "${RED}"
  echo "╔══════════════════════════════════════════════════╗"
  echo "║   INCIDENT RESPONSE DRILL — LAB ENVIRONMENT     ║"
  echo "║   Target: $TARGET                           ║"
  echo "║   Operator: $(whoami)@$(hostname)                      ║"
  echo "║   Time: $(date)              ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

phase() {
  local NUM="$1"; local DESC="$2"
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}[PHASE $NUM]${NC} $DESC  — $(date '+%H:%M:%S')"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_cmd() {
  echo "[$(date '+%H:%M:%S')] CMD: $*" | tee -a "$LOGFILE"
}

run() {
  log_cmd "$@"
  "$@" 2>&1 | tee -a "$LOGFILE" || true
}

# ---- Preflight -----------------------------------------------
banner
echo "All output is being logged to: $LOGFILE"
echo ""
read -rp "Confirm target is $TARGET and this is a lab environment [y/N]: " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

# ---- Phase 1: Passive Reconnaissance -------------------------
phase 1 "Passive Recon — Host Discovery"

run nmap -sn 10.0.2.0/24 -oG - | grep "Up"
echo ""
echo "IDS CORRELATION: Host discovery pings may trigger"
echo "  Suricata SID: ET SCAN NMAP -sP ... (threshold-based)"

# ---- Phase 2: Port Scanning ----------------------------------
phase 2 "Port Scanning — SYN Scan + Service Detection"

run nmap -sS -sV -O -T4 -p- --open "$TARGET" \
  -oN "$HOME/nmap-full-$TARGET.txt"

echo ""
echo "IDS CORRELATION: SYN scan triggers:"
echo "  Suricata ET SCAN NMAP SYN alerts on rapid port cycling"

# ---- Phase 3: Vulnerability Identification -------------------
phase 3 "Vulnerability Scan — NSE Scripts"

run nmap --script vuln "$TARGET" \
  -oN "$HOME/nmap-vuln-$TARGET.txt"

# ---- Phase 4: Service-level Probing --------------------------
phase 4 "Service Probing — Banner Grabbing"

# HTTP banner grab
run curl -sv --max-time 5 "http://$TARGET/" 2>&1 | head -40 || true

# SSH version check
run nc -w3 "$TARGET" 22 <<< "" 2>&1 | head -5 || true

# ---- Phase 5: Auth Brute Force Simulation --------------------
phase 5 "Brute Force Simulation — SSH (5 attempts only)"

echo "NOTE: This uses a 5-attempt cap to trigger IDS without locking accounts."
run hydra -l admin -P /usr/share/wordlists/rockyou.txt \
  -f -t 4 -W 3 "$TARGET" ssh \
  -o "$HOME/hydra-result.txt" \
  2>&1 | head -30 || true

echo ""
echo "IDS CORRELATION: SSH brute force triggers:"
echo "  ET SCAN SSH Brute Force (multiple failed auths)"
echo "  pfSense can block source IP after N failures via pfBlockerNG"

# ---- Phase 6: Evidence Capture Summary -----------------------
phase 6 "Evidence Collection Summary"

echo ""
echo -e "${GREEN}=== Drill Complete ===${NC}"
echo ""
echo "Generated files:"
ls -lh "$HOME"/nmap-*.txt "$HOME"/hydra-result.txt "$LOGFILE" 2>/dev/null || true
echo ""
echo -e "${CYAN}Next steps for IR documentation:${NC}"
echo "  1. Collect Suricata alerts:    ssh ubuntu-server 'sudo cat /var/log/suricata/fast.log'"
echo "  2. Collect pfSense firewall log from Web UI → Status → System Logs → Firewall"
echo "  3. Timeline correlation: match this log timestamps to IDS alert timestamps"
echo "  4. Document findings in docs/09-incident-response.md"
echo ""
echo "Full drill log saved to: $LOGFILE"
