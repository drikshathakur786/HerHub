//
//  PlistStorageManager.swift
//  HerHub
//
//  Generic plist storage helper for local data persistence
//

import Foundation

/// Generic manager for reading/writing Codable objects to plist files
final class PlistStorageManager {
    
    static let shared = PlistStorageManager()
    
    private init() {}
    
    // MARK: - File Paths
    
    /// Returns the URL for a plist file in the Documents directory
    private func fileURL(for fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("\(fileName).plist")
    }
    
    // MARK: - Save
    
    /// Saves an array of Codable objects to a plist file
    func save<T: Codable>(_ items: [T], to fileName: String) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(items)
        try data.write(to: fileURL(for: fileName))
        print("✅ [Plist] Saved \(items.count) items to \(fileName).plist")
    }
    
    /// Saves a single Codable object to a plist file (wraps in array)
    func save<T: Codable>(_ item: T, to fileName: String) throws {
        try save([item], to: fileName)
    }
    
    // MARK: - Load
    
    /// Loads an array of Codable objects from a plist file
    func load<T: Codable>(from fileName: String) throws -> [T] {
        let url = fileURL(for: fileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("📁 [Plist] File \(fileName).plist does not exist, returning empty array")
            return []
        }
        
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let items = try decoder.decode([T].self, from: data)
        print("✅ [Plist] Loaded \(items.count) items from \(fileName).plist")
        return items
    }
    
    /// Loads a single Codable object from a plist file (first item in array)
    func loadFirst<T: Codable>(from fileName: String) throws -> T? {
        let items: [T] = try load(from: fileName)
        return items.first
    }
    
    // MARK: - Append
    
    /// Appends a new item to an existing plist file
    func append<T: Codable & Equatable>(_ item: T, to fileName: String) throws {
        var items: [T] = try load(from: fileName)
        items.append(item)
        try save(items, to: fileName)
    }
    
    // MARK: - Delete
    
    /// Deletes a plist file
    func delete(fileName: String) throws {
        let url = fileURL(for: fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            print("🗑️ [Plist] Deleted \(fileName).plist")
        }
    }
    
    /// Checks if a plist file exists
    func exists(fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: fileURL(for: fileName).path)
    }
}
