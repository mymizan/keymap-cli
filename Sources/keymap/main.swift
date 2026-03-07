import Foundation

// Parse command-line arguments
let arguments = CommandLine.arguments
let command = CommandParser.parse(arguments: arguments)

// Load existing replacements from plist
var manager: ReplacementManager
do {
    let existingReplacements = try PlistReader.loadReplacements()
    manager = ReplacementManager(replacements: existingReplacements)
} catch {
    // If plist doesn't exist or can't be read, start with empty manager
    manager = ReplacementManager()
}

switch command {
case .add(let shortcut, let expansion):
    do {
        try manager.addShortcut(shortcut, expansion: expansion)
        print("✓ Added: '\(shortcut)' → '\(expansion)'")
    } catch let error as ReplacementManagerError {
        print(error.description)
        exit(1)
    } catch {
        print("Error: \(error)")
        exit(1)
    }
    
case .remove(let shortcut):
    do {
        try manager.removeShortcut(shortcut)
        print("✓ Removed: '\(shortcut)'")
    } catch let error as ReplacementManagerError {
        print(error.description)
        exit(1)
    } catch {
        print("Error: \(error)")
        exit(1)
    }
    
case .update(let shortcut, let expansion):
    do {
        try manager.updateShortcut(shortcut, expansion: expansion)
        print("✓ Updated: '\(shortcut)' → '\(expansion)'")
    } catch let error as ReplacementManagerError {
        print(error.description)
        exit(1)
    } catch {
        print("Error: \(error)")
        exit(1)
    }
    
case .list:
    let shortcuts = manager.listShortcuts()
    if shortcuts.isEmpty {
        print("No text replacements found.")
    } else {
        print(OutputFormatter.formatList(shortcuts))
    }
    
case .help:
    CommandParser.printUsage()
    
case .unknown:
    print("Error: Unknown command")
    CommandParser.printUsage()
    exit(1)
}
