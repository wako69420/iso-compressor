#!/bin/bash
echo "======================================"
echo "Installing PSP & PS2 ISO Compressor (Mac TUI)"
echo "======================================"
echo "Downloading core engine..."
mkdir -p "$HOME/.psp-compressor"
curl -sL -o "$HOME/.psp-compressor/maxcso" "https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/CLI/mac/maxcso"
chmod +x "$HOME/.psp-compressor/maxcso"

echo "Downloading TUI wrapper..."
curl -sL -o /tmp/psp-compressor "https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/CLI/mac/psp-compressor.sh"
chmod +x /tmp/psp-compressor

echo "Installing to /usr/local/bin/ (You may be prompted for your Mac password)..."
sudo mv /tmp/psp-compressor /usr/local/bin/psp-compressor
echo ""
echo "Success! You can now launch the interactive menu from any terminal by typing:"
echo "psp-compressor"
