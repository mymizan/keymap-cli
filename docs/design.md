# System Design

## Overview

The CLI reads and modifies the macOS preference store where text replacements are saved.

Workflow:

1. Load macOS preferences plist
2. Extract text replacement array
3. Modify entries
4. Save updated plist

---

## Storage Format

File:

~/Library/Preferences/.GlobalPreferences.plist

Key:

NSUserDictionaryReplacementItems

Example item:

{
  "on": 1,
  "replace": "x.oc",
  "with": "npm install v24.14.0"
}

---

## Architecture

CLI Tool
│
├── Command Parser
│
├── Replacement Manager
│
├── Plist Reader
│
├── Plist Writer
│
└── Output Formatter

---

## Modules

### CLI Parser

Responsible for:

- parsing arguments
- validating commands

Commands supported:

add  
remove  
update  
list

---

### Replacement Manager

Handles business logic:

- detect duplicates
- update entries
- remove entries

---

### Plist Reader

Responsibilities:

- load plist
- parse NSUserDictionaryReplacementItems
- convert to Swift structs

---

### Plist Writer

Responsibilities:

- update array
- serialize plist
- safely write file back to disk

---

## Data Model

Swift struct example:

struct ReplacementItem {
    var shortcut: String
    var expansion: String
    var enabled: Bool
}

---

## Error Handling

Cases to handle:

- plist not found
- malformed plist
- duplicate entries
- missing arguments
- file write failure

---

## Logging

Errors should print human-readable messages.

Example:

Error: Shortcut already exists.
