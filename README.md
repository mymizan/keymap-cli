# keymap

A command-line tool to manage macOS Text Replacement shortcuts.

## Installation

Build the project using Swift Package Manager:

```bash
swift build -c release
```

The binary will be available at `.build/release/keymap`.

## Usage

```bash
keymap add <shortcut> <expansion>
keymap remove <shortcut>
keymap update <shortcut> <expansion>
keymap list
keymap search <query>
keymap enable <shortcut>
keymap disable <shortcut>
keymap export [file]
keymap import <file>
```