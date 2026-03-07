# Changelog

All notable changes to this project will be documented in this file.

## [0.7.0] - 2026-03-07

### Added
- Implement comprehensive ErrorHandler class for enhanced error handling
  - Context-aware error messages with recovery suggestions
  - Environment validation before file operations
  - Input validation for shortcuts and expansions
  - File system error handling with specific error codes
  - Recovery hints for common issues (permissions, missing files, corruption)
- Enhance main.swift with error handling integration
  - Pre-operation environment checks for add/remove/update commands
  - Input validation before processing commands
  - Colored success/error/warning messages using OutputFormatter
  - Graceful handling of plist loading failures
  - Proper exit codes for different error conditions
- Create ErrorHandlerTests with 18 comprehensive test cases:
  - Manager error handling (already exists, not found, empty inputs)
  - Writer error handling (file not found, backup creation, serialization)
  - Reader error handling (file not found, invalid format, decoding errors)
  - Context-aware error messages
  - Input validation (empty, whitespace, valid inputs)

### Changed
- main.swift now includes comprehensive error handling and validation
- Error messages now include helpful recovery suggestions
- Output uses colored formatting for better user experience

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — ✅ Complete
- Phase 4: Data Manipulation — ✅ Complete
- Phase 5: Plist Writing — ✅ Complete
- Phase 6: Output Formatting — ✅ Complete
- Phase 7: Error Handling — ✅ Complete
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 95 tests passing (14 Command + 10 PlistReader + 25 ReplacementManager + 8 PlistWriter + 20 OutputFormatter + 18 ErrorHandler)
- Build: ✅ Success

## [0.6.0] - 2026-03-07

### Added
- Enhance OutputFormatter with multiple output formats
  - Table format (existing, with color support)
  - JSON format for machine-readable output
  - Summary statistics with counts and breakdown
  - Color support for terminal output (auto-detection)
  - Colored status indicators for enabled/disabled items
- Implement formatted message utilities
  - formatError() with red color and icon
  - formatSuccess() with green color and checkmark
  - formatWarning() with yellow color and warning symbol
- Create OutputFormatterTests with 20 comprehensive test cases:
  - List formatting (empty, single, multiple)
  - Sorting and column width calculations
  - JSON serialization with multiple items
  - Summary statistics with variations
  - Message formatting with colors
  - Edge cases (special characters, unicode)
  - Disabled item handling and display

### Changed
- OutputFormatter now supports multiple output formats
- Enhanced ColorTerminal detection for better user experience

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — ✅ Complete
- Phase 4: Data Manipulation — ✅ Complete
- Phase 5: Plist Writing — ✅ Complete
- Phase 6: Output Formatting — ✅ Complete
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 77 tests passing (14 Command + 10 PlistReader + 25 ReplacementManager + 8 PlistWriter + 20 OutputFormatter)
- Build: ✅ Success

## [0.5.0] - 2026-03-07

### Added
- Implement PlistWriter class for persisting changes to macOS plist
  - Write ReplacementItem objects back to NSUserDictionaryReplacementItems
  - Preserve existing plist keys while updating replacements
  - Create automatic backups before writing
  - Serialize swift objects to plist format
- Implement PlistWriterError enum for error handling
  - fileNotFound, cannotCreateBackup, serializationFailed, writeFailure
  - Descriptive error messages for debugging
- Integrate PlistWriter into main.swift
  - All add/remove/update operations now persist to disk
  - Changes are immediately saved to ~/.GlobalPreferences.plist
  - Proper error handling and rollback on failure
- Create PlistWriterTests with 8 comprehensive test cases:
  - Write empty/single/multiple replacements
  - Preserve enabled/disabled states
  - Backup creation and error handling
  - Dictionary conversion validation

### Changed
- Main entrypoint now persists all changes to plist
- Add/remove/update commands are now fully permanent

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — ✅ Complete
- Phase 4: Data Manipulation — ✅ Complete
- Phase 5: Plist Writing — ✅ Complete
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 57 tests passing (14 Command + 10 PlistReader + 25 ReplacementManager + 8 PlistWriter)
- Build: ✅ Success

## [0.4.0] - 2026-03-07

### Added
- Implement ReplacementManager class with core business logic
  - addShortcut() - Add new text replacements with duplicate detection
  - removeShortcut() - Remove replacements by shortcut
  - updateShortcut() - Update expansion text while preserving state
  - listShortcuts() - Get all replacements sorted alphabetically
  - getReplacement() - Find specific replacement by shortcut
  - count() - Get total number of replacements
- Implement ReplacementManagerError enum for error handling
  - shortcutNotFound, shortcutAlreadyExists
  - emptyShortcut, emptyExpansion
  - Descriptive error messages
- Implement OutputFormatter for list formatting
  - Format replacements in table columns
  - Align shortcut and expansion columns
  - Handle empty lists gracefully
- Update main.swift to use ReplacementManager
  - Load existing replacements from plist
  - Process commands with manager
  - Display appropriate success/error messages
  - Proper exit codes on error
- Create 25 ReplacementManagerTests covering:
  - Add operations (single, multiple, duplicates, validation)
  - Remove operations (existing, non-existent, multiple items)
  - Update operations (valid, non-existent, state preservation)
  - List operations (sorting, consistency, empty state)
  - Integration workflows (add-update-remove chains)
  - Error handling and descriptions

### Changed
- Replace command acknowledgement with actual functionality
- ReplacementManagerTests now contains full test suite (25 tests)

### Status
- Phase 1: Project Setup — ✅ Complete
- Phase 2: CLI Argument Parsing — ✅ Complete
- Phase 3: Plist Reading — ✅ Complete
- Phase 4: Data Manipulation — ✅ Complete
- Phase 5: Plist Writing — 🔲 Pending
- Phase 6: Output Formatting — 🔲 Pending
- Phase 7: Error Handling — 🔲 Pending
- Phase 8: Testing — 🔲 Pending

### Test Results
- All 49 tests passing (14 CommandParser + 10 PlistReader + 25 ReplacementManager)
- Build: ✅ Success

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
