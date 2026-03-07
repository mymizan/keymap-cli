# keymap v0.4.0 Release

**Release Date:** March 7, 2026

## Overview
Phase 4 completion: Full data manipulation and core functionality implementation. All basic operations are now fully functional.

## What's New
- **Complete ReplacementManager**: Add, remove, update, and list operations
- **Functional CLI**: Commands now execute with real operations
- **Output Formatting**: List command displays shortcuts in organized table format
- **Comprehensive Error Handling**: Descriptive error messages for all failure scenarios

## Features

### Add Shortcuts
```bash
keymap add <shortcut> <expansion>
keymap add x.oc "npm install v24.14.0"
```
- Prevents duplicate shortcuts (shows error)
- Creates new replacement with enabled state
- Validates non-empty shortcut and expansion

### Remove Shortcuts
```bash
keymap remove <shortcut>
keymap remove x.oc
```
- Removes matching shortcut
- Validates shortcut exists
- Displays error if not found

### Update Shortcuts
```bash
keymap update <shortcut> <expansion>
keymap update x.oc "npm install v24.15.0"
```
- Updates expansion text
- Preserves enabled state
- Validates shortcut exists

### List Shortcuts
```bash
keymap list
```
- Displays all shortcuts in alphabetical order
- Formatted table with aligned columns
- Shows "No text replacements" when empty

## Error Handling

Clear, descriptive errors for:
- **Duplicate shortcuts**: "Error: Shortcut 'x.oc' already exists. Use update to modify."
- **Missing shortcuts**: "Error: Shortcut 'nonexistent' not found."
- **Empty input**: "Error: Shortcut cannot be empty."
- **Invalid expansion**: "Error: Expansion cannot be empty."

## ReplacementManager API

```swift
// Initialize manager
let manager = ReplacementManager()
let manager = ReplacementManager(replacements: existingItems)

// Add operation
try manager.addShortcut("x.oc", expansion: "npm install")

// Remove operation
try manager.removeShortcut("x.oc")

// Update operation
try manager.updateShortcut("x.oc", expansion: "new expansion")

// List operations
let sorted = manager.listShortcuts()
let count = manager.count()
let item = manager.getReplacement("x.oc")
let all = manager.getAll()
```

## Test Coverage
- ✅ 25 ReplacementManagerTests covering:
  - Add operations (single, multiple, duplicates, validation)
  - Remove operations (existing/non-existent, multiple)
  - Update operations (valid updates, state preservation)
  - List operations (sorting, consistency, empty state)
  - Integration workflows (multi-step operations)
  - Error handling and messages

## Total Test Results
- ✅ 49 total tests passing (100% success rate)
  - 14 CommandParserTests
  - 10 PlistReaderTests
  - 25 ReplacementManagerTests

## Plist Integration
- Loads existing replacements from ~/.GlobalPreferences.plist on startup
- Handles missing plist gracefully (starts with empty manager)
- Ready for Phase 5 (plist writing)

## Workflow Example

```bash
# Add multiple shortcuts
keymap add x.oc "npm install v24.14.0"
keymap add gh.c "git checkout"
keymap add gs.s "git status"

# Update one
keymap update x.oc "npm install v24.15.0"

# List all (sorted alphabetically)
keymap list

# Remove one
keymap remove gs.s
```

## Known Limitations
- Changes are not yet persisted to plist (Phase 5)
- No macro expansion or wildcard features
- Text replacement synchronization not yet implemented

## Next Steps
Phase 5 will implement plist writing to persist all changes back to:
```
~/.GlobalPreferences.plist
```

## Architecture
```
CLI Arguments
    ↓
CommandParser (Phase 2)
    ↓
ReplacementManager (Phase 4) ← YOU ARE HERE
    ├─ Add/Remove/Update/List operations
    └─ Error handling & validation
    ↓
PlistReader (Phase 3)
    └─ Loads data from ~/.GlobalPreferences.plist
    ↓
OutputFormatter (Phase 4)
    └─ Formats list output
    ↓
[Phase 5: PlistWriter - Write back to plist]
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
- ✓ Add new shortcuts
- ✓ Add duplicate shortcut (error)
- ✓ Remove existing shortcut
- ✓ Remove non-existent shortcut (error)
- ✓ Update shortcut expansion
- ✓ Update non-existent shortcut (error)
- ✓ List empty replacements
- ✓ List multiple replacements (sorted)
- ✓ Complex workflows (add → update → remove)
- ✓ All error messages display correctly
