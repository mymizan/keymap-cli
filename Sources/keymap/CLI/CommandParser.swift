// CommandParser.swift - CLI argument parser

enum Command: Equatable {
    case add(shortcut: String, expansion: String)
    case remove(shortcut: String)
    case update(shortcut: String, expansion: String)
    case list
    case export(file: String?)         // nil means stdout
    case `import`(file: String)        // import from file
    case search(query: String)
    case enable(shortcut: String)
    case disable(shortcut: String)
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
        case "export":
            return parseExport(args: args)
        case "import":
            return parseImport(args: args)
        case "search":
            return parseSearch(args: args)
        case "enable":
            return parseEnable(args: args)
        case "disable":
            return parseDisable(args: args)
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

    private static func parseExport(args: [String]) -> Command {
        // export [<file>]
        switch args.count {
        case 1:
            return .export(file: nil)
        case 2:
            return .export(file: args[1])
        default:
            printExportUsage()
            return .unknown
        }
    }

    private static func parseImport(args: [String]) -> Command {
        // import <file>
        guard args.count == 2 else {
            printImportUsage()
            return .unknown
        }
        return .import(file: args[1])
    }

    private static func parseSearch(args: [String]) -> Command {
        // search <query>
        guard args.count == 2 else {
            printSearchUsage()
            return .unknown
        }
        return .search(query: args[1])
    }

    private static func parseEnable(args: [String]) -> Command {
        // enable <shortcut>
        guard args.count == 2 else {
            printEnableUsage()
            return .unknown
        }
        return .enable(shortcut: args[1])
    }

    private static func parseDisable(args: [String]) -> Command {
        // disable <shortcut>
        guard args.count == 2 else {
            printDisableUsage()
            return .unknown
        }
        return .disable(shortcut: args[1])
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
            export [file]                 Export replacements as JSON (stdout if omitted)
            import <file>                 Import replacements from JSON file
            search <query>                Search shortcuts/expansions
            enable <shortcut>             Enable a shortcut
            disable <shortcut>            Disable a shortcut
            help                          Show this help message
        
        Examples:
            keymap add x.oc "npm install v24.14.0"
            keymap remove x.oc
            keymap update x.oc "npm install v24.15.0"
            keymap list
            keymap export > backups.json
            keymap import backups.json
            keymap search npm
            keymap disable x.oc
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

    private static func printExportUsage() {
        print("Usage: keymap export [file]")
        print("Example: keymap export > backup.json")
    }

    private static func printImportUsage() {
        print("Usage: keymap import <file>")
        print("Example: keymap import backup.json")
    }

    private static func printSearchUsage() {
        print("Usage: keymap search <query>")
        print("Example: keymap search nemo")
    }

    private static func printEnableUsage() {
        print("Usage: keymap enable <shortcut>")
        print("Example: keymap enable x.oc")
    }

    private static func printDisableUsage() {
        print("Usage: keymap disable <shortcut>")
        print("Example: keymap disable x.oc")
    }
}