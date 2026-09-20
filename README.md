  <h1>PS1, PS2 & PSP Game Compressor (ISO/CUE to CHD, ZSO, CSO)</h1>
<p>
  <a href="https://github.com/wako69420/iso-compressor/actions/workflows/shellcheck.yml"><img src="https://img.shields.io/github/actions/workflow/status/wako69420/iso-compressor/shellcheck.yml?style=flat-square&label=CI" alt="CI Status"></a>
  <a href="https://github.com/wako69420/iso-compressor/releases"><img src="https://img.shields.io/github/downloads/wako69420/iso-compressor/total.svg?style=flat-square" alt="Downloads"></a>
  <a href="https://github.com/wako69420/iso-compressor/releases"><img src="https://img.shields.io/github/v/release/wako69420/iso-compressor.svg?style=flat-square" alt="Latest Release"></a>
  <a href="https://github.com/wako69420/iso-compressor/blob/master/LICENSE"><img src="https://img.shields.io/github/license/wako69420/iso-compressor.svg?style=flat-square" alt="License"></a>
  <a href="https://github.com/wako69420/iso-compressor/commits/master"><img src="https://img.shields.io/github/last-commit/wako69420/iso-compressor?style=flat-square" alt="Last Commit"></a>
  <br>
  <img src="https://img.shields.io/static/v1?label=Supports&message=Mac,%20Win,%20Linux%20%E2%80%A2%20PS1,%20PS2,%20PSP&color=blue&style=flat-square" alt="Supported Platforms and Hardware">
  <img src="https://img.shields.io/static/v1?label=Powered%20By&message=maxcso%20%26%20chdman&color=purple&style=flat-square" alt="Powered By">
  <br>
  <a href="https://github.com/wako69420/iso-compressor/wiki"><img src="https://img.shields.io/static/v1?label=&message=Information%20%26%20Instructions&color=yellow&style=flat-square" alt="Information and Instructions"></a>
  <a href="https://discord.gg/BxdrA6gfZg"><img src="https://img.shields.io/static/v1?label=&message=Discord&color=5865F2&style=flat-square&logo=discord&logoColor=white" alt="Discord"></a>
  <br><br>
  <a href="https://github.com/wako69420/iso-compressor/releases/latest"><img src="https://img.shields.io/static/v1?label=&message=Download%20Mac%20GUI&color=2ea44f&style=for-the-badge&logo=apple&logoColor=white" alt="Download Mac GUI"></a>
  <a href="#tui-install"><img src="https://img.shields.io/static/v1?label=&message=Windows%20TUI&color=2ea44f&style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0NDggNTEyIj48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTAgOTMuN2wxODMuNi0yNS4zdjE3Ny40SDBWOTMuN3ptMCAzMjQuNmwxODMuNiAyNS4zVjI2OC40SDB2MTQ5Ljl6bTIwMy44IDI4TDQ0OCA0ODBWMjY4LjRIMjAzLjh2MTc3Ljl6bTAtMzgwLjZ2MTgwLjFINDQ4VjMyTDIwMy44IDY1Ljd6Ii8+PC9zdmc+" alt="Windows TUI"></a>
  <a href="#tui-install"><img src="https://img.shields.io/static/v1?label=&message=Mac%20TUI&color=2ea44f&style=for-the-badge&logo=apple&logoColor=white" alt="Mac TUI"></a>
  <a href="#tui-install"><img src="https://img.shields.io/static/v1?label=&message=Linux%20TUI&color=2ea44f&style=for-the-badge&logo=linux&logoColor=white" alt="Linux TUI"></a>
</p>

Personal use project.
<p><i>A simple, drag-and-drop utility for Mac (with full interactive TUI support for Windows, Linux & Mac) that compresses massive PS1, PS2, and PSP <code>.ISO</code> and <code>.CUE</code> backups into highly optimized <code>.CHD</code>, <code>.ZSO</code>, or <code>.CSO</code> files.</i></p>
Saves space on your PSP, PS2, PS1, and emulators that can be used for additional titles; does not hinder functionality of the title, consoles and emulators read compressed files without any issues.

---

## Features & Formats

This tool explicitly provides conversion paths tailored for your specific gaming setup:
- **CUE / ISO ➔ CHD**
- **ISO ➔ CSO**
- **CSO ➔ ZSO**
- **ISO ➔ ZSO**

### Why CHD is the ultimate standard for PS1 & PS2 Emulators
If you are playing your games on **DuckStation (PS1)** or **PCSX2 (PS2)**, you should ALWAYS use the **CHD** format. CHD (Compressed Hunks of Data) uses extremely advanced lossless compression algorithms (like LZMA for data and FLAC for audio) which results in the absolute smallest file sizes possible for CD and DVD based games. It is the gold standard for emulation. 
> [!NOTE]
> You must have `chdman` installed on your system to use the CHD conversion option. Mac users can simply run `brew install rom-tools` in the terminal, or use the button in the application to auto-install it.

> [!TIP]
> **How to compress PS1 Games (BIN/CUE):** PS1 games often come with multiple `.bin` files and one `.cue` file. To compress them into a single `.chd` file, ensure all the `.bin` files are in the exact same folder, and **drag and drop ONLY the `.cue` file** into this tool! The engine will automatically read the `.cue` map, pull in all the associated `.bin` files, and merge them into one single file.

