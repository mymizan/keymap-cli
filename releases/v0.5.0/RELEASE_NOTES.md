# keymap v0.5.0 Release

**Release Date:** March 7, 2026

## Overview
Phase 5 completion: Full plist writing implementation. All changes are now permanently persisted to macOS text replacement storage.

## What's New
- **Persistent Storage**: All add/remove/update operations now save to ~/.GlobalPreferences.plist
- **PlistWriter**: Complete serialization and writing of replacement data
- **Automatic Backups**: Creates .backup before writing to enable recovery
- **Full Integration**: Read-modify-write workflow is complete

## Key Features

### Persistent Operations
All commands now permanently modify macOS text replacements:

```bash
keymap add x.oc "npm install v24.14.0"    # ✓ Saves to plist
keymap update x.oc "new expansion"        # ✓ Updates on disk
keymap remove x.oc                         # ✓ Removes completely
```

### PlistWriter API

```swift
// Write replacements to plist
try PlistWriter.writeReplacements(replacements)
```

Features:
- Reads existing plist to preserve other keys
- Serializes ReplacementItem objects to plist format
- Creates automatic backups for safety
- Proper error handling with descriptive messages

### Workflow

```
User Command
    ↓
CommandParser
    ↓
ReplacementManager (add/remove/update)
    ↓
PlistReader (load existing)
    ↓
Modify in memory
    ↓
PlistWriter (persist to disk)  ← NEW
    ↓
macOS Text Replacement
```

## Complete Operation Example

```bash
# Start fresh (no replacements in macOS)
$ keymap list
No text replacements found.

# Add some replacements
$ keymap add x.oc "npm install v24.14.0"
✓ Added: 'x.oc' → 'npm install v24.14.0'

$ keymap add gh.c "git checkout"
✓ Added: 'gh.c' → 'git checkout'

# List them (now persisted)
$ keymap list
gh.c            git checkout
x.oc            npm install v24.14.0

# Update one
$ keymap update x.oc "npm install && npm test"
✓ Updated: 'x.oc' → 'npm install && npm test'

# Verify changes persisted
$ keymap list
gh.c            git checkout
x.oc            npm install && npm test

# Text replacements now work in macOS!
# Type "x.oc" anywhere and it expands automatically
```

## PlistWriter Details

### Error Handling
- `fileNotFound` - Plist file doesn't exist
- `cannotCreateBackup` - Can't backup before write
- `serializationFailed` - Can't convert to plist format
- `writeFailure(String)` - Can't write to disk

### Backup Management
- Automatic .backup creation at: `~/.GlobalPreferences.plist.backup`
- Preserves data if write fails
- Can be manually restored if needed

### Data Preservation
- Preserves all existing plist keys
- Only modifies NSUserDictionaryReplacementItems
- System settings and other preferences untouched

## Test Coverage
- ✅ 8 PlistWriterTests covering:
  - Write empty/single/multiple replacements
  - Preserve enabled/disabled states
  - Backup creation
  - Dictionary serialization
  - Error handling and descriptions

## Total Test Results
- ✅ 57 total tests passing (100% success rate)
  - 14 CommandParserTests
  - 10 PlistReaderTests
  - 25 ReplacementManagerTests
  - 8 PlistWriterTests

## Flow Verification
- ✓ Add command → loads plist → adds item → writes to disk
- ✓ Remove command → loads plist → removes item → writes to disk
- ✓ Update command → loads plist → updates item → writes to disk
- ✓ List command → loads and displays
- ✓ All changes visible in System Settings

## Known Limitations
- Requires write access to ~/.GlobalPreferences.plist
- Changes take effect on next application that reads plist
- No undo/version history (but backup is available)

## Next Steps
Phase 6 will enhance output formatting with:
- Better table formatting options
- Column width optimization
- Color support (if terminal supports it)

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

## Usage
```bash
# Add text replacement
keymap add <shortcut> <expansion>

# Remove text replacement
keymap remove <shortcut>

# Update existing replacement
keymap update <shortcut> <expansion>

# List all replacements
keymap list

# Show help
keymap help
```

## Now Fully Functional!
This release marks the transition from in-memory operations to persistent storage. The tool can now be used to manage macOS text replacements from the command line with all changes being permanent.
