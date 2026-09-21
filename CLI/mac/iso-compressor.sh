#!/bin/bash
# PS1, PS2 & PSP ISO Compressor TUI
APP_VERSION="v1.4.2"
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

    echo "======================================================="
    echo "                 QUICK COMPRESSION GUIDE               "
    echo "======================================================="
    echo " • PS1 Games (.CUE) ---> ONLY use CHD (For Emulators)"
    echo " • PS2 Games (.ISO) ---> Use CHD (Emulation) or ZSO (Real Console)"
    echo " • PSP Games (.ISO) ---> Use CSO (Emulation) or ZSO (Real Console)"
    echo "======================================================="
    echo " [1] CUE/ISO to CHD (For PS1/PS2 Emulators)
 [2] ISO to CSO (For PSP Emulators)"
    echo " [3] CSO to ZSO (For Real Hardware)"
    echo " [4] ISO to ZSO (For Real Hardware)"
    echo " [5] Batch Compress a Folder"
    echo " [6] Install / Uninstall CHDMAN (For PS1/PS2 Emulators)
 [7] Auto-Update CLI Tool
 [8] About / License"
    echo " [9] Uninstall CLI Tool"
    echo " [10] Exit"
    echo ""
    read -p "Type a number and press Enter: " choice
}

echo "Checking for updates..."
LATEST_VER=$(curl -m 2 -s https://api.github.com/repos/wako69420/iso-compressor/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -n "$LATEST_VER" ] && [ "$LATEST_VER" != "$APP_VERSION" ]; then
    echo "======================================================="
    echo "  UPDATE AVAILABLE: $LATEST_VER (Current: $APP_VERSION)"
    echo "======================================================="
    read -p "Would you like to update now? (y/n): " do_update
    if [ "$do_update" = "y" ] || [ "$do_update" = "Y" ]; then
        curl -sL https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/install_mac.sh | bash
        exit 0
    fi
fi

while true; do
    show_menu
    case $choice in
        1) format="chd"; break;;
        2) format="cso1"; break;;
        3|4) format="zso"; break;;
        5)
            clear
            echo "======================================================="
            echo "               BATCH COMPRESS A FOLDER"
            echo "======================================================="
            echo ""
            read -p "Drag and drop your folder here and press Enter: " folderpath
            folderpath=$(eval echo $folderpath)
            
            echo ""
            echo "What format do you want to convert these games into?"
            echo "[1] CHD (PS1/PS2 Emulators)"
            echo "[2] CSO (PSP Emulators)"
            echo "[3] ZSO (Real Hardware)"
            read -p "Select format: " batch_format_choice
            
            batch_format=""
            if [ "$batch_format_choice" = "1" ]; then batch_format="chd"; fi
            if [ "$batch_format_choice" = "2" ]; then batch_format="cso1"; fi
            if [ "$batch_format_choice" = "3" ]; then batch_format="zso"; fi
            
            if [ -z "$batch_format" ]; then
                echo "Invalid choice."
                read -p "Press Enter to return..."
                continue
            fi
            
            if [ "$batch_format" = "chd" ]; then
                if ! command -v chdman >/dev/null 2>&1; then
                    echo "Error: chdman engine is not installed."
                    read -p "Press Enter to return..."
                    continue
                fi
            fi
            
            echo ""
            echo "======================================================="
            echo "               COMPRESSION IN PROGRESS"
            echo "======================================================="
            echo ""
            
            valid_count=0
            ext_found=""
            
            for f in "$folderpath"/*.iso "$folderpath"/*.cso "$folderpath"/*.cue; do
                [ -e "$f" ] || continue
                ext="${f##*.}"
                ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
                if [ -z "$ext_found" ]; then
                    ext_found="$ext"
                elif [ "$ext_found" != "$ext" ]; then
                    echo "Error: The folder must contain only ONE file format to convert (e.g., only .iso OR only .cso)."
                    echo "Mixed formats were found. Please separate them."
                    read -p "Press Enter to return..."
                    continue 2
                fi
                valid_count=$((valid_count+1))
            done
            
            if [ "$valid_count" -eq 0 ]; then
                echo "Error: No valid game files (.iso, .cso, .cue) were found in this folder."
                read -p "Press Enter to return..."
                continue
            fi
            
            for f in "$folderpath"/*.iso "$folderpath"/*.cso "$folderpath"/*.cue; do
                [ -e "$f" ] || continue
                echo "Processing: $(basename "$f")"
                if [ "$batch_format" = "chd" ]; then
                    ext="${f##*.}"
                    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
                    if [ "$ext" = "cue" ]; then
                        chdman createcd -i "$f" -o "${f%.*}.chd"
                    else
                        chdman createdvd -i "$f" -o "${f%.*}.chd"
                    fi
                else
                    "$ENGINE_PATH" --format=$batch_format "$f"
                fi
            done
            
            echo ""
            echo "======================================================="
            echo "                   ALL DONE!"
            echo "======================================================="
            read -p "Press Enter to return..."
            ;;
        6)
            clear
            echo "======================================================="
            echo "          INSTALL / UNINSTALL CHDMAN"
            echo "======================================================="
            echo ""
            if ! command -v chdman >/dev/null 2>&1; then
                echo "chdman is currently NOT installed."
                read -p "Do you want to download and install it now? (y/n): " confirm
                if [[ "$confirm" == [yY] ]]; then
                    echo "Installing via Homebrew..."
                    if ! command -v brew >/dev/null 2>&1; then
                        echo "Error: Homebrew is not installed! Please install it first (brew.sh)"
                    else
                        brew install rom-tools
                        echo "Done!"
                    fi
                fi
            else
                echo "chdman is currently INSTALLED."
                read -p "Do you want to uninstall and remove it? (y/n): " confirm
                if [[ "$confirm" == [yY] ]]; then
                    echo "Uninstalling via Homebrew..."
                    brew uninstall rom-tools
                    echo "Done!"
                fi
            fi
            read -p "Press Enter to return..."
            ;;
        7)
            clear
            echo "======================================================="
            echo "                 AUTO-UPDATING TOOL"
            echo "======================================================="
            echo "Fetching latest version from GitHub..."
            curl -sL -o /tmp/iso_update.sh "https://raw.githubusercontent.com/wako69420/iso-compressor/master/CLI/install_mac.sh?t=$(date +%s)" && bash /tmp/iso_update.sh && rm /tmp/iso_update.sh
            exit 0
            ;;
        8)
            clear
            echo "======================================================="
            echo "                ABOUT & LICENSE"
            echo "======================================================="
            echo "PS1, PS2 & PSP Game Compressor $APP_VERSION"
            echo "GitHub: https://github.com/wako69420/iso-compressor"
            echo "License: BSD 3-Clause License"
            echo "Credits:"
            echo "- maxcso engine by unknownbrackets"
            echo "- CHD format & chdman by MAME Team"
            echo "- ZSO support (PSP) by ARK-5 Team"
            echo "- ZSO support (PS2) by OPL Team"
            echo "======================================================="
            read -p "Press Enter to return..."
            ;;
        9)
            clear
            echo "======================================================="
            echo "                   UNINSTALL TOOL"
            echo "======================================================="
            echo "This will completely remove the CLI tool and its hidden files from your system."
            read -p "Are you sure you want to uninstall? (y/n): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                echo "Removing backend engine (~/.iso-compressor)..."
                rm -rf ~/.iso-compressor
                echo "Removing global command (/usr/local/bin/iso-compressor)..."
                sudo rm -f /usr/local/bin/iso-compressor
                echo "Uninstallation complete. You can close this terminal."
                exit 0
            else
                echo "Uninstallation cancelled."
                read -p "Press Enter to return..."
            fi
            ;;
        10) exit 0;;
        *) echo "Invalid option"; sleep 1;;
    esac
done

echo ""
read -p "Drag and drop your .ISO, .CSO, or .CUE file here and press Enter: " file_path
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
    ext="${file_path##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    if [ "$ext" == "cue" ]; then
        chdman createcd -i "$file_path" -o "${file_path%.*}.chd"
    else
        chdman createdvd -i "$file_path" -o "${file_path%.*}.chd"
    fi
else
    "$ENGINE_PATH" --format=$format "$file_path"
fi
echo ""
echo "======================================================="
echo "                    ALL DONE!"
echo "======================================================="
