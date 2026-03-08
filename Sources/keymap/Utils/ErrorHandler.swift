// ErrorHandler.swift - Comprehensive error handling and recovery

import Foundation

enum SystemError: Error, Equatable {
    case permissionDenied(String)
    case corruptedPlist
    case diskFull
    case unexpectedError(String)
}

class ErrorHandler {
    
    /// Handle and display errors with recovery suggestions
    static func handle(_ error: Error, context: String = "") {
        let message = buildErrorMessage(error, context: context)
        print(message)
    }
    
    /// Build comprehensive error message with recovery suggestions
    static func buildErrorMessage(_ error: Error, context: String) -> String {
        var message = ""
        
        // Add context if provided
        if !context.isEmpty {
            message += "In '\(context)':\n"
        }
        
        // Match specific error types
        if let managerError = error as? ReplacementManagerError {
            message += managerError.description
            message += recoveryForManagerError(managerError)
        } else if let storageError = error as? TextReplacementStorageError {
            message += storageError.description
            message += recoveryForStorageError(storageError)
        } else {
            message += "Error: \(error.localizedDescription)"
        }
        
        return message
    }
    
    // Recovery suggestions for different error types
    private static func recoveryForManagerError(_ error: ReplacementManagerError) -> String {
        switch error {
        case .shortcutAlreadyExists(let shortcut):
            return "\nHint: Use 'keymap update \(shortcut) <new expansion>' to change it."
        case .shortcutNotFound(_):
            return "\nHint: Use 'keymap list' to see available shortcuts."
        case .emptyShortcut:
            return "\nHint: Shortcut must not be empty. Use 'keymap add <shortcut> <expansion>'."
        case .emptyExpansion:
            return "\nHint: Expansion must not be empty. Use 'keymap add <shortcut> <expansion>'."
        case .alreadyEnabled(let shortcut):
            return "\nHint: Use 'keymap disable \(shortcut)' if you want to turn it off."
        case .alreadyDisabled(let shortcut):
            return "\nHint: Use 'keymap enable \(shortcut)' if you want to turn it on."
        case .unknown:
            return "\nHint: Run 'keymap help' for usage information."
        }
    }
    
    private static func recoveryForStorageError(_ error: TextReplacementStorageError) -> String {
        switch error {
        case .databaseNotFound:
            return "\nHint: macOS text replacement database doesn't exist. Will fall back to plist."
        case .plistNotFound:
            return "\nHint: macOS text replacement plist doesn't exist. Check ~/.GlobalPreferences.plist"
        case .invalidFormat:
            return "\nHint: Storage has invalid format. Try restoring from backup."
        case .decodingError:
            return "\nHint: Storage may be corrupted. Try restoring from backup."
        case .writeFailure(let msg):
            return "\nHint: \(msg). Check disk space and file permissions."
        case .unknown:
            return "\nHint: Try again or check system logs."
        }
    }
    
    /// Check for common issues before operations
    static func validateEnvironment() -> Bool {
        let fileManager = FileManager.default
        let databasePath = (NSString("~/Library/KeyboardServices/TextReplacements.db")).expandingTildeInPath
        let plistPath = (NSString("~/Library/Preferences/.GlobalPreferences.plist")).expandingTildeInPath
        
        // Check if either database or plist exists and is writable
        let hasDatabase = fileManager.fileExists(atPath: databasePath) && fileManager.isWritableFile(atPath: databasePath)
        let hasPlist = fileManager.fileExists(atPath: plistPath) && fileManager.isWritableFile(atPath: plistPath)
        
        if !hasDatabase && !hasPlist {
            // Try to create plist as fallback
            let parentDir = (plistPath as NSString).deletingLastPathComponent
            if !fileManager.fileExists(atPath: parentDir) {
                print("Error: Library/Preferences directory not found.")
                return false
            }
            // Create empty plist
            let emptyPlist: [String: Any] = ["NSUserDictionaryReplacementItems": []]
            do {
                let data = try PropertyListSerialization.data(fromPropertyList: emptyPlist, format: .xml, options: 0)
                fileManager.createFile(atPath: plistPath, contents: data, attributes: nil)
            } catch {
                print("Error: Could not create plist file.")
                return false
            }
        }
        
        return true
    }
    
    /// Validate input before processing
    static func validateInput(shortcut: String, expansion: String? = nil) -> Bool {
        let trimmedShortcut = shortcut.trimmingCharacters(in: .whitespaces)
        if trimmedShortcut.isEmpty {
            print("Error: Shortcut cannot be empty.")
            return false
        }
        
        if let expansion = expansion {
            let trimmedExpansion = expansion.trimmingCharacters(in: .whitespaces)
            if trimmedExpansion.isEmpty {
                print("Error: Expansion cannot be empty.")
                return false
            }
        }
        
        return true
    }
    
    /// Handle file system errors gracefully
    static func handleFileSystemError(_ error: NSError) {
        let code = error.code
        
        switch code {
        case NSFileReadNoSuchFileError:
            print("Error: File or directory not found.")
        case NSFileReadUnknownError, NSFileReadInapplicableStringEncodingError:
            print("Error: Cannot read file.")
        case NSFileWriteNoPermissionError:
            print("Error: Permission denied. Cannot write to file.")
        case NSFileWriteVolumeReadOnlyError:
            print("Error: Volume is read-only.")
        default:
            print("Error: File system error (Code: \(code))")
        }
    }
}