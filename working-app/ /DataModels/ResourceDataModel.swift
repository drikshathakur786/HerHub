//
//  ResourceManager.swift
//  HerHub
//
//  Created by Mahika Behal on 28/10/25.
//

import Foundation

class ResourceManager {

    static let shared = ResourceManager()

    private let documentsDirectory: URL
    private let archiveURL: URL

    private var resources: [Resource] = []

    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory
            .appendingPathComponent("Resources")
            .appendingPathExtension("json")

        loadResources()
    }

    
    func getAllResources() -> [Resource] {
        return resources
    }

    func getResource(by id: UUID) -> Resource? {
        return resources.first(where: { $0.id == id })
    }

    func addResource(_ resource: Resource) {
        resources.append(resource)
        saveResources()
    }

    func updateResource(_ resource: Resource) {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            resources[index] = resource
            saveResources()
        }
    }

    func deleteResource(at index: Int) {
        resources.remove(at: index)
        saveResources()
    }

    
    func toggleBookmark(resourceId: UUID, userId: UUID) {
        guard let index = resources.firstIndex(where: { $0.id == resourceId }) else { return }

        // Toggle bookmark: Add user if not bookmarked, remove if already bookmarked
        if let position = resources[index].bookmarkedBy.firstIndex(of: userId) {
            resources[index].bookmarkedBy.remove(at: position)  // Unbookmark
        } else {
            resources[index].bookmarkedBy.append(userId)        // Bookmark
        }

        saveResources()
    }

    func toggleLike(resourceId: UUID, userId: UUID) {
        guard let index = resources.firstIndex(where: { $0.id == resourceId }) else { return }

        // Create liked array if nil
        if resources[index].isLiked == nil {
            resources[index].isLiked = []
        }

        // Like / Unlike
        if let position = resources[index].isLiked?.firstIndex(of: userId) {
            resources[index].isLiked?.remove(at: position)      // Unlike
        } else {
            resources[index].isLiked?.append(userId)            // Like
        }

        saveResources()
    }
    
    // MARK: - Helper Methods
    func hasUserBookmarked(resourceId: UUID, userId: UUID) -> Bool {
        guard let resource = getResource(by: resourceId) else { return false }
        return resource.bookmarkedBy.contains(userId)
    }
    
    func hasUserLiked(resourceId: UUID, userId: UUID) -> Bool {
        guard let resource = getResource(by: resourceId) else { return false }
        return resource.isLiked?.contains(userId) ?? false
    }

//
//    private func loadResources() {
//
//        // 1. Load saved data from Documents folder
//        if let savedData = loadResourcesFromDisk() {
//            resources = savedData
//            return
//        }
//
//        // 2. Load bundled sample JSON on first launch
//        if let sampleData = loadSampleResourcesFromJSON() {
//            resources = sampleData
//            saveResources()
//            return
//        }
//
//        // 3. Fallback (should never happen)
//        resources = []
//    }
    private func loadResources() {

        // 1️⃣ Try loading saved JSON from Documents FIRST
        if let savedData = loadResourcesFromDisk() {
            print("✔ Loaded saved JSON from Documents")
            resources = savedData
            return
        }

        // 2️⃣ If not found → load bundled JSON  
        if let sampleData = loadSampleResourcesFromJSON() {
            print("✔ Loaded bundled JSON")
            resources = sampleData
            saveResources()
            return
        }

        print("[ResourceManager] Error: No JSON loaded")
        resources = []
    }



    
    private func loadResourcesFromDisk() -> [Resource]? {
        guard let codedData = try? Data(contentsOf: archiveURL) else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode([Resource].self, from: codedData)
    }

    
    private func saveResources() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let encodedData = try? encoder.encode(resources) {
            try? encodedData.write(to: archiveURL, options: .noFileProtection)
        }
    }

    
    private func loadSampleResourcesFromJSON() -> [Resource]? {

        guard let url = Bundle.main.url(forResource: "resources", withExtension: "json") else {
            print("[ResourceManager] Error: JSON file not found in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Resource].self, from: data)

        } catch {
            print("[ResourceManager] Error decoding JSON: \(error)")
            return nil
        }
    }
}
