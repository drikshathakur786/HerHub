//
//  UserController.swift
//  HerHub
//
//  Created by Dhruv on 10/11/25
//
//  Controller for User CRUD operations using Supabase


import Foundation

// Controller for User CRUD operations using Supabase
final class UserController {
    
    static let shared = UserController()
    
    private let supabaseService = SupabaseService.shared
    private let storage = JsonStorageManager.shared // Keep for offline fallback
    private let fileName = "users"
    
    // Flag to determine if using Supabase or local storage
    private var useSupabase: Bool {
        return SupabaseManager.shared.isAuthenticated
    }
    
    private init() {
        // Initialize with test user if no users exist (for local fallback)
        initializeTestUserIfNeeded()
    }
    
    // MARK: - Create User
    
    func createUser(_ user: User) async throws {
        if useSupabase {
            try await supabaseService.createUser(user)
            print("[UserController] Created user in Supabase: \(user.id)")
        } else {
            // Fallback to local storage
            var users: [User] = (try? storage.load(from: fileName)) ?? []
            
            // Check if user already exists (by id or email)
            if users.contains(where: { $0.id == user.id || $0.email == user.email }) {
                throw NSError(domain: "UserController", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "User already exists"])
            }
            
            users.append(user)
            try storage.save(users, to: fileName)
            print("[UserController] Created user locally: \(user.id)")
        }
    }
    
   
    // MARK: - Fetch User by ID
    
    func fetchUser(byID id: UUID) async throws -> User? {
        if useSupabase {
            let user = try await supabaseService.fetchUser(byID: id)
            print("[UserController] Fetched user from Supabase: \(id)")
            return user
        } else {
            let users: [User] = try storage.load(from: fileName)
            return users.first { $0.id == id }
        }
    }
    
    // MARK: - Fetch User by Email
    
    func fetchUserByEmail(_ email: String) async throws -> User? {
        if useSupabase {
            let user = try await supabaseService.fetchUserByEmail(email)
            print("[UserController] Fetched user by email from Supabase: \(email)")
            return user
        } else {
            let users: [User] = try storage.load(from: fileName)
            return users.first { $0.email?.lowercased() == email.lowercased() }
        }
    }
    
    // MARK: - Fetch All Users
    
    func fetchAllUsers() async throws -> [User] {
        if useSupabase {
            let users: [User] = try await supabaseService.fetchAll(from: SupabaseManager.Tables.users)
            print("[UserController] Fetched all users from Supabase: \(users.count) users")
            return users
        } else {
            return try storage.load(from: fileName)
        }
    }
    
    // MARK: - Update User
    
    func updateUser(_ user: User) async throws {
        if useSupabase {
            try await supabaseService.updateUser(user)
            print("[UserController] Updated user in Supabase: \(user.id)")
        } else {
            var users: [User] = try storage.load(from: fileName)
            
            guard let index = users.firstIndex(where: { $0.id == user.id }) else {
                throw NSError(domain: "UserController", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            users[index] = user
            try storage.save(users, to: fileName)
            print("[UserController] Updated user locally: \(user.id)")
        }
    }
    
    // MARK: - Delete User
    
    func deleteUser(byID id: UUID) async throws {
        if useSupabase {
            try await supabaseService.deleteUser(id: id)
            print("[UserController] Deleted user from Supabase: \(id)")
        } else {
            var users: [User] = try storage.load(from: fileName)
            users.removeAll { $0.id == id }
            try storage.save(users, to: fileName)
            print("[UserController] Deleted user locally: \(id)")
        }
    }
    
    // MARK: - Login (validate user by ID + password)
    
    func loginUser(userID: UUID, password: String) async throws -> User? {
        guard let user = try await fetchUser(byID: userID) else { return nil }
        // Note: Password validation is handled by Supabase Auth
        return user
    }
    

    
    private func initializeTestUserIfNeeded() {
        // Only initialize test user for local storage fallback
        if useSupabase {
            print("[UserController] Using Supabase - skipping local test user initialization")
            return
        }
        
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
