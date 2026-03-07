# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2026-03-07

### Added
- Implement ReplacementItem data model with Codable support
  - Properties: replace (shortcut), with (expansion), on (enabled)
  - Convenience accessors: shortcut, expansion, enabled
  - Proper initialization and encoding/decoding
- Implement PlistReader for macOS plist file handling
  - Load replacements from ~/.GlobalPreferences.plist
  - Parse NSUserDictionaryReplacementItems key
  - Convert plist dictionaries to ReplacementItem objects
  - Error handling with descriptive PlistReaderError enum
  - Support for loading all replacements or single items by shortcut
- Create comprehensive PlistReaderTests with 10 test cases:
  - ReplacementItem encoding/decoding
  - Property access and equality
  - Plist file creation and deserilization
  - Dictionary to ReplacementItem conversion
  - Array conversion with multiple items
  - Error handling and descriptions

### Changed
- Enhance test infrastructure for plist file handling

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — ✅ Complete
- Phase 4: Data Manipulation — 🔲 Pending
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 25 tests passing (14 CommandParser + 10 PlistReader + 1 ReplacementManager)
- Build: ✅ Success

## [0.2.0] - 2026-03-07

### Added
- Implement CLI argument parser with CommandParser class
- Create Command enum supporting: add, remove, update, list, help
- Add comprehensive argument validation with error messages
- Implement help text with usage examples
- Add support for case-insensitive command parsing
- Create CommandParserTests with 14 test cases covering:
  - All command types (add, remove, update, list)
  - Missing/invalid arguments
  - Help flags (-h, --help)
  - Edge cases and complex expansions

### Changed
- Update main.swift to use CommandParser for CLI routing
- Implement command acknowledgement messages (Phase 4 implementation pending)

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — 🔲 Pending
- Phase 4: Data Manipulation — 🔲 Pending
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 15 tests passing (14 CommandParserTests + 1 ReplacementManagerTests)
- Build: ✅ Success

## [0.1.0] - 2026-03-07

### Added
- Initialize Swift CLI project using Swift Package Manager
- Create main command entrypoint with binary name "keymap"
- Set up complete folder structure (CLI, Core, Storage, Utils modules)
- Configure Package.swift with executable and test targets
- Create placeholder modules for all phases:
  - CLI/CommandParser.swift
  - Core/ReplacementManager.swift
  - Core/ReplacementItem.swift
  - Storage/PlistReader.swift
  - Storage/PlistWriter.swift
  - Utils/OutputFormatter.swift
- Create initial test suite (ReplacementManagerTests)
- Added README with usage documentation
- Set up release folder structure (releases/v0.1.0)

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — 🔲 Pending
- Phase 3: Plist Reading — 🔲 Pending
- Phase 4: Data Manipulation — 🔲 Pending
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending
