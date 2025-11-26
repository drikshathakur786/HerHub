//
//  UserController.swift
//  HerHub
//
//  Created by Dhruv on 11/11/25.
//

import Foundation

final class UserController {
    
    static let shared = UserController()
    private let manager = UserDataManager()
    private init() {}
    
    // MARK: - Create New User
    func registerUser(_ user: User) async throws {
        try await manager.createUser(user)
    }
    
    // MARK: - Login / Fetch by Email
    func loginUser(email: String, password: String) async throws -> User? {
        guard let user = try await manager.fetchUser(byEmail: email) else { return nil }
        return user.password == password ? user : nil
    }
    
    // MARK: - Fetch User by Email (Debug - No password required)
    func fetchUser(byEmail email: String) async throws -> User? {
        return try await manager.fetchUser(byEmail: email)
    }
    
    // MARK: - Fetch All Users (Admin / Debug)
    func getAllUsers() async throws -> [User] {
        try await manager.fetchAllUsers()
    }
    
    // MARK: - Update User (for profile edits)
    func updateUser(_ user: User) async throws {
        try await manager.updateUser(user)
    }
    
    // MARK: - Update User's Latest Prediction (stored in latest_prediction JSONB field)
    func updateUserPrediction(_ prediction: CyclePrediction, forUser userID: UUID) async throws {
        // Fetch current user
        guard var user = try await manager.fetchUser(byID: userID) else {
            throw NSError(domain: "UserController", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        // Update prediction
        user.latestPrediction = prediction
        // Save updated user
        try await manager.updateUser(user)
    }
    
    // MARK: - Delete User
    func deleteUser(byID id: UUID) async throws {
        try await manager.deleteUser(byID: id)
    }
}
