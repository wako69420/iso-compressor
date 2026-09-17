#!/bin/bash
echo "======================================"
echo "Installing PS1, PS2 & PSP ISO Compressor (Linux TUI)"
echo "======================================"

echo "Downloading TUI wrapper..."
curl -sL -o /tmp/iso-compressor "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/linux/iso-compressor.sh"
chmod +x /tmp/iso-compressor

echo "Installing to /usr/local/bin/ (You may be prompted for your password)..."
sudo mv /tmp/iso-compressor /usr/local/bin/iso-compressor
echo ""
echo "Note: The Linux version requires 'maxcso' to be in your PATH."
echo "If you haven't installed maxcso yet, please build it from https://github.com/unknownbrackets/maxcso"
echo ""
echo "Success! You can now launch the interactive menu from any terminal by typing:"
echo "iso-compressor"
