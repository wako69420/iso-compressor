# Contributing to PS1, PS2 & PSP ISO Compressor

First off, thanks for checking out my project! I built this primarily for my own personal use, but I'm thrilled if it helps out the broader retro-gaming and emulation community. 

Since it's just me working on this, any help or contributions from the community are super appreciated!

## How Can I Contribute?

### Reporting Bugs
If you break something, let me know! 
- **Use the bug report template** provided in the Issues tab.
- **Include your OS and Version** (e.g., Mac GUI, Windows TUI, Linux) so I can figure out what went wrong.

### Suggesting Enhancements
Got a cool idea? I'm all ears.
- **Use the feature request template** in the Issues tab.
- Let me know why it would be a good addition (like adding a new compression format or supporting a new emulator).

### Pull Requests
If you know how to code and want to add something yourself, go for it!
1. **Fork** the repository and create your branch from `master`.
2. **Test** your changes! If you are editing the TUI, make sure it works across macOS and Linux (for bash scripts) or Windows (for `.bat` and PowerShell scripts).
3. **Open a Pull Request** and just give me a quick summary of what you changed and why.

## Code Guidelines
- **Bash Scripts (`.sh`):** Try to keep them POSIX compliant so they work on both Mac and Linux.
- **Windows Scripts (`.bat`/`.ps1`):** Ensure paths use standard environment variables (e.g., `%LOCALAPPDATA%`).
- **AppleScript/GUI:** If you tweak the Mac App, please make sure the `.app` bundle is re-zipped properly.

Thanks for checking out the tool!
