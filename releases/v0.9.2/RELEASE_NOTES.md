# Release Notes - v0.9.2

## Critical Bug Fix: macOS Compatibility Update

This release fixes a critical compatibility issue with macOS Tahoe (15.x) and newer versions where text replacements were not working due to changes in Apple's storage backend.

### What Changed
- **Storage Backend Migration**: Updated from the deprecated `~/.GlobalPreferences.plist` to the new `~/Library/KeyboardServices/TextReplacements.db` SQLite database
- **Database Integration**: Implemented proper SQLite3 database read/write operations with transaction safety
- **Error Handling**: Updated error messages and validation to reference correct file paths
- **Dependencies**: Added SQLite3 system library dependency

### Impact
- Text replacements added via `keymap add` now properly appear in macOS System Settings → Keyboard → Text Replacements
- All existing CLI functionality (add, remove, update, list, search, enable, disable, import) works correctly
- Backward compatible with existing command-line interface

### Testing
- Verified add/remove/update operations work with system text replacements
- Confirmed list command reads from correct database
- All core functionality tested and working

### Installation
Replace your existing `keymap` binary with the new v0.9.2 binary.

### Known Issues
None. This release restores full functionality on modern macOS versions.