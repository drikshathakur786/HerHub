//
//  UserController.swift
//  HerHub
//
//  Created by Dhruv on 10/11/25.


import Foundation

// Controller for User CRUD operations using local JSON storage
final class UserController {
    
    static let shared = UserController()
    
    private let storage = JsonStorageManager.shared
    private let fileName = "users"
    
    private init() {
        // Initialize with test user if no users exist
        initializeTestUserIfNeeded()
    }
    
    // MARK: - Create User
    
    func createUser(_ user: User) async throws {
        var users: [User] = (try? storage.load(from: fileName)) ?? []
        
        // Check if user already exists (by id or email)
        if users.contains(where: { $0.id == user.id || $0.email == user.email }) {
            throw NSError(domain: "UserController", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User already exists"])
        }
        
        users.append(user)
        try storage.save(users, to: fileName)
    }
    
   
    // MARK: - Fetch User by ID
    
    func fetchUser(byID id: UUID) async throws -> User? {
        let users: [User] = try storage.load(from: fileName)
        return users.first { $0.id == id }
    }
    
    // MARK: - Fetch User by Email
    
    func fetchUserByEmail(_ email: String) async throws -> User? {
        let users: [User] = try storage.load(from: fileName)
        return users.first { $0.email?.lowercased() == email.lowercased() }
    }
    
    // MARK: - Fetch All Users
    
    func fetchAllUsers() async throws -> [User] {
        return try storage.load(from: fileName)
    }
    
    // MARK: - Update User
    
    func updateUser(_ user: User) async throws {
        var users: [User] = try storage.load(from: fileName)
        
        guard let index = users.firstIndex(where: { $0.id == user.id }) else {
            throw NSError(domain: "UserController", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        users[index] = user
        try storage.save(users, to: fileName)
    }
    
    // MARK: - Delete User
    
    func deleteUser(byID id: UUID) async throws {
        var users: [User] = try storage.load(from: fileName)
        users.removeAll { $0.id == id }
        try storage.save(users, to: fileName)
    }
    
    // MARK: - Login (validate user by ID + password)
    
    func loginUser(userID: UUID, password: String) async throws -> User? {
        guard let user = try await fetchUser(byID: userID) else { return nil }
        return user.password == password ? user : nil
    }
    

    
    private func initializeTestUserIfNeeded() {
        if storage.exists(fileName: fileName) {
            print("[UserController] Users file exists")
            return
        }
        
        print("[UserController] Initializing test user...")
        
        let testUser = User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            email: "test@herhub.com",
            phoneNumber: nil,
            password: "password123",
            userName: "Test User",
            userPicture: nil,
            baselineProfile: nil,
            recentCheckIns: nil,
            latestPrediction: nil
        )
        
        try? storage.save([testUser], to: fileName)
        print("[UserController] Test user created: test@herhub.com")
    }
}
