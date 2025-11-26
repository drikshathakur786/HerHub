//
//  UserDataManager.swift
//  HerHub
//
//  Created by Dhruv on 11/11/25.
//

import Foundation
import Supabase

// MARK: - Private Data Manager
 class UserDataManager {
    
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    // MARK: - Create User
    func createUser(_ user: User) async throws {
        _ = try await client
            .from("users")
            .insert(user)
            .execute()
    }
    
    // MARK: - Fetch User by Email
    func fetchUser(byEmail email: String) async throws -> User? {
        let response: PostgrestResponse<[User]> = try await client
            .from("users")
            .select()
            .eq("email", value: email)
            .execute()
        return response.value.first
    }
    
    // MARK: - Fetch User by ID
    func fetchUser(byID id: UUID) async throws -> User? {
        let response: PostgrestResponse<[User]> = try await client
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
        return response.value.first
    }
    
    // MARK: - Fetch All Users
    func fetchAllUsers() async throws -> [User] {
        let response: PostgrestResponse<[User]> = try await client
            .from("users")
            .select()
            .execute()
        return response.value
    }
    
    // MARK: - Update User
    func updateUser(_ user: User) async throws {
        _ = try await client
            .from("users")
            .update(user)
            .eq("id", value: user.id.uuidString)
            .execute()
    }
    
    // MARK: - Delete User
    func deleteUser(byID id: UUID) async throws {
        _ = try await client
            .from("users")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
