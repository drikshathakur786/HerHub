//
//  SupabaseService.swift
//  HerHub
//
//  Service layer for Supabase database operations
//

import Foundation
import Supabase

/// Service class for Supabase database operations
final class SupabaseService {
    
    // MARK: - Singleton
    static let shared = SupabaseService()
    
    private let manager = SupabaseManager.shared
    private let client: SupabaseClient
    
    private init() {
        client = manager.client
    }
    
    // MARK: - Generic CRUD Operations
    
    /// Fetch all records from a table
    func fetchAll<T: Codable>(from table: String) async throws -> [T] {
        let response: [T] = try await client
            .from(table)
            .select()
            .execute()
            .value
        return response
    }
    
    /// Fetch a single record by ID
    func fetchByID<T: Codable>(id: UUID, from table: String) async throws -> T? {
        let response: [T] = try await client
            .from(table)
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    /// Insert a new record
    func insert<T: Codable>(_ record: T, into table: String) async throws {
        _ = try await client
            .from(table)
            .insert(record)
            .execute()
    }
    
    /// Update a record by ID
    func update<T: Codable>(id: UUID, record: T, in table: String) async throws {
        _ = try await client
            .from(table)
            .update(record)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    /// Delete a record by ID
    func delete(id: UUID, from table: String) async throws {
        _ = try await client
            .from(table)
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - User Operations
    
    /// Fetch user by email
    func fetchUserByEmail(_ email: String) async throws -> User? {
        let response: [User] = try await client
            .from(SupabaseManager.Tables.users)
            .select()
            .ilike("email", pattern: email)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    /// Fetch user by ID
    func fetchUser(byID id: UUID) async throws -> User? {
        return try await fetchByID(id: id, from: SupabaseManager.Tables.users)
    }
    
    /// Create a new user
    func createUser(_ user: User) async throws {
        try await insert(user, into: SupabaseManager.Tables.users)
    }
    
    /// Update an existing user
    func updateUser(_ user: User) async throws {
        let id = user.id
        try await update(id: id, record: user, in: SupabaseManager.Tables.users)
    }
    
    /// Delete a user
    func deleteUser(id: UUID) async throws {
        try await delete(id: id, from: SupabaseManager.Tables.users)
    }
    
    /// Delete the currently authenticated user's account by calling the Supabase RPC
    func deleteAccount() async throws {
        _ = try await client.rpc("delete_user").execute()
    }
    
    // MARK: - Community Operations
    
    /// Fetch all communities with their posts and comments reassembled
    func fetchAllCommunities() async throws -> [Community] {
        // 1. Fetch flat community records
        let dbCommunities: [CommunityForDB] = try await fetchAll(from: SupabaseManager.Tables.communities)
        
        // 2. Fetch all posts
        let dbPosts: [PostForDB] = try await fetchAll(from: SupabaseManager.Tables.posts)
        
        // 3. Fetch all comments
        let dbComments: [CommentForDB] = try await fetchAll(from: SupabaseManager.Tables.comments)
        
        // 4. Reassemble: comments -> posts -> communities
        var assembledCommunities: [Community] = []
        
        for dbCom in dbCommunities {
            var community = Community(name: dbCom.name, description: dbCom.description, themeColor: dbCom.themeColor, iconName: dbCom.iconName, isFeatured: dbCom.isFeatured, createdBy: dbCom.createdBy)
            // Overwrite generated id/createdAt with DB values
            community = Community(id: dbCom.id, name: dbCom.name, description: dbCom.description, themeColor: dbCom.themeColor, iconName: dbCom.iconName, isFeatured: dbCom.isFeatured, createdBy: dbCom.createdBy, posts: [], members: dbCom.members, createdAt: dbCom.createdAt)
            
            // Find posts belonging to this community
            let communityPosts = dbPosts.filter { $0.communityID == dbCom.id }
            for dbPost in communityPosts {
                let postComments = dbComments.filter { $0.postID == dbPost.id }.map { dbComment in
                    Comment(id: dbComment.id, postID: dbComment.postID, parentCommentID: dbComment.parentCommentID, authorID: dbComment.authorID, authorName: dbComment.authorName, text: dbComment.text, createdAt: dbComment.createdAt, likedBy: dbComment.likedBy)
                }
                let post = Post(id: dbPost.id, communityID: dbPost.communityID, authorID: dbPost.authorID, authorName: dbPost.authorName, title: dbPost.title, text: dbPost.text, imageURL: dbPost.imageURL, likedBy: dbPost.likedBy, comments: postComments, createdAt: dbPost.createdAt)
                community.posts.append(post)
            }
            
            assembledCommunities.append(community)
        }
        
        return assembledCommunities
    }
    
    /// Fetch community by ID
    func fetchCommunity(byID id: UUID) async throws -> Community? {
        return try await fetchByID(id: id, from: SupabaseManager.Tables.communities)
    }
    
    /// Create a new community (DB-safe, no nested posts)
    func createCommunity(_ community: Community) async throws {
        let dbRecord = CommunityForDB(from: community)
        try await insert(dbRecord, into: SupabaseManager.Tables.communities)
    }
    
    /// Update a community (DB-safe, no nested posts)
    func updateCommunity(_ community: Community) async throws {
        let dbRecord = CommunityForDB(from: community)
        try await update(id: community.id, record: dbRecord, in: SupabaseManager.Tables.communities)
    }
    
    /// Delete a community
    func deleteCommunity(_ community: Community) async throws {
        try await delete(id: community.id, from: SupabaseManager.Tables.communities)
    }
    
    /// Join a community
    func joinCommunity(communityID: UUID, userID: UUID) async throws {
        // This would typically use a junction table or array update
        // Implementation depends on your database schema
        let rpcParams = [
            "community_id": communityID.uuidString,
            "user_id": userID.uuidString
        ]
        _ = try await client.rpc("join_community", params: rpcParams).execute()
    }
    
    // MARK: - Post Operations
    
    /// Fetch posts for a community
    func fetchPosts(forCommunity communityID: UUID) async throws -> [Post] {
        let response: [Post] = try await client
            .from(SupabaseManager.Tables.posts)
            .select()
            .eq("community_id", value: communityID.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    /// Create a new post (DB-safe, no nested comments)
    func createPost(_ post: Post) async throws {
        let dbRecord = PostForDB(from: post)
        try await insert(dbRecord, into: SupabaseManager.Tables.posts)
    }
    
    /// Delete a post
    func deletePost(postID: UUID) async throws {
        try await delete(id: postID, from: SupabaseManager.Tables.posts)
    }
    
    /// Toggle like on a post
    func togglePostLike(postID: UUID, userID: UUID) async throws -> Bool {
        let rpcParams = [
            "post_id": postID.uuidString,
            "user_id": userID.uuidString
        ]
        let response: [String: Bool] = try await client.rpc("toggle_post_like", params: rpcParams).execute().value
        return response["liked"] ?? false
    }
    
    /// Create a report for a post (DB-safe)
    func createReport(_ report: Report) async throws {
        let dbRecord = ReportForDB(from: report)
        try await insert(dbRecord, into: SupabaseManager.Tables.reports)
    }
    
    // MARK: - Comment Operations
    
    /// Fetch comments for a post
    func fetchComments(forPost postID: UUID) async throws -> [Comment] {
        let response: [Comment] = try await client
            .from(SupabaseManager.Tables.comments)
            .select()
            .eq("post_id", value: postID.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
        return response
    }
    
    /// Create a comment (DB-safe)
    func createComment(_ comment: Comment) async throws {
        let dbRecord = CommentForDB(from: comment)
        try await insert(dbRecord, into: SupabaseManager.Tables.comments)
    }
    
    /// Delete a comment
    func deleteComment(commentID: UUID) async throws {
        try await delete(id: commentID, from: SupabaseManager.Tables.comments)
    }
    
    // MARK: - Cycle Data Operations
    
    /// Fetch cycle check-ins for a user
    func fetchCycleCheckIns(forUser userID: UUID) async throws -> [CycleCheckIn] {
        let response: [CycleCheckIn] = try await client
            .from(SupabaseManager.Tables.cycleCheckIns)
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("date", ascending: false)
            .limit(30)
            .execute()
            .value
        return response
    }
    
    /// Create a cycle check-in
    func createCycleCheckIn(_ checkIn: CycleCheckIn) async throws {
        try await insert(checkIn, into: SupabaseManager.Tables.cycleCheckIns)
    }
    
    /// Fetch latest prediction for a user
    func fetchLatestPrediction(forUser userID: UUID) async throws -> CyclePrediction? {
        let response: [CyclePrediction] = try await client
            .from(SupabaseManager.Tables.cyclePredictions)
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return response.first
    }
    
    /// Save a cycle prediction
    func savePrediction(_ prediction: CyclePrediction) async throws {
        try await insert(prediction, into: SupabaseManager.Tables.cyclePredictions)
    }
    
    // MARK: - Storage Operations
    
    /// Upload an image to storage
    func uploadImage(data: Data, fileName: String, bucket: String) async throws -> String {
        let filePath = "\(fileName)"
        _ = try await client.storage
            .from(bucket)
            .upload(filePath, data: data)
        
        // Return the public URL
        let publicURL = try client.storage
            .from(bucket)
            .getPublicURL(path: filePath)
        return publicURL.absoluteString
    }
    
    /// Download an image from storage
    func downloadImage(path: String, bucket: String) async throws -> Data {
        return try await client.storage
            .from(bucket)
            .download(path: path)
    }
    
    /// Delete an image from storage
    func deleteImage(path: String, bucket: String) async throws {
        _ = try await client.storage
            .from(bucket)
            .remove(paths: [path])
    }
}

