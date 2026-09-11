# PSP ISO Compressor (ZSO & CSO)

A simple, drag-and-drop utility for Mac and Windows that compresses large PSP `.ISO` backups into optimized `.ZSO` or `.CSO` files to save disk space.

## Features
- **ZSO Support:** Shrinks games using ultra-fast LZ4 compression. This format is strictly meant for **Physical PSP Consoles** running modern Custom Firmware (like ARK-4/ARK-5). It completely eliminates the lag spikes that old formats caused on real hardware.
- **CSO Support:** The legacy compression standard. Choose this format if you are playing games on the **PPSSPP Emulator** on your Mac or PC, as PPSSPP currently does not support ZSO.

## How to use (Mac)
1. Open the `ISO Compressor (Mac).app` by double-clicking it, or simply drag-and-drop `.ISO` files directly onto the app icon.
2. A prompt will appear asking you to choose between ZSO or CSO format.
3. The app will compress the file in the background and place the new file in the same folder as your original game.

## How to use (Windows)
1. Open the `ISO Compressor (Windows)` folder.
2. Drag and drop your `.ISO` files directly onto the `Drag and Drop Games Here.bat` script file.
3. A command window will prompt you to type `1` for ZSO or `2` for CSO.
4. The script will shrink the games and place the new files next to your originals.

## Credits & Open Source
This tool is a wrapper powered by the incredibly fast **maxcso** engine.
All core compression credit goes to [unknownbrackets](https://github.com/unknownbrackets/maxcso).