### Why CSO is better for PSP Emulators
If you are playing your games on the **PPSSPP Emulator (PSP)** or **PCSX2 Emulator (PS2)** (on a PC, Mac, or phone), you should ALWAYS use the **CSO** format. An uncompressed `.ISO` file wastes gigabytes of storage space with blank "dummy data". The `.CSO` format uses standard Zlib compression to aggressively shrink the file down. Because modern PCs and smartphones have massive processing power, the emulator can decompress the CSO file instantly in the background, giving you massive storage savings with absolutely zero performance loss. 
> [!WARNING]
> PPSSPP does not currently support the ZSO format.

### Why ZSO is better for Real Hardware (PSP & PS2)
If you are playing games on **Real Physical PSP Hardware (ARK-5)** or a **Real PS2 Console (OPL)**, you should ALWAYS use the **ZSO** format. 
Back in the day, people used CSO files on real hardware to save space. However, because Zlib compression is so tight, the processors of the PSP and PS2 would choke trying to decompress the game files fast enough, causing terrible lag spikes and audio stuttering (especially in games like *Grand Theft Auto*). 
The `.ZSO` format fixes this by using ultra-fast **LZ4 compression**. It shrinks the game beautifully, but decompresses roughly **500% faster**. This allows the physical console to unpack the game instantly, completely curing the lag spikes while still saving you massive amounts of space on your memory stick!


---

## Hardware & Emulator Compatibility List
To ensure your compressed games boot flawlessly, please verify that your hardware or emulator meets the following requirements:

### ZSO (For Real Hardware)
* **Real PSP Console:** Must be running **ARK-4** or **ARK-5** Custom Firmware (CFW). Older firmwares like PRO-C or ME do not support ZSO natively out of the box.
* **Real PS2 Console:** Must be using **OPL (Open PS2 Loader) v1.2.0 Beta** or newer. Older stable builds of OPL (like v1.1.0) do not have the ZSO decompression engine built-in.

### CHD (For Emulators)
* **PS1 Emulation:** Fully supported by **DuckStation**, **RetroArch** (SwanStation/Beetle cores), and most modern emulators.
  > [!IMPORTANT]
  > Cannot be used on real PS1 hardware without extracting back to `.bin/.cue` and burning to a CD-R.
* **PS2 Emulation:** Fully supported by **PCSX2** (Nightly builds / v1.7+).
  > [!WARNING]
  > RPCS3 (PS3 Emulator) does not support CHD.

### CSO (For PSP Emulation & Legacy CFW)
* **PSP Emulation:** Fully supported by the **PPSSPP** emulator on all platforms (PC, Mac, Android, iOS).
* **Real PSP Console:** Supported by virtually all legacy Custom Firmwares (PRO, ME) and modern ones (ARK).
  > [!TIP]
  > ZSO is highly recommended over CSO for real hardware to prevent lag.

---

<a name="tui-install"></a>
## Terminal / CLI Installation (Interactive TUI)
If you prefer to use the command line, or if you are on Windows, you can install the interactive Terminal User Interface (TUI) directly to your system path.

**macOS Installation:**
Open your Terminal and run the following command:
```bash
curl -sL https://github.com/wako69420/iso-compressor/releases/latest/download/install_mac.sh | bash
```

**Linux Installation:**
Open your Terminal and run the following command:
```bash
curl -sL https://github.com/wako69420/iso-compressor/releases/latest/download/install_linux.sh | bash
```

**Windows Installation:**
Open PowerShell and run the following command:
```powershell
irm https://github.com/wako69420/iso-compressor/releases/latest/download/install_win.ps1 | iex
```

Once installed on either OS, simply type the following command into any terminal to launch the Drag-and-Drop menu:
```bash
iso-compressor
```

---

## How to use (Mac GUI)
1. Download the latest Mac Release from the Releases tab.
2. Open **`ISO Compressor (Mac).app`** by double-clicking it, or simply **drag-and-drop** your `.ISO`/`.CSO` files directly onto the app icon.
3. A prompt will clearly ask you to choose between CHD (For PS1/PS2 Emulators), CSO (For PSP Emulators), or ZSO (For Real Hardware).

---

---

## 🗺️ Roadmap
Development on this project is highly active! While I am keeping the exact new features under wraps for now, expect some massive quality-of-life improvements, deeper automation, and wider format support in the upcoming releases. Stay tuned!

## License & Open Source
This project is licensed under the [BSD 3-Clause License](LICENSE). 
* **maxcso Engine:** All core compression credit goes to [unknownbrackets](https://github.com/unknownbrackets/maxcso) for the blazing fast CSO/ZSO engine.
* **MAME Team (chdman):** [MAME Development Team](https://www.mamedev.org/) (and Aaron Giles) for the CHD format and the `chdman` tool.
* **ARK-5 Custom Firmware:** [ARK-5 Team](https://github.com/PSP-Archive/ARK-4) (Acid_Snake, KrazyS, and contributors) native ZSO (Inferno V2) support directly into the firmware.
* **OPL (Open PS2 Loader):** The [OPL Development Team](https://github.com/ps2homebrew/Open-PS2-Loader)

---

## Tags
`psp`, `ps2`, `iso`, `cso`, `zso`, `compression`, `maxcso`, `ppsspp`, `pcsx2`, `opl`, `ark-5`
