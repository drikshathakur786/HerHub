//
//  CommunityManager.swift
//  HerHub
//
//  Created by Driksha Thakur on 11/11/25.
//

import Foundation

class CommunityManager {
    
    // MARK: - Singleton Instance
    // A single shared manager used across the app
    // A single globally accessible instance CommunityManager.shared
    // static let ensures it’s created once and is immutable (thread-safe creation in Swift).
    // Purpose: share the same manager across the app so all screens see the same in-memory data.
    static let shared = CommunityManager()
    let currentUserID = UUID(uuidString: "E4882162-392D-4212-B740-76C297B59601")! // This represents YOU
    
    
    // MARK: - Private Properties
    // Stores all community data in memory. In-memory array of Community objects.
    private var communities: [Community] = []
    
    
    // Local file path for saving and loading data. The URL pointing to the plist file on disk where the communities are saved/loaded. It’s let because its location never changes after initialization.
    private let fileURL: URL
    
    
    // MARK: - Initializer
    // Sets file location and loads saved or sample data
    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
        // Builds the file path .../Documents/communities_v10.plist
        fileURL = directory.appendingPathComponent("communities_v11").appendingPathExtension("json")
        
        loadCommunities()
    }
    
    
    // MARK: - READ
    // Returns all communities
    func getAllCommunities() -> [Community] {
        return communities
    }
    
    
    // Returns a single community by ID
    func getCommunity(by id: UUID) -> Community? {
        return communities.first { $0.id == id }
    }
    
    
    // MARK: - CREATE
    // Adds a new community and saves data
    func addCommunity(name: String, description: String, themeColor: String, isFeatured: Bool, createdBy: UUID) {
        let newCommunity = Community(
            name: name,
            description: description,
            themeColor: themeColor,
            isFeatured: isFeatured,
            createdBy: createdBy
        )
        communities.append(newCommunity)
        saveCommunities()
    }
    
    
    // Returns all posts from communities marked as featured
    func getFeaturedPosts() -> [Post] {
        let allCommunities = getAllCommunities()
        let featuredCommunities = allCommunities.filter { $0.isFeatured == true }
        let allFeaturedPosts = featuredCommunities.flatMap { $0.posts }
        return allFeaturedPosts.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    
    // MARK: - UPDATE
    // Updates an existing community
    func updateCommunity(_ updated: Community) {
        if let index = communities.firstIndex(where: { $0.id == updated.id }) {
            communities[index] = updated
            saveCommunities()
        }
    }
    
    // MARK: - ADD POST
    // Adds a new post to a community
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
        saveCommunities()
    }
    
    
    // Returns all posts from all communities
    func getAllPosts() -> [Post] {
        let allPosts = communities.flatMap { $0.posts }
        return allPosts.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    
    // MARK: - ADD COMMENT
    // Adds a comment to a specific post inside a community
    func addComment(to postID: UUID, in communityID: UUID, authorID: UUID, authorName: String, text: String) {
        guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
        guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
        
        let comment = Comment(
            postID: postID,
            authorID: authorID,
            authorName: authorName,
            text: text
        )
        
        communities[cIndex].posts[pIndex].comments.append(comment)
        saveCommunities()
    }
    
    
    // MARK: - JOIN COMMUNITY
    // Adds a user to a community if not already joined
    func joinCommunity(communityID: UUID, userID: UUID) {
        guard let index = communities.firstIndex(where: { $0.id == communityID }) else { return }
        
        if !communities[index].members.contains(userID) {
            communities[index].members.append(userID)
            saveCommunities()
        }
    }
    
    // MARK: - LIKE POST
    // Increases like count for a specific post
        func likePost(postID: UUID, communityID: UUID) {
            // 1. Find the community
            guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
            
            // 2. Find the post
            guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
            
            // 3. Increase count
            communities[cIndex].posts[pIndex].likesCount += 1
            
            // 4. Save
            saveCommunities()
        }
    
    
    // MARK: - LIKE COMMENT
        func likeComment(commentID: UUID, postID: UUID, communityID: UUID) {
            // 1. Find Community
            guard let cIndex = communities.firstIndex(where: { $0.id == communityID }) else { return }
            
            // 2. Find Post
            guard let pIndex = communities[cIndex].posts.firstIndex(where: { $0.id == postID }) else { return }
            
            // 3. Find Comment
            guard let cmIndex = communities[cIndex].posts[pIndex].comments.firstIndex(where: { $0.id == commentID }) else { return }
            
            // 4. Increase Count
            communities[cIndex].posts[pIndex].comments[cmIndex].likesCount += 1
            
            // 5. Save
            saveCommunities()
        }
    
    
    // MARK: - PERSISTENCE
    // Loads saved data or default sample data
    private func loadCommunities() {
//        if let data = try? Data(contentsOf: fileURL) {
//            let decoder = PropertyListDecoder()
//            if let decoded = try? decoder.decode([Community].self, from: data) {
//                communities = decoded
//                return
//            }
//        }
//        
//        // Load sample data if file not found
//        communities = loadSampleCommunities()
//        saveCommunities()
        
        if let data = try? Data(contentsOf: fileURL) {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode([Community].self, from: data) {
                    communities = decoded
                    return
                }
            }
            
            // 2. If no saved data exists, load sample data
            communities = loadSampleCommunities()
            saveCommunities()
    }
    
    
    // Saves current data to a plist file
    private func saveCommunities() {
//        let encoder = PropertyListEncoder()
//        encoder.outputFormat = .xml
//        if let data = try? encoder.encode(communities) {
//            try? data.write(to: fileURL, options: .noFileProtection)
//        }
        
        
        let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional: Makes the JSON file human-readable
            
            if let data = try? encoder.encode(communities) {
                try? data.write(to: fileURL, options: .noFileProtection)
            }
    }
    
    // MARK: - SAMPLE DATA (FROM JSON FILE)
//        private func loadSampleCommunities() -> [Community] {
//            // 1. Find the file in the app bundle
//            guard let url = Bundle.main.url(forResource: "sampleCommunities", withExtension: "json") else {
//                print("❌ Error: Could not find sampleCommunities.json in bundle.")
//                return []
//            }
//            
//            // 2. Decode the JSON data
//            do {
//                let data = try Data(contentsOf: url)
//                let decoder = JSONDecoder()
//                // This automatically converts the JSON text into [Community] objects
//                let decodedCommunities = try decoder.decode([Community].self, from: data)
//                
//                print("✅ Successfully loaded \(decodedCommunities.count) communities from JSON.")
//                return decodedCommunities
//                
//            } catch {
//                print("❌ Error decoding sample data: \(error)")
//                return []
//            }
//        }
    
    
    // MARK: - SAMPLE DATA (FROM JSON FILE)
        private func loadSampleCommunities() -> [Community] {
            // 1. Find the file
            guard let url = Bundle.main.url(forResource: "sampleCommunities", withExtension: "json") else {
                print("❌ Error: Could not find sampleCommunities.json")
                return []
            }
            
            // 2. Decode the JSON
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var decodedCommunities = try decoder.decode([Community].self, from: data)
                
                // --- 3. THE FIX: REFRESH DATES ---
                // Loop through everything and set the date to NOW
                let now = Date()
                
                for i in 0..<decodedCommunities.count {
                    // Update Community Date
                    decodedCommunities[i].createdAt = now
                    
                    // Update Posts
                    for j in 0..<decodedCommunities[i].posts.count {
                        decodedCommunities[i].posts[j].createdAt = now
                        
                        // Update Comments
                        for k in 0..<decodedCommunities[i].posts[j].comments.count {
                            decodedCommunities[i].posts[j].comments[k].createdAt = now
                        }
                    }
                }
                // --------------------------------
                
                print("✅ Loaded and refreshed \(decodedCommunities.count) communities.")
                return decodedCommunities
                
            } catch {
                print("❌ Error decoding sample data: \(error)")
                return []
            }
        }
    // MARK: - SAMPLE DATA
    // Creates sample communities for first-time launch
