import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    private init() {}
    
    // MARK: - Properties
    private(set) var currentUser: User?
    
    private let userIdKey = "currentUserId"
    
    // MARK: - Session Management
    
    /// Login user and save session
    func login(user: User) {
        self.currentUser = user
        UserDefaults.standard.set(user.id.uuidString, forKey: userIdKey)
        print("✅ User logged in: \(user.email ?? user.userName ?? "Unknown")")
        NotificationCenter.default.post(name: .userSessionUpdated, object: nil)
    }
    
    /// Logout and clear session
    func logout() {
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: userIdKey)
        print("👋 User logged out")
        NotificationCenter.default.post(name: .userSessionUpdated, object: nil)
    }
    
    /// Get saved user ID from UserDefaults
    func getSavedUserId() -> UUID? {
        guard let idString = UserDefaults.standard.string(forKey: userIdKey),
              let uuid = UUID(uuidString: idString) else {
            return nil
        }
        return uuid
    }
    
    /// Load session from UserDefaults
    func loadSession() async throws {
        // First, try to load saved session
        if let userId = getSavedUserId() {
            print("🔄 Loading session for user ID: \(userId)")
            
            // Fetch user from JSON storage
            if let user = try UserJsonManager.shared.fetchUser(byID: userId) {
                self.currentUser = user
                print("✅ Session loaded: \(user.email ?? user.userName ?? "Unknown")")
                NotificationCenter.default.post(name: .userSessionUpdated, object: nil)
                return
            } else {
                print("  User not found in storage, clearing session")
                logout()
            }
        }
        
        // Auto-login with test user if no session exists (for local development)
        print("🔄 No saved session, attempting auto-login with test user...")
        if let testUser = try UserJsonManager.shared.fetchUser(byEmail: "test@herhub.com") {
            login(user: testUser)
            print("✅ Auto-logged in as test user: \(testUser.email ?? "Unknown")")
        } else {
            print("   No test user found")
        }
    }
    
    /// Update current user (e.g., after profile edit)
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
        print("✅ Current user updated")
        NotificationCenter.default.post(name: .userSessionUpdated, object: nil)
    }
}

extension Notification.Name {
    static let userSessionUpdated = Notification.Name("UserSessionUpdated")
}
