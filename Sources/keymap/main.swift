import Foundation

// Parse command-line arguments
let arguments = CommandLine.arguments
let command = CommandParser.parse(arguments: arguments)

// Validate environment before operations that modify files
func needsEnvironmentValidation(_ command: Command) -> Bool {
    switch command {
    case .add, .remove, .update:
        return true
    case .list, .help, .unknown:
        return false
    }
}

if needsEnvironmentValidation(command) && !ErrorHandler.validateEnvironment() {
    exit(1)
}

// Load existing replacements from plist
var manager: ReplacementManager
do {
    let existingReplacements = try PlistReader.loadReplacements()
    manager = ReplacementManager(replacements: existingReplacements)
} catch {
    manager = ReplacementManager()  // Initialize with empty manager
    // For list command, show error but don't fail
    if case .list = command {
        ErrorHandler.handle(error, context: "loading replacements")
        print("No text replacements found.")
        exit(0)
    } else if case .help = command {
        // Help doesn't need data, just show usage
    } else if case .unknown = command {
        // Unknown commands fail anyway
        ErrorHandler.handle(error, context: "loading replacements")
        exit(1)
    } else {
        // For add/remove/update, fail if we can't load
        ErrorHandler.handle(error, context: "loading replacements")
        exit(1)
    }
}

switch command {
case .add(let shortcut, let expansion):
    // Validate input before processing
    guard ErrorHandler.validateInput(shortcut: shortcut, expansion: expansion) else {
        exit(1)
    }
    
    do {
        try manager.addShortcut(shortcut, expansion: expansion)
        // Write changes back to plist
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Added: '\(shortcut)' → '\(expansion)'"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "add shortcut")
        exit(1)
    } catch let error as PlistWriterError {
        ErrorHandler.handle(error, context: "saving changes")
        exit(1)
    } catch let error as NSError {
        ErrorHandler.handleFileSystemError(error)
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "add shortcut")
        exit(1)
    }
    
case .remove(let shortcut):
    // Validate input before processing
    guard ErrorHandler.validateInput(shortcut: shortcut) else {
        exit(1)
    }
    
    do {
        try manager.removeShortcut(shortcut)
        // Write changes back to plist
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Removed: '\(shortcut)'"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "remove shortcut")
        exit(1)
    } catch let error as PlistWriterError {
        ErrorHandler.handle(error, context: "saving changes")
        exit(1)
    } catch let error as NSError {
        ErrorHandler.handleFileSystemError(error)
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "remove shortcut")
        exit(1)
    }
    
case .update(let shortcut, let expansion):
    // Validate input before processing
    guard ErrorHandler.validateInput(shortcut: shortcut, expansion: expansion) else {
        exit(1)
    }
    
    do {
        try manager.updateShortcut(shortcut, expansion: expansion)
        // Write changes back to plist
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Updated: '\(shortcut)' → '\(expansion)'"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "update shortcut")
        exit(1)
    } catch let error as PlistWriterError {
        ErrorHandler.handle(error, context: "saving changes")
        exit(1)
    } catch let error as NSError {
        ErrorHandler.handleFileSystemError(error)
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "update shortcut")
        exit(1)
    }
    
case .list:
    let shortcuts = manager.listShortcuts()
    if shortcuts.isEmpty {
        print(OutputFormatter.formatWarning("No text replacements found."))
    } else {
        print(OutputFormatter.formatList(shortcuts))
    }
    
case .help:
    CommandParser.printUsage()
    
case .unknown:
    print(OutputFormatter.formatError("Unknown command"))
    CommandParser.printUsage()
    exit(1)
}
