#!/bin/bash

# CS Tutor - Auto Setup and Launch (Linux Mint)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${BOLD}  CS Tutor - Auto Setup and Launch${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""

# -------------------------------------------------------
# 1. Check if Python is installed
# -------------------------------------------------------
echo -e "[1/4] Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}  [ERROR] Python3 is NOT installed.${NC}"
    echo ""
    echo "  Fix: Run the following command to install Python3:"
    echo "       sudo apt update && sudo apt install python3 python3-pip -y"
    echo ""
    exit 1
fi
PYVER=$(python3 --version 2>&1)
echo -e "       Found ${GREEN}${PYVER}${NC}"
echo ""

# -------------------------------------------------------
# 2. Upgrade pip silently
# -------------------------------------------------------
echo -e "[2/4] Updating pip..."
python3 -m pip install --upgrade pip --quiet 2>/dev/null || \
    python3 -m ensurepip --quiet 2>/dev/null
echo "       Done."
echo ""

# -------------------------------------------------------
# 3. Install dependencies
# -------------------------------------------------------
echo -e "[3/4] Installing dependencies..."
python3 -m pip install --quiet requests 2>/dev/null
echo "       All dependencies installed."
echo ""

# -------------------------------------------------------
# 4. Get local IP and launch
# -------------------------------------------------------
echo -e "[4/4] Starting server..."
echo ""

# Get local network IP (try multiple methods)
LOCAL_IP=""
if command -v ip &> /dev/null; then
    LOCAL_IP=$(ip -4 route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[\d.]+')
fi
if [ -z "$LOCAL_IP" ] && command -v hostname &> /dev/null; then
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
if [ -z "$LOCAL_IP" ] && command -v ifconfig &> /dev/null; then
    LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
fi

echo -e "${GREEN}====================================================${NC}"
echo ""
echo -e "${BOLD}  YOUR APP IS LIVE AT:${NC}"
echo ""
echo -e "     ${CYAN}http://localhost:8008${NC}"
echo ""
if [ -n "$LOCAL_IP" ]; then
    echo -e "  ${YELLOW}----------------------------------------------------${NC}"
    echo -e "  ${BOLD}SHARE THIS WITH OTHER DEVICES ON YOUR NETWORK:${NC}"
    echo ""
    echo -e "     ${CYAN}http://${LOCAL_IP}:8008${NC}"
    echo ""
    echo -e "  ${YELLOW}----------------------------------------------------${NC}"
else
    echo -e "  ${RED}[!] Could not detect network IP.${NC}"
    echo "      Check your WiFi/Ethernet connection."
    echo ""
fi
echo ""
echo "  Subjects: OS + C  |  Oracle SQL/PLSQL  |  React"
echo "  Models:   Llama 3.3 70B  |  GPT-OSS 120B"
echo ""
echo "  Press Ctrl+C to stop the server."
echo ""
echo -e "${GREEN}====================================================${NC}"
echo ""

# -------------------------------------------------------
# Allow through firewall (if ufw is active)
# -------------------------------------------------------
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    if echo "$UFW_STATUS" | grep -qi "active"; then
        sudo ufw allow 8008/tcp comment "CS Tutor" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}Firewall rule added for port 8008.${NC}"
        else
            echo -e "  ${YELLOW}[!] Could not add firewall rule. Run with sudo if${NC}"
            echo "      other devices on your network can't connect."
        fi
        echo ""
    fi
fi

# -------------------------------------------------------
# Install as startup service (runs for all users)
# -------------------------------------------------------
if [ "$1" = "--install" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    echo -e "  ${YELLOW}Installing as systemd service (all users)...${NC}"
    sudo tee /etc/systemd/system/cs-tutor.service > /dev/null <<SERVICEEOF
[Unit]
Description=CS Tutor - Llama 3.3 via Groq
After=network.target

[Service]
Type=simple
WorkingDirectory=${SCRIPT_DIR}
ExecStart=/usr/bin/python3 ${SCRIPT_DIR}/app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEEOF

    sudo systemctl daemon-reload
    sudo systemctl enable cs-tutor.service
    sudo systemctl start cs-tutor.service
    echo ""
    echo -e "  ${GREEN}Service installed and started!${NC}"
    echo "  It will auto-start on every boot for all users."
    echo ""
    echo "  Manage with:"
    echo "    sudo systemctl status cs-tutor"
    echo "    sudo systemctl stop cs-tutor"
    echo "    sudo systemctl restart cs-tutor"
    echo "    sudo systemctl disable cs-tutor   (remove from startup)"
    echo ""
    exit 0
fi

if [ "$1" = "--uninstall" ]; then
    echo -e "  ${YELLOW}Removing startup service...${NC}"
    sudo systemctl stop cs-tutor.service 2>/dev/null
    sudo systemctl disable cs-tutor.service 2>/dev/null
    sudo rm -f /etc/systemd/system/cs-tutor.service
    sudo systemctl daemon-reload
    echo -e "  ${GREEN}Service removed.${NC}"
    echo ""
    exit 0
fi

# -------------------------------------------------------
# Launch the app
# -------------------------------------------------------
cd "$(dirname "$0")"
python3 app.py

echo ""
echo "Server stopped."
