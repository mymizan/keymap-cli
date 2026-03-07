// OutputFormatter.swift - Formats output for CLI display

import Foundation

class OutputFormatter {
    
    // ANSI color codes for terminal output
    enum Color: String {
        case reset = "\u{001B}[0m"
        case bold = "\u{001B}[1m"
        case dim = "\u{001B}[2m"
        case cyan = "\u{001B}[36m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case red = "\u{001B}[31m"
    }
    
    // Check if terminal supports colors
    private static var supportsColor: Bool {
        let termType = ProcessInfo.processInfo.environment["TERM"] ?? ""
        return !termType.isEmpty && termType != "dumb"
    }
    
    /// Format a list of replacements for display
    static func formatList(_ items: [ReplacementItem]) -> String {
        guard !items.isEmpty else {
            return "No text replacements found."
        }
        
        return formatTable(items)
    }
    
    /// Format as a table with headers and separators
    private static func formatTable(_ items: [ReplacementItem]) -> String {
        // Calculate column widths
        let maxShortcutLength = items.map { $0.shortcut.count }.max() ?? 0
        let maxExpansionLength = items.map { $0.expansion.count }.max() ?? 0
        
        let shortcutColumnWidth = max(maxShortcutLength, 8) // "shortcut" is 8 chars
        let expansionColumnWidth = max(maxExpansionLength, 9) // "expansion" is 9 chars
        
        var output = ""
        
        // Header with styling
        let headerColor = supportsColor ? Color.bold.rawValue : ""
        let resetColor = supportsColor ? Color.reset.rawValue : ""
        
        output += headerColor
        output += "shortcut"
        output += String(repeating: " ", count: shortcutColumnWidth - "shortcut".count + 2)
        output += "expansion"
        output += resetColor + "\n"
        
        // Separator line
        let separatorLength = shortcutColumnWidth + 2 + expansionColumnWidth
        output += String(repeating: "-", count: separatorLength) + "\n"
        
        // Items
        for item in items.sorted(by: { $0.shortcut < $1.shortcut }) {
            let statusColor = item.enabled ? (supportsColor ? Color.green.rawValue : "") : (supportsColor ? Color.dim.rawValue : "")
            let resetColor = supportsColor ? Color.reset.rawValue : ""
            
            output += statusColor
            output += item.shortcut
            output += String(repeating: " ", count: shortcutColumnWidth - item.shortcut.count + 2)
            output += item.expansion
            output += resetColor + "\n"
        }
        
        return output.trimmingCharacters(in: .newlines)
    }
    
    /// Format with JSON output
    static func formatJSON(_ items: [ReplacementItem]) -> String {
        let dicts = items.map { item in
            return [
                "shortcut": item.shortcut,
                "expansion": item.expansion,
                "enabled": item.enabled
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(
            withJSONObject: dicts,
            options: [.prettyPrinted, .sortedKeys]
        ) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        
        return "[]"
    }
    
    /// Format summary statistics
    static func formatSummary(_ items: [ReplacementItem]) -> String {
        let total = items.count
        let enabled = items.filter { $0.enabled }.count
        let disabled = total - enabled
        
        var output = "Summary:\n"
        output += "  Total replacements: \(total)\n"
        output += "  Enabled: \(enabled)\n"
        output += "  Disabled: \(disabled)"
        
        return output
    }
    
    /// Format error message with color
    static func formatError(_ message: String) -> String {
        if supportsColor {
            return "\(Color.red.rawValue)\(message)\(Color.reset.rawValue)"
        }
        return message
    }
    
    /// Format success message with color
    static func formatSuccess(_ message: String) -> String {
        if supportsColor {
            return "\(Color.green.rawValue)✓ \(message)\(Color.reset.rawValue)"
        }
        return "✓ \(message)"
    }
    
    /// Format warning message with color
    static func formatWarning(_ message: String) -> String {
        if supportsColor {
            return "\(Color.yellow.rawValue)⚠ \(message)\(Color.reset.rawValue)"
        }
        return "⚠ \(message)"
    }
}