//
//  ResourceModel.swift
//  HerHub
//
//  Created by Mahika Behal on 28/10/25.
//

import Foundation

struct Resource: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var detailSubtitle: String   
    var category: ResourceCategory
    var content: String
    var author: String
    var estimatedReadTime: String
    var imageURL: String?
    var bookmarkedBy: [UUID]     
    var isLiked: [UUID]?          
    var summary: String?
    var sourceURL: String?      
    var tags: [String]?
    
    var likesCount: Int {
        return isLiked?.count ?? 0
    }
    
    var bookmarksCount: Int {
        return bookmarkedBy.count
    }
    
    func isLikedBy(userID: UUID) -> Bool {
        return isLiked?.contains(userID) ?? false
    }
    
    func isBookmarkedBy(userID: UUID) -> Bool {
        return bookmarkedBy.contains(userID)
    }
    
    init(
        title: String,
        description: String,
        detailSubtitle: String,
        category: ResourceCategory,
        content: String,
        author: String,
        estimatedReadTime: String,
        imageURL: String? = nil,
        bookmarkedBy: [UUID] = [],
        isLiked: [UUID]? = nil,
        tags: [String]? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.detailSubtitle = detailSubtitle     
        self.category = category
        self.content = content
        self.author = author
        self.estimatedReadTime = estimatedReadTime
        self.imageURL = imageURL
        self.bookmarkedBy = bookmarkedBy
        self.isLiked = isLiked
        self.tags = tags
    }
}

enum ResourceCategory: String, Codable, CaseIterable {
    case featured = "Featured"
    case health = "Health"
    case wellness = "Wellness"
    case lifestyle = "Lifestyle"
    case fitness = "Fitness"
    case skincare = "Skincare"
}
