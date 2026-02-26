//
//  Community.swift
//  HerHub
//
//  Created by Driksha Thakur on 11/11/25.
//

import Foundation

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

    static func == (lhs: Community, rhs: Community) -> Bool {
        lhs.id == rhs.id
    }
}

struct Comment: Codable, Identifiable, Equatable {
    let id: UUID
    var postID: UUID
    var authorID: UUID
    var authorName: String
    var text: String
    var createdAt: Date
    var likedBy: [UUID] = []
    var likesCount: Int {
        return likedBy.count
    }

    init(postID: UUID, authorID: UUID, authorName: String, text: String) {
        self.id = UUID()
        self.postID = postID
        self.authorID = authorID
        self.authorName = authorName
        self.text = text
        self.createdAt = Date()
        self.likedBy = []
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
