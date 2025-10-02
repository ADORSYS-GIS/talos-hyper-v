#!/usr/bin/env bash
set -euo pipefail

# This script installs the necessary tools for WinRM testing on a Debian-based system.

# 1. Update package lists
sudo apt-get update

# 2. Install Go
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Installing Go..."
    sudo apt-get install -y golang-go
fi

# 3. Install winrm-cli
echo "Installing winrm-cli..."
go install github.com/masterzen/winrm-cli@latest

# 4. Add Go bin to PATH
if ! grep -q 'export PATH=$PATH:~/go/bin' ~/.profile; then
    echo 'export PATH=$PATH:~/go/bin' >> ~/.profile
    echo "Go bin directory added to PATH. Please source ~/.profile or log out and back in for the changes to take effect."
fi

echo "Setup complete. winrm-cli is installed."