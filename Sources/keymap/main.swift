import Foundation

// Parse command-line arguments
let arguments = CommandLine.arguments
let command = CommandParser.parse(arguments: arguments)

// Validate environment before operations that modify files
func needsEnvironmentValidation(_ command: Command) -> Bool {
    switch command {
    case .add, .remove, .update, .import, .enable, .disable:
        return true
    case .list, .export, .search, .help, .unknown:
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
    
case .export(let file):
    let items = manager.exportItems()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    if let data = try? encoder.encode(items), let jsonString = String(data: data, encoding: .utf8) {
        if let path = file {
            // attempt to write to given path
            do {
                try jsonString.write(toFile: path, atomically: true, encoding: .utf8)
                print(OutputFormatter.formatSuccess("Exported to \(path)"))
            } catch {
                ErrorHandler.handle(error, context: "exporting to \(path)")
                exit(1)
            }
        } else {
            print(jsonString)
        }
    } else {
        print(OutputFormatter.formatError("Failed to serialize export data"))
        exit(1)
    }
    
case .import(let file):
    // read JSON file and merge
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: file))
        let decoded = try JSONDecoder().decode([ReplacementItem].self, from: data)
        _ = manager.importItems(decoded)
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Imported \(decoded.count) replacements from \(file)"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "importing replacements")
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "importing from \(file)")
        exit(1)
    }
    
case .search(let query):
    let results = manager.search(query)
    if results.isEmpty {
        print(OutputFormatter.formatWarning("No results for '\(query)'"))
    } else {
        print(OutputFormatter.formatList(results))
    }
    
case .enable(let shortcut):
    guard ErrorHandler.validateInput(shortcut: shortcut) else { exit(1) }
    do {
        try manager.enableShortcut(shortcut)
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Enabled: '\(shortcut)'"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "enable shortcut")
        exit(1)
    } catch let error as PlistWriterError {
        ErrorHandler.handle(error, context: "saving changes")
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "enable shortcut")
        exit(1)
    }
    
case .disable(let shortcut):
    guard ErrorHandler.validateInput(shortcut: shortcut) else { exit(1) }
    do {
        try manager.disableShortcut(shortcut)
        try PlistWriter.writeReplacements(manager.getAll())
        print(OutputFormatter.formatSuccess("Disabled: '\(shortcut)'"))
    } catch let error as ReplacementManagerError {
        ErrorHandler.handle(error, context: "disable shortcut")
        exit(1)
    } catch let error as PlistWriterError {
        ErrorHandler.handle(error, context: "saving changes")
        exit(1)
    } catch {
        ErrorHandler.handle(error, context: "disable shortcut")
        exit(1)
    }
    
case .help:
    CommandParser.printUsage()
    
case .unknown:
    print(OutputFormatter.formatError("Unknown command"))
    CommandParser.printUsage()
    exit(1)
}
