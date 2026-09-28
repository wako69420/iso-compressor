import re

with open("CLI/windows/iso-compressor.bat", "r") as f:
    text = f.read()

old_menu = """echo  [1] CUE/ISO to CHD (For PS1/PS2 Emulators)
echo  [2] ISO to CSO (For PSP Emulators)
echo  [3] CSO to ZSO (For Real Hardware)
echo  [4] ISO to ZSO (For Real Hardware)
echo  [5] Install CHDMAN (For CHD Support)
echo  [6] Auto-Update CLI Tool
echo  [7] About / License
echo  [8] Uninstall CLI Tool
echo  [9] Exit
echo.
set /p choice="Type 1, 2, 3, 4, 5, 6, 7, 8, or 9 and press Enter: \""""

new_menu = """echo  [1] CUE/ISO to CHD (For PS1/PS2 Emulators)
echo  [2] ISO to CSO (For PSP Emulators)
echo  [3] CSO to ZSO (For Real Hardware)
echo  [4] ISO to ZSO (For Real Hardware)
echo  [5] Batch Compress a Folder
echo  [6] Install / Uninstall CHDMAN (For PS1/PS2 Emulators)
echo  [7] Auto-Update CLI Tool
echo  [8] About / License
echo  [9] Uninstall CLI Tool
echo  [10] Exit
echo.
set /p choice="Type a number and press Enter: \""""

text = text.replace(old_menu, new_menu)

# I need to completely restructure the bat if logic.
# Because it's a huge script, it's easier to use sed/awk or python to rewrite the if blocks.
# Actually, the batch script handles inputs sequentially.
