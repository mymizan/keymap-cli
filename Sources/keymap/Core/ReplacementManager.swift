// ReplacementManager.swift - Core business logic for managing text replacements

import Foundation

enum ReplacementManagerError: Error, Equatable {
    case shortcutNotFound(String)
    case shortcutAlreadyExists(String)
    case emptyShortcut
    case emptyExpansion
    case alreadyEnabled(String)
    case alreadyDisabled(String)
    case unknown(String)
    
    var description: String {
        switch self {
        case .shortcutNotFound(let shortcut):
            return "Error: Shortcut '\(shortcut)' not found."
        case .shortcutAlreadyExists(let shortcut):
            return "Error: Shortcut '\(shortcut)' already exists. Use update to modify."
        case .emptyShortcut:
            return "Error: Shortcut cannot be empty."
        case .emptyExpansion:
            return "Error: Expansion cannot be empty."
        case .alreadyEnabled(let shortcut):
            return "Error: Shortcut '\(shortcut)' is already enabled."
        case .alreadyDisabled(let shortcut):
            return "Error: Shortcut '\(shortcut)' is already disabled."
        case .unknown(let msg):
            return "Error: \(msg)"
        }
    }
}

class ReplacementManager {
    private var replacements: [ReplacementItem]
    
    /// Initialize with existing replacements or empty array
    init(replacements: [ReplacementItem] = []) {
        self.replacements = replacements
    }
    
    // MARK: - Core Operations
    
    /// Add a new text replacement shortcut
    /// - Parameters:
    ///   - shortcut: The text to be replaced
    ///   - expansion: The replacement text
    /// - Throws: ReplacementManagerError if shortcut already exists
    func addShortcut(_ shortcut: String, expansion: String) throws {
        // Validate input
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard !expansion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyExpansion
        }
        
        // Check for duplicates
        if replacements.contains(where: { $0.shortcut == shortcut }) {
            throw ReplacementManagerError.shortcutAlreadyExists(shortcut)
        }
        
        // Add the new item
        let item = ReplacementItem(shortcut: shortcut, expansion: expansion, enabled: true)
        replacements.append(item)
    }
    
    /// Remove a text replacement by shortcut
    /// - Parameters:
    ///   - shortcut: The shortcut to remove
    /// - Throws: ReplacementManagerError if shortcut not found
    func removeShortcut(_ shortcut: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        
        replacements.remove(at: index)
    }
    
    /// Update an existing text replacement
    /// - Parameters:
    ///   - shortcut: The shortcut to update
    ///   - expansion: The new expansion text
    /// - Throws: ReplacementManagerError if shortcut not found
    func updateShortcut(_ shortcut: String, expansion: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        
        guard !expansion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyExpansion
        }
        
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        
        let updatedItem = ReplacementItem(shortcut: shortcut, expansion: expansion, enabled: replacements[index].enabled)
        replacements[index] = updatedItem
    }
    
    /// List all text replacements
    /// - Returns: Array of all ReplacementItem objects
    func listShortcuts() -> [ReplacementItem] {
        return replacements.sorted { $0.shortcut < $1.shortcut }
    }
    
    /// Get the count of replacements
    func count() -> Int {
        return replacements.count
    }
    
    /// Get a specific replacement by shortcut
    func getReplacement(_ shortcut: String) -> ReplacementItem? {
        return replacements.first { $0.shortcut == shortcut }
    }
    
    /// Get all replacements as array
    func getAll() -> [ReplacementItem] {
        return replacements
    }
    
    // MARK: - Extended Operations (Phase 9)
    
    /// Enable an existing shortcut
    /// - Throws: ReplacementManagerError if not found or already enabled
    func enableShortcut(_ shortcut: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        if replacements[index].enabled {
            throw ReplacementManagerError.alreadyEnabled(shortcut)
        }
        let item = replacements[index]
        replacements[index] = ReplacementItem(shortcut: item.shortcut, expansion: item.expansion, enabled: true)
    }
    
    /// Disable an existing shortcut
    /// - Throws: ReplacementManagerError if not found or already disabled
    func disableShortcut(_ shortcut: String) throws {
        guard !shortcut.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ReplacementManagerError.emptyShortcut
        }
        guard let index = replacements.firstIndex(where: { $0.shortcut == shortcut }) else {
            throw ReplacementManagerError.shortcutNotFound(shortcut)
        }
        if !replacements[index].enabled {
            throw ReplacementManagerError.alreadyDisabled(shortcut)
        }
        let item = replacements[index]
        replacements[index] = ReplacementItem(shortcut: item.shortcut, expansion: item.expansion, enabled: false)
    }
    
    /// Search for replacements matching a query in shortcut or expansion
    func search(_ query: String) -> [ReplacementItem] {
        guard !query.isEmpty else { return [] }
        return replacements.filter { item in
            item.shortcut.localizedCaseInsensitiveContains(query) ||
            item.expansion.localizedCaseInsensitiveContains(query)
        }.sorted { $0.shortcut < $1.shortcut }
    }
    
    /// Import a collection of replacement items, updating existing entries and adding new ones
    /// - Returns: Number of items processed
    func importItems(_ items: [ReplacementItem]) -> Int {
        var count = 0
        for newItem in items {
            if let index = replacements.firstIndex(where: { $0.shortcut == newItem.shortcut }) {
                replacements[index] = newItem
            } else {
                replacements.append(newItem)
            }
            count += 1
        }
        return count
    }
    
    /// Export current replacements (sorted)
    func exportItems() -> [ReplacementItem] {
        return listShortcuts()
    }
}