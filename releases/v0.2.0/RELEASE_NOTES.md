# keymap v0.2.0 Release

**Release Date:** March 7, 2026

## Overview
Phase 2 completion: Full CLI argument parsing with comprehensive error handling and validation.

## What's New
- **CLI Argument Parser**: Complete command-line argument parsing with validation
- **Command Support**: Add, Remove, Update, List, and Help commands
- **Error Handling**: Validates arguments and provides helpful error messages
- **Test Coverage**: 14 comprehensive tests covering all parsing scenarios

## Commands

```bash
# Add a text replacement
keymap add <shortcut> <expansion>
keymap add x.oc "npm install v24.14.0"

# Remove a text replacement
keymap remove <shortcut>
keymap remove x.oc

# Update an existing text replacement
keymap update <shortcut> <expansion>
keymap update x.oc "npm install v24.15.0"

# List all text replacements
keymap list

# Show help
keymap help
keymap -h
keymap --help
```

## Test Results
- ✅ 14 CommandParserTests passed
- ✅ Case-insensitive command parsing
- ✅ Argument validation with error messages
- ✅ All edge cases covered

## Known Limitations
- Commands are acknowledged but not yet executed
- Plist reading/writing not yet implemented
- Output formatting not yet implemented

## Next Steps
Phase 3 will implement Plist reading to load macOS Text Replacement data from:
```
~/Library/Preferences/.GlobalPreferences.plist
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

## Tested Scenarios
- ✓ Help text displays correctly
- ✓ Add command with multiple word expansions
- ✓ Remove command with single argument
- ✓ Update command with complex expansions
- ✓ List command executes
- ✓ Invalid commands show error
- ✓ Missing arguments are caught
