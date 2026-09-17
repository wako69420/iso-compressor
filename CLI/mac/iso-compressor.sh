#!/bin/bash
# PS1, PS2 & PSP ISO Compressor TUI
ENGINE_PATH="$HOME/.iso-compressor/maxcso"

if [ ! -f "$ENGINE_PATH" ]; then
    echo "Error: maxcso engine not found at $ENGINE_PATH"
    echo "Please reinstall using the curl command from GitHub."
    exit 1
fi

show_menu() {
    clear
    echo "======================================================="
    echo "          PS1, PS2 & PSP GAME COMPRESSOR (CHD, ZSO, CSO)"
    echo "======================================================="
    echo ""
    echo "NOTE:
- CHD format is the ultimate standard for PS1 & PS2 Emulators (Requires chdman)."
    echo "- CSO format is for Emulators (PPSSPP & PCSX2) on PC/Mac/Phone."
    echo "- ZSO format is for ACTUAL PSP (ARK-5) & PS2 (OPL) Hardware."
    echo ""
    echo "Please choose an option:"
    echo ""
    echo " [1] ISO to CHD (For PS1/PS2 Emulators)
 [2] ISO to CSO (For PSP Emulators)"
    echo " [3] CSO to ZSO (For Real Hardware)"
    echo " [4] ISO to ZSO (For Real Hardware)"
    echo " [5] Install CHDMAN (For CHD Support)
 [6] Auto-Update CLI Tool
 [7] About / License"
    echo " [8] Exit"
    echo ""
    read -p "Type 1, 2, 3, 4, 5, 6, 7, or 8 and press Enter: " choice
}

while true; do
    show_menu
    case $choice in
        1) format="chd"; break;;
        2) format="cso"; break;;
        3|4) format="zso"; break;;
        5)
            clear
            echo "======================================================="
            echo "                   INSTALL CHDMAN"
            echo "======================================================="
            echo "CHD is the ultimate lossless compression format for PS1 and PS2 Emulators."
            echo "To create CHD files, this app needs a free tool called 'chdman'."
            echo ""
            echo "Installing via Homebrew..."
            if ! command -v brew >/dev/null 2>&1; then
                echo "Error: Homebrew is not installed! Please install it first (brew.sh)"
            else
                brew install rom-tools
                echo "Done!"
            fi
            read -p "Press Enter to return..."
            ;;
        6)
            clear
            echo "======================================================="
            echo "                 AUTO-UPDATING TOOL"
            echo "======================================================="
            echo "Fetching latest version from GitHub..."
            curl -sL -o /tmp/iso_update.sh https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/install_mac.sh && bash /tmp/iso_update.sh && rm /tmp/iso_update.sh
            exit 0
            ;;
        7)
            clear
            echo "======================================================="
            echo "                ABOUT & LICENSE"
            echo "======================================================="
            echo "PS1, PS2 & PSP ISO Compressor v1.4.0"
            echo "GitHub: https://github.com/wako69420/iso-compressor"
            echo "License: MIT License"
            echo "Credits:"
            echo "- maxcso engine by unknownbrackets"
            echo "- CHD format & chdman by MAME Team"
            echo "- ZSO support (PSP) by ARK-5 Team"
            echo "- ZSO support (PS2) by OPL Team"
            echo "======================================================="
            read -p "Press Enter to return..."
            ;;
        8) exit 0;;
        *) echo "Invalid option"; sleep 1;;
    esac
done

echo ""
read -p "Drag and drop your .ISO or .CSO file here and press Enter: " file_path
# Remove quotes and trailing spaces if dropped by Finder
file_path=$(echo "$file_path" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' | xargs)

clear
echo "======================================================="
echo "              COMPRESSION IN PROGRESS"
echo "======================================================="
if [ "$format" == "chd" ]; then
    if ! command -v chdman >/dev/null 2>&1; then
        echo "Error: chdman is not installed or not in PATH."
        echo "Please install it (e.g. 'brew install rom-tools' on Mac)."
        exit 1
    fi
    chdman createdvd -i "$file_path" -o "${file_path%.*}.chd"
else
    "$ENGINE_PATH" --format=$format "$file_path"
fi
echo ""
echo "======================================================="
echo "                    ALL DONE!"
echo "======================================================="
