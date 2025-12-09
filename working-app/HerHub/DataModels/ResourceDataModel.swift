//
//  ResourceManager.swift
//  HerHub
//
//  Created by Mahika Behal on 28/10/25.
//

import Foundation

class ResourceManager {

    // MARK: - Singleton Instance
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

    

    func toggleBookmark(for id: UUID) {
        if let index = resources.firstIndex(where: { $0.id == id }) {
            resources[index].isBookmarked.toggle()
            saveResources()
        }
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


    private func loadResources() {

        // 1. Load saved data from Documents folder
        if let savedData = loadResourcesFromDisk() {
            resources = savedData
            return
        }

        // 2. Load bundled sample JSON on first launch
        if let sampleData = loadSampleResourcesFromJSON() {
            resources = sampleData
            saveResources()
            return
        }

        // 3. Fallback (should never happen)
        resources = []
    }

    
    private func loadResourcesFromDisk() -> [Resource]? {
        guard let codedData = try? Data(contentsOf: archiveURL) else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode([Resource].self, from: codedData)
    }

    //Save Resources
    private func saveResources() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let encodedData = try? encoder.encode(resources) {
            try? encodedData.write(to: archiveURL, options: .noFileProtection)
        }
    }

    //Load Bundled JSON
    private func loadSampleResourcesFromJSON() -> [Resource]? {

        guard let url = Bundle.main.url(forResource: "resources", withExtension: "json") else {
            print("  JSON file not found in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Resource].self, from: data)

        } catch {
            print("  Error decoding JSON: \(error)")
            return nil
        }
    }
}
