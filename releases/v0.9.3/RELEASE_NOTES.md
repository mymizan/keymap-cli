# Release Notes - v0.9.3

## Cross-Platform macOS Compatibility

This release adds full compatibility across macOS versions, ensuring the app works on both modern and legacy macOS systems.

### What Changed
- **Unified Storage System**: Implemented automatic detection and fallback between storage methods
  - **Modern macOS (Tahoe 15.x+)**: Uses SQLite database `~/Library/KeyboardServices/TextReplacements.db`
  - **Legacy macOS (Ventura 13.x and older)**: Falls back to plist `~/.GlobalPreferences.plist`
- **Automatic Detection**: App detects which storage method is available and uses the appropriate one
- **Seamless Operation**: All CLI commands work identically regardless of macOS version

### Compatibility
- ✅ **macOS Tahoe (15.x)** and newer: Database storage
- ✅ **macOS Ventura (13.x)** and older: Plist storage
- ✅ **macOS Monterey (12.x)** and older: Plist storage
- ✅ **macOS Big Sur (11.x)** and older: Plist storage

### Impact
- No user action required - app automatically uses correct storage method
- All existing functionality preserved
- Backward compatible with previous installations
- Future-proof for upcoming macOS versions

### Testing
- Verified database storage on macOS Tahoe
- Confirmed plist fallback mechanism
- Tested all CLI operations (add, remove, update, list, etc.)
- Cross-platform functionality validated

### Installation
Replace your existing `keymap` binary with the new v0.9.3 binary. The app will automatically detect and use the appropriate storage method for your macOS version.

### Known Issues
None. Full compatibility across supported macOS versions.