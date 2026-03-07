# keymap v0.3.0 Release

**Release Date:** March 7, 2026

## Overview
Phase 3 completion: Complete plist reading implementation for loading macOS Text Replacement data.

## What's New
- **Data Model**: Full ReplacementItem struct with encoding/decoding support
- **Plist Reader**: Loads macOS text replacements from ~/.GlobalPreferences.plist
- **NSUserDictionaryReplacementItems**: Properly parses Apple's text replacement format
- **Type Safety**: Codable implementation ensures type-safe data handling

## Data Model

### ReplacementItem
```swift
struct ReplacementItem {
    var replace: String      // The shortcut
    var with: String         // The expansion text
    var on: Bool             // Whether enabled
}
```

**Convenience Properties:**
- `shortcut` → `replace`
- `expansion` → `with`
- `enabled` → `on`

## Features

### Load All Replacements
Reads all text replacements from macOS:
```swift
let replacements = try PlistReader.loadReplacements()
```

### Load Single Replacement
Find a specific replacement by shortcut:
```swift
let item = try PlistReader.loadReplacement(shortcut: "x.oc")
```

### Error Handling
Descriptive error types:
- `PlistReaderError.fileNotFound` - Plist file doesn't exist
- `PlistReaderError.invalidFormat` - Invalid plist format
- `PlistReaderError.decodingError(String)` - Decoding failed
- `PlistReaderError.unknown(String)` - Other errors

## Plist File Location
- **Path**: `~/.GlobalPreferences.plist`
- **Key**: `NSUserDictionaryReplacementItems`
- **Format**: Array of dictionaries with keys: `replace`, `with`, `on`

## Test Coverage
- ✅ 10 PlistReaderTests covering:
  - ReplacementItem encoding/decoding
  - Property access and equality
  - Plist file creation and parsing
  - Dictionary to ReplacementItem conversion
  - Array handling for multiple items
  - Error types and descriptions

## Test Results
- ✅ 25 total tests passing
  - 14 CommandParserTests
  - 10 PlistReaderTests
  - 1 ReplacementManagerTests placeholder

## Known Limitations
- Only reads plist; writing not yet implemented (Phase 5)
- Commands still display acknowledgement only (Phase 4)
- Output formatting not yet implemented (Phase 6)

## Next Steps
Phase 4 will implement ReplacementManager with actual operations:
- Add shortcut functionality
- Remove shortcut functionality
- Update shortcut functionality
- List shortcuts functionality

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

## Architecture
```
PlistReader
    ↓
loads ~/.GlobalPreferences.plist
    ↓
deserializes NSUserDictionaryReplacementItems
    ↓
converts to ReplacementItem objects
    ↓
returns [ReplacementItem]
```
