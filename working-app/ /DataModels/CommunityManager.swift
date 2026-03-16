//
//  CommunityManager.swift
//  HerHub
//
//  Created by Driksha Thakur on 11/11/25.
//

import Foundation

class CommunityManager {
    
    static let shared = CommunityManager()
   
    var currentUserID: UUID? {
        return AuthManager.shared.currentUser?.id
    }
    
    var currentUserName: String {
        return AuthManager.shared.currentUser?.userName ?? "Anonymous"
    }

    private var communities: [Community] = []
    private let supabaseService = SupabaseService.shared
    
    private let fileURL: URL
    private let reportedPostsDefaultsKeyPrefix = "herhub_reportedPosts_"
   
    private var useSupabase: Bool {
        return AuthManager.shared.isLoggedIn
    }
    
    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = directory.appendingPathComponent("communities_v11").appendingPathExtension("json")
        loadCommunities()
    }
    
    
    func getAllCommunities() -> [Community] {
        return communities
    }
   
    
    func getCommunity(by id: UUID) -> Community? {
        return communities.first { $0.id == id }
    }
    
    
    func addCommunity(name: String, description: String, themeColor: String, isFeatured: Bool, createdBy: UUID) {
        var newCommunity = Community(
            name: name,
            description: description,
            themeColor: themeColor,
            isFeatured: isFeatured,
            createdBy: createdBy
        )
        newCommunity.members.append(createdBy)
        communities.append(newCommunity)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.createCommunity(newCommunity)
                print("[CommunityManager] Created community in Supabase: \(newCommunity.id)")
            }
        }
        saveCommunities()
    }
    
    
    func getFeaturedPosts() -> [Post] {
      
        guard let userID = currentUserID else { return [] }
        let reported = postIDsReported(by: userID)
                
        let allCommunities = getAllCommunities()
        let relevantCommunities = allCommunities.filter { community in
            return community.isFeatured == true && community.members.contains(userID)
        }
                
        let allPosts = relevantCommunities.flatMap { $0.posts }
                .filter { !reported.contains($0.id) }
                
        let activePosts = allPosts.filter { $0.likesCount > 0 }
                
        let topPosts = activePosts.sorted { (post1, post2) -> Bool in
                if post1.likesCount == post2.likesCount {
                    return post1.createdAt > post2.createdAt
                }
                return post1.likesCount > post2.likesCount
        }
                
        return Array(topPosts.prefix(5))
    }
    
    
    func updateCommunity(_ updated: Community) {
        if let index = communities.firstIndex(where: { $0.id == updated.id }) {
            communities[index] = updated
            
            if useSupabase {
                Task {
                    _ = try? await supabaseService.updateCommunity(updated)
                    print("[CommunityManager] Updated community in Supabase: \(updated.id)")
                }
            }
            
            saveCommunities()
        }
    }
    
    
    func addPost(to communityID: UUID, authorID: UUID, authorName: String, title: String, text: String, imageURL: String?) {
        guard let index = communities.firstIndex(where: { $0.id == communityID }) else { return }
        let post = Post(
            communityID: communityID,
            authorID: authorID,
            authorName: authorName,
            title: title,
            text: text,
            imageURL: imageURL
        )
        communities[index].posts.append(post)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.createPost(post)
                print("[CommunityManager] Created post in Supabase: \(post.id)")
            }
        }
        
        saveCommunities()
    }
    
    func deletePost(postID: UUID, in communityID: UUID) {
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        
        communities[cIndex].posts.remove(at: pIndex)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.deletePost(postID: postID)
                print("[CommunityManager] Deleted post in Supabase: \(postID)")
            }
        }
        
        saveCommunities()
    }
    
    
    func getAllPosts() -> [Post] {
        let allPosts = communities.flatMap { $0.posts }
        return allPosts.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    
    func getJoinedCommunities() -> [Community] {
        guard let userID = currentUserID else { return [] }
        return communities.filter { $0.members.contains(userID) }
    }
  
    
    func getPosts(byUserID userID: UUID) -> [Post] {
        return getAllPosts().filter { $0.authorID == userID }
    }
    
    
    func getCommunities(createdBy userID: UUID) -> [Community] {
        return communities.filter { $0.createdBy == userID }
    }
  
    
    func isCurrentUserMember(of communityID: UUID) -> Bool {
        guard let userID = currentUserID,
              let community = getCommunity(by: communityID) else { return false }
        return community.members.contains(userID)
    }
   
    
    func addComment(to postID: UUID, in communityID: UUID, authorID: UUID, authorName: String, text: String) {
        
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
    
        let comment = Comment(
            postID: postID,
            parentCommentID: nil,
            authorID: authorID,
            authorName: authorName,
            text: text
        )
        
        communities[cIndex].posts[pIndex].comments.append(comment)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.createComment(comment)
                print("[CommunityManager] Created comment in Supabase: \(comment.id)")
            }
        }
        
        saveCommunities()
    }
    
    func addReply(to parentCommentID: UUID, postID: UUID, in communityID: UUID, authorID: UUID, authorName: String, text: String) {
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        
        let reply = Comment(
            postID: postID,
            parentCommentID: parentCommentID,
            authorID: authorID,
            authorName: authorName,
            text: text
        )
        
        communities[cIndex].posts[pIndex].comments.append(reply)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.createComment(reply)
                print("[CommunityManager] Created reply comment in Supabase: \(reply.id)")
            }
        }
        
        saveCommunities()
    }
    
    func deleteComment(commentID: UUID, postID: UUID, communityID: UUID) {
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        guard let cmIndex = communities[cIndex].posts[pIndex].comments.firstIndex(where: { $0.id == commentID }) else { return }
        
        communities[cIndex].posts[pIndex].comments.remove(at: cmIndex)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.deleteComment(commentID: commentID)
                print("[CommunityManager] Deleted comment in Supabase: \(commentID)")
            }
        }
        
        saveCommunities()
    }
    
    
    func joinCommunity(communityID: UUID, userID: UUID) {
        guard let index = communities.firstIndex(where: { $0.id == communityID }) else { return }
        
        if !communities[index].members.contains(userID) {
            communities[index].members.append(userID)
            
            if useSupabase {
                Task {
                    _ = try? await supabaseService.joinCommunity(communityID: communityID, userID: userID)
                    print("[CommunityManager] Joined community in Supabase: \(communityID)")
                }
            }
            
            saveCommunities()
        }
    }
    
    func leaveCommunity(communityID: UUID, userID: UUID) {
        guard let index = communities.firstIndex(where: { $0.id == communityID }) else { return }
        
        if let memberIndex = communities[index].members.firstIndex(of: userID) {
            communities[index].members.remove(at: memberIndex)
            
            if useSupabase {
    
            }
            
            saveCommunities()
        }
    }

    func deleteCommunity(communityID: UUID) {
        guard let index = communities.firstIndex(where: { $0.id == communityID }) else { return }
        
        let community = communities.remove(at: index)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.deleteCommunity(community)
                print("[CommunityManager] Deleted community in Supabase: \(community.id)")
            }
        }
        
        saveCommunities()
    }


    func likePost(postID: UUID, communityID: UUID, userID: UUID) {
        
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        
        
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        
        if let existingIndex = communities[cIndex].posts[pIndex].likedBy.firstIndex(of: userID) {
            communities[cIndex].posts[pIndex].likedBy.remove(at: existingIndex)
        } else {
            communities[cIndex].posts[pIndex].likedBy.append(userID)
        }
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.togglePostLike(postID: postID, userID: userID)
                print("[CommunityManager] Toggled post like in Supabase: \(postID)")
            }
        }
        
        saveCommunities()
    }
    
    
    func hasUserLikedPost(postID: UUID, communityID: UUID, userID: UUID) -> Bool {
        guard let community = getCommunity(by: communityID),
              let post = community.posts.first(where: { $0.id == postID }) else {
            return false
        }
        return post.likedBy.contains(userID)
    }
    
    
    func likeComment(commentID: UUID, postID: UUID, communityID: UUID) {
 
        guard let userID = currentUserID else { return }
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        guard let cmIndex = communities[cIndex].posts[pIndex].comments.firstIndex(where: { $0.id == commentID }) else { return }
        
    
        if let userIndex = communities[cIndex].posts[pIndex].comments[cmIndex].likedBy.firstIndex(of: userID) {
            communities[cIndex].posts[pIndex].comments[cmIndex].likedBy.remove(at: userIndex)
        } else {
            communities[cIndex].posts[pIndex].comments[cmIndex].likedBy.append(userID)
        }
      
        saveCommunities()
    }
    
 
    func addReport(postID: UUID, communityID: UUID, reporterID: UUID, reason: String, notes: String?) {
        let report = Report(
            postID: postID,
            communityID: communityID,
            reporterID: reporterID,
            reason: reason,
            notes: notes
        )
        recordReportedPost(postID: postID, by: reporterID)
        
        if useSupabase {
            Task {
                _ = try? await supabaseService.createReport(report)
                print("[CommunityManager] Created report in Supabase: \(report.id)")
            }
        }
        
        print("REPORT FILED:")
        print("   - Post ID: \(postID)")
        print("   - Reason: \(reason)")
        print("   - Reporter: \(reporterID)")
    }
    
    
    func postIDsReported(by userID: UUID) -> Set<UUID> {
        let key = reportedPostsDefaultsKeyPrefix + userID.uuidString
        guard let strings = UserDefaults.standard.stringArray(forKey: key) else { return [] }
        return Set(strings.compactMap { UUID(uuidString: $0) })
    }
    
    func recordReportedPost(postID: UUID, by reporterID: UUID) {
        let key = reportedPostsDefaultsKeyPrefix + reporterID.uuidString
        var set = postIDsReported(by: reporterID)
        set.insert(postID)
        UserDefaults.standard.set(Array(set).map { $0.uuidString }, forKey: key)
    }
    
    func getPostsForDisplay(in communityID: UUID, currentUserID: UUID?) -> [Post] {
        guard let community = getCommunity(by: communityID) else { return [] }
        guard let userID = currentUserID else { return community.posts }
        let reported = postIDsReported(by: userID)
        return community.posts.filter { !reported.contains($0.id) }
    }
    
    
    private func loadCommunities() {
        if useSupabase {
            loadFromLocalStorage()
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)

            Task {
                do {
                    let fetched = try await supabaseService.fetchAllCommunities()

                    if fetched.isEmpty {
                        print("[CommunityManager] Supabase returned 0 communities, falling back to local cache")
                        await MainActor.run {
                            self.loadFromLocalStorage()
                            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
                        }
                    } else {
                        self.communities = fetched
                        print("[CommunityManager] Loaded \(fetched.count) communities from Supabase")
                        await MainActor.run {
                            self.saveCommunities()
                            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
                        }
                    }
                } catch {
                    print("[CommunityManager] Error loading from Supabase: \(error)")
                    await MainActor.run {
                        self.loadFromLocalStorage()
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
                    }
                }
            }
        } else {
            loadFromLocalStorage()
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
        }
    }
    
    private func loadFromLocalStorage() {
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Community].self, from: data) {
                if decoded.isEmpty {
                    communities = loadSampleCommunities()
                    saveCommunities()
                } else {
                    communities = decoded
                }
                return
            }
        }
        
        communities = loadSampleCommunities()
        saveCommunities()
    }

   
    private func saveCommunities() {

        let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
        if let data = try? encoder.encode(communities) {
                _ = try? data.write(to: fileURL, options: .noFileProtection)
        }
    }
  
    
    private func loadSampleCommunities() -> [Community] {
           
            guard let url = Bundle.main.url(forResource: "sampleCommunities", withExtension: "json") else {
                print("  Error: Could not find sampleCommunities.json")
                return []
            }
         
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var decodedCommunities = try decoder.decode([Community].self, from: data)
              
                let now = Date()
                
                for i in 0..<decodedCommunities.count {
                 
                    decodedCommunities[i].createdAt = now
                    
                    for j in 0..<decodedCommunities[i].posts.count {
                        decodedCommunities[i].posts[j].createdAt = now
                        
                        for k in 0..<decodedCommunities[i].posts[j].comments.count {
                            decodedCommunities[i].posts[j].comments[k].createdAt = now
                        }
                    }
                }
                print("Loaded and refreshed \(decodedCommunities.count) communities.")
                return decodedCommunities
                
            } catch {
                print(" Error decoding sample data: \(error)")
                return []
            }
    }
    
}


