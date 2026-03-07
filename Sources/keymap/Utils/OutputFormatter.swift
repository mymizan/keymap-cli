// OutputFormatter.swift - Formats output for CLI display

import Foundation

class OutputFormatter {
    
    /// Format a list of replacements for display
    static func formatList(_ items: [ReplacementItem]) -> String {
        guard !items.isEmpty else {
            return "No text replacements found."
        }
        
        // Calculate column widths
        let maxShortcutLength = items.map { $0.shortcut.count }.max() ?? 0
        let shortcutColumnWidth = max(maxShortcutLength, 8) // "shortcut" is 8 chars
        
        var output = ""
        
        // Header
        output += "shortcut"
        output += String(repeating: " ", count: shortcutColumnWidth - "shortcut".count + 2)
        output += "expansion\n"
        
        // Separator
        output += String(repeating: "-", count: shortcutColumnWidth + 2 + 20) + "\n"
        
        // Items
        for item in items.sorted(by: { $0.shortcut < $1.shortcut }) {
            output += item.shortcut
            output += String(repeating: " ", count: shortcutColumnWidth - item.shortcut.count + 2)
            output += item.expansion + "\n"
        }
        
        return output.trimmingCharacters(in: .newlines)
    }
}