#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║         CYBERSEC PORTFOLIO — GitHub Profile Setup Script        ║
# ║                                                                  ║
# ║  Run this script on any Linux/macOS machine with git + curl.    ║
# ║  It will:                                                        ║
# ║    1. Check for git + GitHub CLI (gh)                           ║
# ║    2. Initialize your portfolio repo with all files             ║
# ║    3. Create a GitHub profile README (special repo)             ║
# ║    4. Push everything to GitHub                                  ║
# ║                                                                  ║
# ║  Usage:  chmod +x github-setup.sh && ./github-setup.sh          ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()    { echo -e "${GREEN}✔${NC}  $*"; }
info()  { echo -e "${CYAN}→${NC}  $*"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $*"; }
error() { echo -e "${RED}✖ ERROR:${NC} $*"; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}── $* ──────────────────────────────${NC}"; }

clear
echo -e "${BOLD}${CYAN}"
cat << 'BANNER'
  ██████╗ ██╗████████╗██╗  ██╗██╗   ██╗██████╗
 ██╔════╝ ██║╚══██╔══╝██║  ██║██║   ██║██╔══██╗
 ██║  ███╗██║   ██║   ███████║██║   ██║██████╔╝
 ██║   ██║██║   ██║   ██╔══██║██║   ██║██╔══██╗
 ╚██████╔╝██║   ██║   ██║  ██║╚██████╔╝██████╔╝
  ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝

   Cybersecurity Portfolio — GitHub Setup Script
BANNER
echo -e "${NC}"

# ── Step 0: Collect user info ────────────────────────────────────────
step "Configuration"

read -rp "$(echo -e "${CYAN}?${NC} Your GitHub username: ")" GH_USER
read -rp "$(echo -e "${CYAN}?${NC} Your full name (for README): ")" FULL_NAME
read -rp "$(echo -e "${CYAN}?${NC} Your email: ")" GH_EMAIL
read -rp "$(echo -e "${CYAN}?${NC} Portfolio repo name [cybersec-lab-portfolio]: ")" REPO_NAME
REPO_NAME="${REPO_NAME:-cybersec-lab-portfolio}"

echo ""
info "GitHub User : $GH_USER"
info "Full Name   : $FULL_NAME"
info "Email       : $GH_EMAIL"
info "Repo Name   : $REPO_NAME"
echo ""
read -rp "$(echo -e "${YELLOW}?${NC} Continue? [y/N]: ")" CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ── Step 1: Dependency checks ────────────────────────────────────────
step "Checking Dependencies"

command -v git  >/dev/null 2>&1 && ok "git found" || error "git not installed. Run: sudo apt install git"
command -v curl >/dev/null 2>&1 && ok "curl found" || error "curl not installed."

# GitHub CLI check
if ! command -v gh >/dev/null 2>&1; then
  warn "GitHub CLI (gh) not found. Attempting install..."
  if command -v apt-get >/dev/null 2>&1; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -q && sudo apt-get install -y gh
    ok "GitHub CLI installed."
  else
    error "Please install GitHub CLI manually: https://cli.github.com/manual/installation"
  fi
else
  ok "GitHub CLI found: $(gh --version | head -1)"
fi

# ── Step 2: Git config ───────────────────────────────────────────────
step "Configuring Git"

git config --global user.name  "$FULL_NAME"
git config --global user.email "$GH_EMAIL"
git config --global init.defaultBranch main
ok "Git configured for $FULL_NAME <$GH_EMAIL>"

# ── Step 3: GitHub auth ──────────────────────────────────────────────
step "GitHub Authentication"

if gh auth status >/dev/null 2>&1; then
  ok "Already authenticated with GitHub."
else
  info "Launching GitHub authentication flow..."
  gh auth login --hostname github.com --git-protocol https --web
  ok "GitHub authentication complete."
fi

# ── Step 4: Create portfolio repo ───────────────────────────────────
step "Creating Portfolio Repository: $REPO_NAME"

WORK_DIR="$HOME/$REPO_NAME"

if [[ -d "$WORK_DIR/.git" ]]; then
  warn "Directory $WORK_DIR already has a git repo. Skipping init."
else
  mkdir -p "$WORK_DIR"
  cd "$WORK_DIR"
  git init
  ok "Git repo initialized at $WORK_DIR"
fi

cd "$WORK_DIR"

# Copy files from script's directory if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/README.md" ]]; then
  cp -r "$SCRIPT_DIR"/* "$WORK_DIR/" 2>/dev/null || true
  ok "Copied portfolio files from $SCRIPT_DIR"
fi

# ── Step 5: Generate profile README ─────────────────────────────────
step "Creating GitHub Profile README"

PROFILE_DIR="$HOME/${GH_USER}"
mkdir -p "$PROFILE_DIR"

cat > "$PROFILE_DIR/README.md" << PROFILE_README
<h1 align="center">Hey, I'm ${FULL_NAME} 👋</h1>

<p align="center">
  <b>Cybersecurity Enthusiast | Network Security | Ethical Hacking</b><br/>
  Building enterprise-grade security skills, one lab at a time.
</p>

---

## 🔐 Featured Project

### 🛡️ [Enterprise Network Security Lab](https://github.com/${GH_USER}/${REPO_NAME})

A 3-month hands-on cybersecurity project simulating a real enterprise network:

- **pfSense** firewall with multi-segment architecture (LAN + DMZ)
- **Suricata IDS/IPS** with Emerging Threats rule sets
- **Kali Linux** attacker simulating penetration testing scenarios
- **WireGuard VPN** for secure remote administration
- Full documentation: network diagrams, configs, incident reports

---

## 🧰 Skills & Tools

\`\`\`
Network Security     │ pfSense, Suricata, Wireshark, tcpdump
Penetration Testing  │ Nmap, Metasploit, Hydra, Gobuster
Vulnerability Mgmt   │ OpenVAS / Greenbone, CVSS scoring
Virtualization       │ KVM, QEMU, virt-manager, libvirt
Operating Systems    │ Linux (Ubuntu, Kali, Debian), pfSense BSD
Scripting            │ Bash, Python
Documentation        │ Markdown, draw.io, structured reporting
\`\`\`

---

## 📈 Currently Learning

- [ ] SIEM integration (Wazuh / ELK Stack)
- [ ] Cloud security fundamentals (AWS VPC, Security Groups)
- [ ] Active Directory attacks and defenses
- [ ] Preparing for CompTIA Security+ / CEH

---

## 📫 Connect

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin)](https://linkedin.com/in/${GH_USER})
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?logo=github)](https://github.com/${GH_USER})

---

<p align="center"><i>"Security is not a product, but a process." — Bruce Schneier</i></p>
PROFILE_README

ok "Profile README generated at $PROFILE_DIR/README.md"

# ── Step 6: Push portfolio repo ──────────────────────────────────────
step "Pushing Portfolio Repo to GitHub"

cd "$WORK_DIR"

# Create initial commit
git add -A
git commit -m "🛡️ Initial commit: Cybersecurity home lab portfolio" 2>/dev/null || true

# Create GitHub repo and push
if gh repo view "${GH_USER}/${REPO_NAME}" >/dev/null 2>&1; then
  warn "Repo ${GH_USER}/${REPO_NAME} already exists on GitHub — pushing to existing."
  git remote set-url origin "https://github.com/${GH_USER}/${REPO_NAME}.git" 2>/dev/null \
    || git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
else
  gh repo create "${REPO_NAME}" \
    --public \
    --description "Enterprise network security home lab — pfSense, Suricata IDS, Kali, VPN, IR simulation" \
    --source="$WORK_DIR" \
    --remote=origin \
    --push
  ok "GitHub repo created: https://github.com/${GH_USER}/${REPO_NAME}"
fi

git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || true
ok "Portfolio pushed to GitHub."

# ── Step 7: Push profile README ─────────────────────────────────────
step "Pushing GitHub Profile README"

cd "$PROFILE_DIR"
git init
git config user.name  "$FULL_NAME"
git config user.email "$GH_EMAIL"
git add README.md
git commit -m "✨ GitHub profile README"

if gh repo view "${GH_USER}/${GH_USER}" >/dev/null 2>&1; then
  warn "Profile repo ${GH_USER}/${GH_USER} already exists — pushing."
  git remote set-url origin "https://github.com/${GH_USER}/${GH_USER}.git" 2>/dev/null \
    || git remote add origin "https://github.com/${GH_USER}/${GH_USER}.git"
else
  gh repo create "${GH_USER}" \
    --public \
    --description "GitHub profile README" \
    --source="$PROFILE_DIR" \
    --remote=origin
  ok "Profile repo created: https://github.com/${GH_USER}/${GH_USER}"
fi

git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || true
ok "Profile README pushed — visible at https://github.com/${GH_USER}"

# ── Done ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}"
cat << 'DONE'
  ╔══════════════════════════════════════════╗
  ║       ✅  ALL DONE — SETUP COMPLETE      ║
  ╚══════════════════════════════════════════╝
DONE
echo -e "${NC}"
echo -e "  ${CYAN}Portfolio repo :${NC} https://github.com/${GH_USER}/${REPO_NAME}"
echo -e "  ${CYAN}Profile page   :${NC} https://github.com/${GH_USER}"
echo ""
echo -e "  ${YELLOW}Next steps:${NC}"
echo "    1. Add a profile photo in GitHub Settings"
echo "    2. Pin your $REPO_NAME repo on your profile"
echo "    3. Add network topology diagrams to /diagrams/"
echo "    4. Enable GitHub Pages for a hosted portfolio site"
echo ""
