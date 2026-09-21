#!/bin/bash
echo "======================================"
echo "Installing PS1, PS2 & PSP ISO Compressor (Mac TUI)"
echo "======================================"
echo "Downloading core engine..."
mkdir -p "$HOME/.iso-compressor"
curl -sL -o "$HOME/.iso-compressor/maxcso" "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/mac/maxcso?t=$(date +%s)"
chmod +x "$HOME/.iso-compressor/maxcso"

echo "Downloading TUI wrapper..."
curl -sL -o /tmp/iso-compressor "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/mac/iso-compressor.sh?t=$(date +%s)"
chmod +x /tmp/iso-compressor

echo "Installing to /usr/local/bin/ (You may be prompted for your Mac password)..."
sudo mv /tmp/iso-compressor /usr/local/bin/iso-compressor
echo ""
echo "Success! You can now launch the interactive menu from any terminal by typing:"
echo "iso-compressor"
