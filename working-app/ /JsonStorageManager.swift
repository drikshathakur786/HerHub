//
//  JsonStorageManager.swift
//  HerHub



import Foundation


final class JsonStorageManager {
    
    static let shared = JsonStorageManager()
    
    private init() {}
    
    
    private var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func fileURL(for fileName: String) -> URL {
        documentDirectory.appendingPathComponent("\(fileName).json")
    }
    


  
    func save<T: Codable>(_ object: T, to fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // convert the date into a string 
        encoder.outputFormatting = .prettyPrinted // pretty print the json data  in a readable format 
        
        let data = try encoder.encode(object)
        let url = fileURL(for: fileName)
        
        try data.write(to: url, options: [.atomic])
        print(" [JsonStorage] Saved to: \(url.lastPathComponent)")
    }
    
    func load<T: Codable>(from fileName: String) throws -> T {
        let url = fileURL(for: fileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "JsonStorageManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "File '\(fileName).json' not found"]
            )
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let object = try decoder.decode(T.self, from: data)
        print("[JsonStorage] Loaded from: \(url.lastPathComponent)")
        return object
    }
    
    func exists(fileName: String) -> Bool {
        let url = fileURL(for: fileName)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    
    func listAllFiles() -> [String] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "json" }.map { $0.lastPathComponent }
        } catch {
            print(" [JsonStorage] Error listing files: \(error)")
            return []
        }
    }
}
