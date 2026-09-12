#!/bin/bash
# PSP ISO Compressor TUI
ENGINE_PATH="$HOME/.psp-compressor/maxcso"

if [ ! -f "$ENGINE_PATH" ]; then
    echo "Error: maxcso engine not found at $ENGINE_PATH"
    echo "Please reinstall using the curl command from GitHub."
    exit 1
fi

show_menu() {
    clear
    echo "======================================================="
    echo "          PSP GAME COMPRESSOR (ZSO & CSO)"
    echo "======================================================="
    echo ""
    echo "NOTE:"
    echo "- CSO format is for PPSSPP Emulators on PC/Mac/Phone."
    echo "- ZSO format is for ACTUAL PSP Hardware running ARK-5."
    echo ""
    echo "Please choose an option:"
    echo ""
    echo " [1] ISO to CSO (For PPSSPP)"
    echo " [2] CSO to ZSO (For Real PSP)"
    echo " [3] ISO to ZSO (For Real PSP)"
    echo " [4] About / License"
    echo " [5] Exit"
    echo ""
    read -p "Type 1, 2, 3, 4, or 5 and press Enter: " choice
}

while true; do
    show_menu
    case $choice in
        1) format="cso"; break;;
        2|3) format="zso"; break;;
        4)
            clear
            echo "======================================================="
            echo "                ABOUT & LICENSE"
            echo "======================================================="
            echo "ISO/CSO Compressor v1.0"
            echo "GitHub: https://github.com/wako69420/psp-iso-compressor"
            echo "License: MIT License"
            echo "Credits:"
            echo "- maxcso engine by unknownbrackets"
            echo "- ZSO support powered by ARK-5 Team"
            echo "======================================================="
            read -p "Press Enter to return..."
            ;;
        5) exit 0;;
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
"$ENGINE_PATH" --format=$format "$file_path"
echo ""
echo "======================================================="
echo "                    ALL DONE!"
echo "======================================================="
