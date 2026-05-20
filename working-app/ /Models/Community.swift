//
//  Community.swift
//  HerHub
//
//  Created by Driksha Thakur on 11/11/25.
//

import Foundation

// MARK: - DB-safe structs for Supabase (no nested arrays)

/// Community record for Supabase — excludes `posts` (stored in separate table)
struct CommunityForDB: Codable {
    let id: UUID
    var name: String
    var description: String
    var themeColor: String
    var isFeatured: Bool
    var createdBy: UUID
    var members: [UUID]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case themeColor = "theme_color"
        case isFeatured = "is_featured"
        case createdBy = "created_by"
        case members
        case createdAt = "created_at"
    }
    
    init(from community: Community) {
        self.id = community.id
        self.name = community.name
        self.description = community.description
        self.themeColor = community.themeColor
        self.isFeatured = community.isFeatured
        self.createdBy = community.createdBy
        self.members = community.members
        self.createdAt = community.createdAt
    }
}

/// Post record for Supabase — excludes `comments` (stored in separate table)
struct PostForDB: Codable {
    let id: UUID
    var communityID: UUID
    var authorID: UUID
    var authorName: String
    var title: String
    var text: String
    var imageURL: String?
    var likedBy: [UUID]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case communityID = "community_id"
        case authorID = "author_id"
        case authorName = "author_name"
        case title, text
        case imageURL = "image_url"
        case likedBy = "liked_by"
        case createdAt = "created_at"
    }
    
    init(from post: Post) {
        self.id = post.id
        self.communityID = post.communityID
        self.authorID = post.authorID
        self.authorName = post.authorName
        self.title = post.title
        self.text = post.text
        self.imageURL = post.imageURL
        self.likedBy = post.likedBy
        self.createdAt = post.createdAt
    }
}

/// Comment record for Supabase
struct CommentForDB: Codable {
    let id: UUID
    var postID: UUID
    var parentCommentID: UUID?
    var authorID: UUID
    var authorName: String
    var text: String
    var createdAt: Date
    var likedBy: [UUID]

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case parentCommentID = "parent_comment_id"
        case authorID = "author_id"
        case authorName = "author_name"
        case text
        case createdAt = "created_at"
        case likedBy = "liked_by"
    }
    
    init(from comment: Comment) {
        self.id = comment.id
        self.postID = comment.postID
        self.parentCommentID = comment.parentCommentID
        self.authorID = comment.authorID
        self.authorName = comment.authorName
        self.text = comment.text
        self.createdAt = comment.createdAt
        self.likedBy = comment.likedBy
    }
}

/// Report record for Supabase
struct ReportForDB: Codable {
    let id: UUID
    var postID: UUID
    var communityID: UUID
    var reporterID: UUID
    var reason: String
    var notes: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case communityID = "community_id"
        case reporterID = "reporter_id"
        case reason, notes
        case createdAt = "created_at"
    }
    
    init(from report: Report) {
        self.id = report.id
        self.postID = report.postID
        self.communityID = report.communityID
        self.reporterID = report.reporterID
        self.reason = report.reason
        self.notes = report.notes
        self.createdAt = report.createdAt
    }
}

// MARK: - App models (used locally, keep camelCase for local JSON compatibility)

struct Community: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var themeColor: String
    var isFeatured: Bool
    var createdBy: UUID
    var posts: [Post]
    var members: [UUID]
    var createdAt: Date

    init(name: String, description: String, themeColor: String, isFeatured: Bool = false, createdBy: UUID) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.themeColor = themeColor
        self.isFeatured = isFeatured
        self.createdBy = createdBy
        self.posts = []
        self.members = []
        self.createdAt = Date()
    }
    
    /// Full memberwise init for reassembling from DB
    init(id: UUID, name: String, description: String, themeColor: String, isFeatured: Bool, createdBy: UUID, posts: [Post], members: [UUID], createdAt: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.themeColor = themeColor
        self.isFeatured = isFeatured
        self.createdBy = createdBy
        self.posts = posts
        self.members = members
        self.createdAt = createdAt
    }

    static func == (lhs: Community, rhs: Community) -> Bool {
        lhs.id == rhs.id
    }
}

struct Comment: Codable, Identifiable, Equatable {
    let id: UUID
    var postID: UUID
    var parentCommentID: UUID?
    var authorID: UUID
    var authorName: String
    var text: String
    var createdAt: Date
    var likedBy: [UUID] = []
    var likesCount: Int {
        return likedBy.count
    }

    init(postID: UUID, parentCommentID: UUID? = nil, authorID: UUID, authorName: String, text: String) {
        self.id = UUID()
        self.postID = postID
        self.parentCommentID = parentCommentID
        self.authorID = authorID
        self.authorName = authorName
        self.text = text
        self.createdAt = Date()
        self.likedBy = []
    }
    
    /// Full memberwise init for reassembling from DB
    init(id: UUID, postID: UUID, parentCommentID: UUID?, authorID: UUID, authorName: String, text: String, createdAt: Date, likedBy: [UUID]) {
        self.id = id
        self.postID = postID
        self.parentCommentID = parentCommentID
        self.authorID = authorID
        self.authorName = authorName
        self.text = text
        self.createdAt = createdAt
        self.likedBy = likedBy
    }

    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

struct Post: Codable, Identifiable, Equatable {
    let id: UUID
    var communityID: UUID
    var authorID: UUID
    var authorName: String
    var title: String
    var text: String
    var imageURL: String?
    var likedBy: [UUID]
    var comments: [Comment]
    var createdAt: Date
    var likesCount: Int {
        return likedBy.count
    }
    
    init(communityID: UUID, authorID: UUID, authorName: String,title: String, text: String, imageURL: String? = nil) {
        self.id = UUID()
        self.communityID = communityID
        self.authorID = authorID
        self.authorName = authorName
        self.title = title
        self.text = text
        self.imageURL = imageURL
        self.likedBy = []
        self.comments = []
        self.createdAt = Date()
    }
    
    /// Full memberwise init for reassembling from DB
    init(id: UUID, communityID: UUID, authorID: UUID, authorName: String, title: String, text: String, imageURL: String?, likedBy: [UUID], comments: [Comment], createdAt: Date) {
        self.id = id
        self.communityID = communityID
        self.authorID = authorID
        self.authorName = authorName
        self.title = title
        self.text = text
        self.imageURL = imageURL
        self.likedBy = likedBy
        self.comments = comments
        self.createdAt = createdAt
    }

    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
    
    func isLikedBy(userID: UUID) -> Bool {
        return likedBy.contains(userID)
    }
}

struct Report: Codable, Identifiable, Equatable {
    let id: UUID
    var postID: UUID
    var communityID: UUID
    var reporterID: UUID
    var reason: String
    var notes: String?
    var createdAt: Date

    init(postID: UUID, communityID: UUID, reporterID: UUID, reason: String, notes: String? = nil) {
        self.id = UUID()
        self.postID = postID
        self.communityID = communityID
        self.reporterID = reporterID
        self.reason = reason
        self.notes = notes
        self.createdAt = Date()
    }

    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id
    }
}
