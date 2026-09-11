#!/bin/bash
echo "======================================"
echo "Installing PSP ISO Compressor (Mac CLI)"
echo "======================================"
echo "Downloading engine..."
curl -sL -o /tmp/psp-compressor "https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/ISO%20Compressor%20(Mac).app/Contents/Resources/maxcso"
chmod +x /tmp/psp-compressor
echo "Installing to /usr/local/bin/ (You may be prompted for your Mac password)..."
sudo mv /tmp/psp-compressor /usr/local/bin/psp-compressor
echo ""
echo "Success! You can now use the tool from any terminal window."
echo "Usage: psp-compressor --format=zso \"/path/to/game.iso\""
