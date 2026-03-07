# keymap v0.1.0 Release

**Release Date:** March 7, 2026

## Overview
Initial project setup for keymap — a command-line tool to manage macOS Text Replacement shortcuts.

## What's Included
- Compiled binary: `keymap`
- Complete project structure with modular architecture
- Swift Package Manager configuration
- Test framework setup

## Known Limitations
This is the initial setup release. The following phases are not yet implemented:
- CLI Argument Parsing
- Plist Reading/Writing
- Core functionality (add, remove, update, list commands)
- Error handling
- Output formatting

## Next Steps
Phase 2 will implement CLI argument parsing for the following commands:
```bash
keymap add <shortcut> <expansion>
keymap remove <shortcut>
keymap update <shortcut> <expansion>
keymap list
```

## Build Information
- Language: Swift 6.1+
- Platform: macOS (Ventura or newer)
- Binary: `keymap`

## Installation
Extract the binary and place it in your PATH:
```bash
chmod +x keymap
sudo mv keymap /usr/local/bin/
```
