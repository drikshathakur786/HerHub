//
//  JsonStorageManager.swift
//  HerHub
//
//  JSON storage helper for local data persistence in Models folder
//

import Foundation

/// Generic manager for reading/writing Codable objects to JSON files in the Models folder
final class JsonStorageManager {
    
    static let shared = JsonStorageManager()
    
    private init() {
        // Create data folder if it doesn't exist
        createDataFolderIfNeeded()
    }
    
    // MARK: - File Paths
    
    /// Returns the URL for the data folder inside Documents/HerHubData
    private var dataFolderURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("HerHubData", isDirectory: true)
    }
    
    /// Returns the URL for a JSON file in the data folder
    private func fileURL(for fileName: String) -> URL {
        return dataFolderURL.appendingPathComponent("\(fileName).json")
    }
    
    /// Creates the data folder if it doesn't exist
    private func createDataFolderIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dataFolderURL.path) {
            do {
                try fileManager.createDirectory(at: dataFolderURL, withIntermediateDirectories: true)
                print("📁 [JSON] Created data folder: \(dataFolderURL.path)")
            } catch {
                print("❌ [JSON] Failed to create data folder: \(error)")
            }
        }
    }
    
    // MARK: - Save
    
    /// Saves an array of Codable objects to a JSON file
    func save<T: Codable>(_ items: [T], to fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(items)
        try data.write(to: fileURL(for: fileName))
        print("✅ [JSON] Saved \(items.count) items to \(fileName).json")
        print("📁 [JSON] Path: \(fileURL(for: fileName).path)")
    }
    
    /// Saves a single Codable object to a JSON file (wraps in array)
    func save<T: Codable>(_ item: T, to fileName: String) throws {
        try save([item], to: fileName)
    }
    
    // MARK: - Load
    
    /// Loads an array of Codable objects from a JSON file
    func load<T: Codable>(from fileName: String) throws -> [T] {
        let url = fileURL(for: fileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("📁 [JSON] File \(fileName).json does not exist, returning empty array")
            return []
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let items = try decoder.decode([T].self, from: data)
        print("✅ [JSON] Loaded \(items.count) items from \(fileName).json")
        return items
    }
    
    /// Loads a single Codable object from a JSON file (first item in array)
    func loadFirst<T: Codable>(from fileName: String) throws -> T? {
        let items: [T] = try load(from: fileName)
        return items.first
    }
    
    // MARK: - Append
    
    /// Appends a new item to an existing JSON file
    func append<T: Codable & Equatable>(_ item: T, to fileName: String) throws {
        var items: [T] = try load(from: fileName)
        items.append(item)
        try save(items, to: fileName)
    }
    
    // MARK: - Delete
    
    /// Deletes a JSON file
    func delete(fileName: String) throws {
        let url = fileURL(for: fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            print("🗑️ [JSON] Deleted \(fileName).json")
        }
    }
    
    /// Checks if a JSON file exists
    func exists(fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: fileURL(for: fileName).path)
    }
    
    /// Returns the full path to the data folder (for debugging)
    func getDataFolderPath() -> String {
        return dataFolderURL.path
    }
}
