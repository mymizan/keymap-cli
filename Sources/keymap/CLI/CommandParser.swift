// CommandParser.swift - CLI argument parser

enum Command {
    case add(shortcut: String, expansion: String)
    case remove(shortcut: String)
    case update(shortcut: String, expansion: String)
    case list
    case unknown
    case help
}

class CommandParser {
    
    static func parse(arguments: [String]) -> Command {
        // Skip the program name (first argument)
        let args = Array(arguments.dropFirst())
        
        guard !args.isEmpty else {
            return .help
        }
        
        let command = args[0].lowercased()
        
        switch command {
        case "add":
            return parseAdd(args: args)
        case "remove":
            return parseRemove(args: args)
        case "update":
            return parseUpdate(args: args)
        case "list":
            return .list
        case "help", "-h", "--help":
            return .help
        default:
            return .unknown
        }
    }
    
    private static func parseAdd(args: [String]) -> Command {
        // add <shortcut> <expansion>
        guard args.count == 3 else {
            printAddUsage()
            return .unknown
        }
        let shortcut = args[1]
        let expansion = args[2]
        return .add(shortcut: shortcut, expansion: expansion)
    }
    
    private static func parseRemove(args: [String]) -> Command {
        // remove <shortcut>
        guard args.count == 2 else {
            printRemoveUsage()
            return .unknown
        }
        let shortcut = args[1]
        return .remove(shortcut: shortcut)
    }
    
    private static func parseUpdate(args: [String]) -> Command {
        // update <shortcut> <expansion>
        guard args.count == 3 else {
            printUpdateUsage()
            return .unknown
        }
        let shortcut = args[1]
        let expansion = args[2]
        return .update(shortcut: shortcut, expansion: expansion)
    }
    
    static func printUsage() {
        print("""
        keymap - macOS Text Replacement CLI Manager
        
        Usage:
            keymap <command> [arguments]
        
        Commands:
            add <shortcut> <expansion>    Add a new text replacement
            remove <shortcut>             Remove a text replacement
            update <shortcut> <expansion> Update an existing text replacement
            list                          List all text replacements
            help                          Show this help message
        
        Examples:
            keymap add x.oc "npm install v24.14.0"
            keymap remove x.oc
            keymap update x.oc "npm install v24.15.0"
            keymap list
        """)
    }
    
    private static func printAddUsage() {
        print("Usage: keymap add <shortcut> <expansion>")
        print("Example: keymap add x.oc \"npm install v24.14.0\"")
    }
    
    private static func printRemoveUsage() {
        print("Usage: keymap remove <shortcut>")
        print("Example: keymap remove x.oc")
    }
    
    private static func printUpdateUsage() {
        print("Usage: keymap update <shortcut> <expansion>")
        print("Example: keymap update x.oc \"npm install v24.15.0\"")
    }
}