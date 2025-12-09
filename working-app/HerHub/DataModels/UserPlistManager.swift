//
//  UserPlistManager.swift
//  HerHub
//
//  Local plist storage for user data (replaces Supabase)
//

import Foundation

/// Manages local plist storage for user data
final class UserPlistManager {
    
    static let shared = UserPlistManager()
    
    private let storage = PlistStorageManager.shared
    private let fileName = "users"
    
    private init() {
        // Initialize with test user if no users exist
        initializeTestUserIfNeeded()
    }
    
    // MARK: - Create User
    
    func createUser(_ user: User) throws {
        var users: [User] = (try? storage.load(from: fileName)) ?? []
        
        // Check if user already exists
        if users.contains(where: { $0.id == user.id || $0.email == user.email }) {
            throw NSError(domain: "UserPlistManager", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User already exists"])
        }
        
        users.append(user)
        try storage.save(users, to: fileName)
    }
    
    // MARK: - Fetch User by Email
    
    func fetchUser(byEmail email: String) throws -> User? {
        let users: [User] = try storage.load(from: fileName)
        return users.first { $0.email?.lowercased() == email.lowercased() }
    }
    
    // MARK: - Fetch User by ID
    
    func fetchUser(byID id: UUID) throws -> User? {
        let users: [User] = try storage.load(from: fileName)
        return users.first { $0.id == id }
    }
    
    // MARK: - Fetch All Users
    
    func fetchAllUsers() throws -> [User] {
        return try storage.load(from: fileName)
    }
    
    // MARK: - Update User
    
    func updateUser(_ user: User) throws {
        var users: [User] = try storage.load(from: fileName)
        
        guard let index = users.firstIndex(where: { $0.id == user.id }) else {
            throw NSError(domain: "UserPlistManager", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        users[index] = user
        try storage.save(users, to: fileName)
    }
    
    // MARK: - Delete User
    
    func deleteUser(byID id: UUID) throws {
        var users: [User] = try storage.load(from: fileName)
        users.removeAll { $0.id == id }
        try storage.save(users, to: fileName)
    }
    
    // MARK: - Test User Initialization
    
    private func initializeTestUserIfNeeded() {
        // Check if users already exist
        if storage.exists(fileName: fileName) {
            print("📁 [UserPlist] User data file already exists, skipping initialization")
            return
        }
        
        print("🌱 [UserPlist] Initializing test user...")
        
        // Create test user with fixed UUID (matches CycleDataPlistManager)
        let testUser = User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            email: "test@herhub.com",
            phoneNumber: nil,
            password: "password123",
            userName: "Test User",
            userPicture: nil,
            baselineProfile: nil,
            recentCheckIns: nil,
            latestPrediction: CyclePrediction.sample()
        )
        
        try? storage.save([testUser], to: fileName)
        print("✅ [UserPlist] Test user initialized: test@herhub.com")
    }
}
