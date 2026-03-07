# keymap v0.9.0 Release

**Release Date:** March 7, 2026

## Overview
Phase 9 completion: new CLI commands expand the utility of the tool with search, toggling, and import/export features.

## What's New
- **New Commands**
  - `search <query>`: Quickly filter shortcuts or expansions.
  - `enable <shortcut>` / `disable <shortcut>`: Toggle replacement activation state.
  - `export [file]`: Dump current replacements as JSON to stdout or file.
  - `import <file>`: Load replacements from a JSON file, merging with existing entries.
- **Core API Extensions**
  - `ReplacementManager` gained `search`, `enableShortcut`, `disableShortcut`, `exportItems`, and `importItems`.
  - New error cases (`alreadyEnabled`, `alreadyDisabled`) with recovery hints.
- **CLI Enhancements**
  - CommandParser and main logic updated for all new operations.
  - Comprehensive tests added for parsing and manager behavior.
  - IntegrationTests augmented to cover end-to-end workflows including the new commands.

## Test Coverage
- ✅ Additional 18+ tests bringing total over 131.
- ✅ All tests pass successfully.

## Total Test Results
- ✅ 100% test pass rate.

## Installation
```bash
swift build -c release
chmod +x keymap
sudo mv keymap /usr/local/bin/
```

## Usage Examples
```bash
keymap search npm
keymap disable x.oc
keymap export > mybackup.json
keymap import mybackup.json
```

## Notes
This release delivers full Phase 9 functionality and sets the stage for future improvements such as a GUI or additional utilities.
