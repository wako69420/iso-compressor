#!/bin/bash
# PS1, PS2 & PSP ISO Compressor TUI (Linux)

if ! command -v maxcso >/dev/null 2>&1; then
    echo "Error: 'maxcso' engine not found in PATH."
    echo "Please install maxcso (https://github.com/unknownbrackets/maxcso) or build it from source."
    exit 1
fi
ENGINE_PATH="maxcso"

show_menu() {
    clear
    echo "======================================================="
    echo "          PS1, PS2 & PSP GAME COMPRESSOR (CHD, ZSO, CSO)"
    echo "======================================================="
    echo ""
    echo "NOTE:"
    echo "- CHD format is the ultimate standard for PS1 & PS2 Emulators (Requires chdman)."
    echo "- CSO format is for Emulators (PPSSPP & PCSX2) on PC/Mac/Phone."
    echo "- ZSO format is for ACTUAL PSP (ARK-5) & PS2 (OPL) Hardware."
    echo ""
    echo "Please choose an option:"
    echo ""
    echo " [1] ISO to CHD (For PS1/PS2 Emulators)"
    echo " [2] ISO to CSO (For PSP Emulators)"
    echo " [3] CSO to ZSO (For Real Hardware)"
    echo " [4] ISO to ZSO (For Real Hardware)"
    echo " [5] Install CHDMAN (For CHD Support)"
    echo " [6] Auto-Update CLI Tool"
    echo " [7] About / License"
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
            if command -v apt-get >/dev/null 2>&1; then
                echo "Detected Debian/Ubuntu. Installing mame-tools..."
                sudo apt-get update && sudo apt-get install -y mame-tools
            elif command -v pacman >/dev/null 2>&1; then
                echo "Detected Arch Linux. Installing mame-tools..."
                sudo pacman -S --needed mame-tools
            elif command -v dnf >/dev/null 2>&1; then
                echo "Detected Fedora. Installing mame..."
                sudo dnf install mame
            else
                echo "Unsupported package manager. Please install 'mame-tools' or 'chdman' manually."
            fi
            echo "Done!"
            read -p "Press Enter to return..."
            ;;
        6)
            clear
            echo "======================================================="
            echo "                 AUTO-UPDATING TOOL"
            echo "======================================================="
            echo "Fetching latest version from GitHub..."
            curl -sL https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/install_linux.sh | bash
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
file_path=$(echo "$file_path" | sed -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//' | xargs)

clear
echo "======================================================="
echo "              COMPRESSION IN PROGRESS"
echo "======================================================="
if [ "$format" == "chd" ]; then
    if ! command -v chdman >/dev/null 2>&1; then
        echo "Error: chdman is not installed or not in PATH."
        echo "Please use option [5] to install it."
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
