<div align="center">
  <img src="logo.jpg" alt="Logo" width="200"/>
  <h1>PSP & PS2 ISO Compressor (ZSO & CSO)</h1>
  Personal use project.
  <p><i>A simple, drag-and-drop utility for Mac (with full interactive TUI support for Windows & Mac) that compresses massive PSP and PS2 <code>.ISO</code> backups into highly optimized <code>.ZSO</code> or <code>.CSO</code> files.</i></p>
  Saves space on your PSP, PS2, and emulators that can be used for additional titles; does not hinder functionality of the title, consoles and emulators read compressed files without any issues.
</div>

---

## Features & Formats

This tool explicitly provides conversion paths tailored for your specific gaming setup:
- **ISO ➔ CSO**
- **CSO ➔ ZSO**
- **ISO ➔ ZSO**

### Why CSO is better for Emulators (PPSSPP & PCSX2)
If you are playing your games on the **PPSSPP Emulator (PSP)** or **PCSX2 Emulator (PS2)** (on a PC, Mac, or phone), you should ALWAYS use the **CSO** format. An uncompressed `.ISO` file wastes gigabytes of storage space with blank "dummy data". The `.CSO` format uses standard Zlib compression to aggressively shrink the file down. Because modern PCs and smartphones have massive processing power, the emulator can decompress the CSO file instantly in the background, giving you massive storage savings with absolutely zero performance loss. 
*(Note: PPSSPP does not currently support the ZSO format).*

### Why ZSO is better for Real Hardware (PSP & PS2)
If you are playing games on **Real Physical PSP Hardware (ARK-5)** or a **Real PS2 Console (OPL)**, you should ALWAYS use the **ZSO** format. 
Back in the day, people used CSO files on real hardware to save space. However, because Zlib compression is so tight, the processors of the PSP and PS2 would choke trying to decompress the game files fast enough, causing terrible lag spikes and audio stuttering (especially in games like *Grand Theft Auto*). 
The `.ZSO` format fixes this by using ultra-fast **LZ4 compression**. It shrinks the game beautifully, but decompresses roughly **500% faster**. This allows the physical console to unpack the game instantly, completely curing the lag spikes while still saving you massive amounts of space on your memory stick!

---

## How to use (Mac GUI)
1. Download the latest Mac Release from the Releases tab.
2. Open **`ISO Compressor (Mac).app`** by double-clicking it, or simply **drag-and-drop** your `.ISO`/`.CSO` files directly onto the app icon.
3. A prompt will clearly ask you to choose between CSO (For Emulators) or ZSO (For Real Hardware).

---

## Terminal / CLI Installation (Interactive TUI)
If you prefer to use the command line, or if you are on Windows, you can install the interactive Terminal User Interface (TUI) directly to your system path.

**macOS Installation:**
Open your Terminal and run the following command:
```bash
curl -sL https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/CLI/install_mac.sh | bash
```

**Windows Installation:**
Open PowerShell and run the following command:
```powershell
irm https://raw.githubusercontent.com/wako69420/psp-iso-compressor/master/CLI/install_win.ps1 | iex
```

Once installed on either OS, simply type the following command into any terminal to launch the Drag-and-Drop menu:
```bash
psp-compressor
```

---

## License & Open Source
This project is licensed under the [MIT License](LICENSE). 
* **maxcso Engine:** All core compression credit goes to [unknownbrackets](https://github.com/unknownbrackets/maxcso)
* **ARK-5 Custom Firmware:** [ARK-5 Team](https://github.com/PSP-Archive/ARK-4) (Acid_Snake, KrazyS, and contributors) for building the native ZSO (Inferno V2) support directly into the firmware.

---

## Tags
`psp`, `ps2`, `iso`, `cso`, `zso`, `compression`, `maxcso`, `ppsspp`, `pcsx2`, `opl`, `ark-5`