//    private func loadSampleCommunities() -> [Community] {
//        let userID = UUID()
//        _ = "Driksha"
//
//        // --- 1. First Period Community ---
//        var firstPeriod = Community(
//            name: "FirstFlow",
//            description: "Support for your first period journey",
//            themeColor: "pink",
//            isFeatured: true,
//            createdBy: userID
//        )
//
//        // Post 1
//        var fpPost1 = Post(
//            communityID: firstPeriod.id,
//            authorID: userID,
//            authorName: "miali_98",
//            title: "Cramps help?",
//            text: "Is it normal for my tummy to hurt this much? It feels like a constant, dull ache and sometimes it gets sharp. 😩 I have a big science test tomorrow and I'm so worried I won't be able to concentrate. Does anyone have tips for dealing with cramps that actually work?",
//            imageURL: nil
//        )
//        fpPost1.comments = [
//            Comment(postID: fpPost1.id, authorID: UUID(), authorName: "Sarah L.", text: "Heat patches are a lifesaver! I wear them to school."),
//            Comment(postID: fpPost1.id, authorID: UUID(), authorName: "Emma K.", text: "Ginger tea helps me a lot with the nausea."),
//            Comment(postID: fpPost1.id, authorID: UUID(), authorName: "Maya P.", text: "You got this! Good luck on your test!")
//        ]
//        
//        // Post 2
//        var fpPost2 = Post(
//            communityID: firstPeriod.id,
//            authorID: userID,
//            authorName: "selenaa12",
//            title: "My Go-Kit",
//            text: "My mom helped me make a little 'go-kit' for my school bag! It has a couple of pads, a clean pair of underwear, and a small chocolate bar for emergencies. It makes me feel so much more prepared and less anxious! What do you keep in yours?",
//            imageURL: "post_image_1"
//        )
//        fpPost2.comments = [
//            Comment(postID: fpPost2.id, authorID: UUID(), authorName: "Chloe", text: "I keep spare leggings in mine too, just in case."),
//            Comment(postID: fpPost2.id, authorID: UUID(), authorName: "Zoe", text: "Great idea adding the chocolate! 🍫")
//        ]
//        
//        // Post 3
//        var fpPost3 = Post(
//            communityID: firstPeriod.id,
//            authorID: userID,
//            authorName: "janee112",
//            title: "Leaks happen!",
//            text: "Let's talk about something everyone worries about: leaks! It has happened to literally all of us at some point, so please don't feel embarrassed. Pro tip: tying a sweater or hoodie around your waist is a classic for a reason! Also, if you get a stain on your clothes, cold water is your best friend. What are your go-to tricks?",
//            imageURL: "post_image_2"
//        )
//        fpPost3.comments = [
//            Comment(postID: fpPost3.id, authorID: UUID(), authorName: "Lily", text: "Hydrogen peroxide works wonders on fresh stains!"),
//            Comment(postID: fpPost3.id, authorID: UUID(), authorName: "Grace", text: "Tying the jacket is the oldest trick in the book, works every time.")
//        ]
//        
//        // Post 4
//        var fpPost4 = Post(
//            communityID: firstPeriod.id,
//            authorID: userID,
//            authorName: "sarahhimila_34",
//            title: "Reminder",
//            text: "Just a reminder for anyone who needs to hear it: every body is different! Your first period might be light, heavy, short, long, or show up at a different time than your friends. That's completely okay. It might be light, heavy, short, long, or show up at a different time than your friends and that's normal! Your body figures things out. You're not alone in this! 💕",
//            imageURL: nil
//        )
//        fpPost4.comments = [
//            Comment(postID: fpPost4.id, authorID: UUID(), authorName: "Hannah", text: "Needed to hear this today, thank you! ❤️"),
//            Comment(postID: fpPost4.id, authorID: UUID(), authorName: "Olivia", text: "Love this positive vibe.")
//        ]
//
//        // Assign posts to community
//        firstPeriod.posts = [fpPost1, fpPost2, fpPost3, fpPost4]
////        firstPeriod.members = (0..<3).map { _ in UUID() }
////        firstPeriod.members.append(self.currentUserID) // <--- ADD YOU!
//        
//        var fpMembers = (0..<3).map { _ in UUID() }
//        fpMembers.append(self.currentUserID) // <--- ADD YOU!
//        firstPeriod.members = fpMembers
//                
//
//        
//        // --- 2. PCOS Support Community ---
//        var pcosSupport = Community(
//            name: "PCOS",
//            description: "Understanding and managing PCOS",
//            themeColor: "purple",
//            isFeatured: true,
//            createdBy: userID
//        )
//        
//        // PCOS Post 1
//        var pcosPost1 = Post(
//            communityID: pcosSupport.id,
//            authorID: userID,
//            authorName: "julia_18",
//            title: "Diagnosis Story",
//            text: "Just got diagnosed with PCOS last month. The irregular periods were so confusing! Thanks to this community for helping me understand it's not my fault.",
//            imageURL: "pcos_post_1"
//        )
//        pcosPost1.comments = [
//            Comment(postID: pcosPost1.id, authorID: UUID(), authorName: "Anna", text: "Welcome to the community! It gets easier to manage."),
//            Comment(postID: pcosPost1.id, authorID: UUID(), authorName: "Bella", text: "Don't stress, knowledge is power.")
//        ]
//        
//        // PCOS Post 2
//        var pcosPost2 = Post(
//            communityID: pcosSupport.id,
//            authorID: userID,
//            authorName: "selenaa09",
//            title: "Diet Tips",
//            text: "Here are some PCOS-friendly foods that can help manage symptoms naturally! 🥗",
//            imageURL: "pcos_post_2"
//        )
//        pcosPost2.comments = [
//            Comment(postID: pcosPost2.id, authorID: UUID(), authorName: "Clara", text: "Cutting sugar helped my energy levels so much."),
//            Comment(postID: pcosPost2.id, authorID: UUID(), authorName: "Diana", text: "Do you have any easy lunch recipes?")
//        ]
//        
//        // PCOS Post 3
//        var pcosPost3 = Post(
//            communityID: pcosSupport.id,
//            authorID: userID,
//            authorName: "katie87",
//            title: "Self Care",
//            text: "Friendly reminder: Be gentle with yourself. This journey has its ups and downs, and it’s okay to have tough days. Your worth isn’t defined by a diagnosis. Sending love to anyone who needs it today. ♥️ #PCOSSupport #SelfCare",
//            imageURL: nil
//        )
//        pcosPost3.comments = [
//             Comment(postID: pcosPost3.id, authorID: UUID(), authorName: "Eva", text: "Self care Sunday is my favorite."),
//             Comment(postID: pcosPost3.id, authorID: UUID(), authorName: "Fiona", text: "Sending love back! We are strong.")
//        ]
//        
//        // PCOS Post 4
//        var pcosPost4 = Post(
//            communityID: pcosSupport.id,
//            authorID: userID,
//            authorName: "mindful.mover_anna",
//            title: "Mindful Movement",
//            text: "Movement has been a game-changer for my mood swings. Found that gentle yoga and daily walks work better for me than intense workouts. What kind of movement makes you all feel good?\n#PCOSJourney #MindfulMovement",
//            imageURL: "pcos_post_3"
//        )
//        pcosPost4.comments = [
//            Comment(postID: pcosPost4.id, authorID: UUID(), authorName: "Gina", text: "Yin yoga is amazing for stress relief."),
//            Comment(postID: pcosPost4.id, authorID: UUID(), authorName: "Holly", text: "I love swimming, it's so gentle on the joints.")
//        ]
//        
//        // Assign posts
//        pcosSupport.posts = [pcosPost1, pcosPost2, pcosPost3, pcosPost4]
////        pcosSupport.members = (0..<2).map { _ in UUID() }
//        var pcosMembers = (0..<2).map { _ in UUID() }
//        pcosMembers.append(self.currentUserID) // <--- ADD YOU!
//        pcosSupport.members = pcosMembers
//
//        return [firstPeriod, pcosSupport]
//    }
}
