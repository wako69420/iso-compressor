# Contributing to PS1, PS2 & PSP ISO Compressor

First off, thank you for considering contributing to this project! It's people like you that make the retro-gaming and emulation community such a fantastic place.

## How Can I Contribute?

### Reporting Bugs
This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.
- **Use the bug report template** provided in the Issues tab.
- **Include OS and Version** (e.g., Mac GUI, Windows TUI, Linux).

### Suggesting Enhancements
Feature requests are always welcome! 
- **Use the feature request template** in the Issues tab.
- Explain how this enhancement would help the broader community (e.g., adding a new compression format, supporting a new emulator).

### Pull Requests
We actively welcome Pull Requests!
1. **Fork** the repository and create your branch from `master`.
2. **Test** your changes! If you are editing the TUI, make sure it works across macOS and Linux (for bash scripts) or Windows (for `.bat` and PowerShell scripts).
3. **Open a Pull Request** using the provided template. Make sure your PR description clearly describes what you changed and why.

## Code Guidelines
- **Bash Scripts (`.sh`):** Try to keep POSIX compliance where possible so it works across macOS and Linux.
- **Windows Scripts (`.bat`/`.ps1`):** Ensure paths use standard environment variables (e.g., `%LOCALAPPDATA%`).
- **AppleScript/GUI:** When compiling changes to the Mac App, please ensure the `.app` bundle is re-zipped and properly referenced.

Thank you for helping us make ISO compression better for everyone!
