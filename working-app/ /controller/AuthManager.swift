//
//  AuthManager.swift
//  HerHub
//
//  Manages user login and signup
//

import Foundation

// singleton class for managing authentication

final class AuthManager {
    
    // singleton instance
    static let shared = AuthManager()
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUserID"
    
    // current logged in user
    private(set) var currentUser: User?
    
    // private init for singleton pattern
    private init() { 
        loadCurrentUser() // load saved user on init
    }
    
    // MARK: - Session Management
    
    // check if user is logged in
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    // load user from saved ID
    private func loadCurrentUser() {
        guard let userIDString = userDefaults.string(forKey: currentUserKey),
              let userID = UUID(uuidString: userIDString) else {
            currentUser = nil
            return
        }
        
        // fetch user asynchronously
        Task {
            currentUser = try? await UserController.shared.fetchUser(byID: userID)
        }
    }
    
    // MARK: - Sign In
    
    // sign in with email and password
    func signIn(email: String, password: String) async throws -> User {
        // get user from database
        guard let user = try await UserController.shared.fetchUserByEmail(email) else {
            throw AuthError.userNotFound
        }
        
        // check password matches
        guard user.password == password else {
            throw AuthError.invalidPassword
        }
        
        // save logged in user
        currentUser = user
        userDefaults.set(user.id.uuidString, forKey: currentUserKey)
        
        print("signed in: \(email)")
        print("user name: \(user.userName ?? "not set")")
        print("user ID: \(user.id)")
        return user
    }
    
    // MARK: - Sign Up
    
    // create new account
    
    func signUp(name: String, email: String, password: String) async throws -> User {
        // check if email already exists
        if let _ = try? await UserController.shared.fetchUserByEmail(email) {
            throw AuthError.emailAlreadyExists
        }
        
        // make new user object
        let newUser = User(
            id: UUID(),
            email: email,
            phoneNumber: nil,
            password: password,
            userName: name,
            userPicture: nil,
            baselineProfile: nil,
            recentCheckIns: nil,
            latestPrediction: nil
        )
        
        // save to database
        try await UserController.shared.createUser(newUser)
        
        // set as current user
        currentUser = newUser
        userDefaults.set(newUser.id.uuidString, forKey: currentUserKey)
        
        print("created account: \(email)")
        print("user name: \(newUser.userName ?? "not set")")
        print("user ID: \(newUser.id)")
        return newUser
    }
    
    // MARK: - Sign Out
    
    // logout user
    func signOut() {
        currentUser = nil
        userDefaults.removeObject(forKey: currentUserKey)
        print("user signed out")
    }
    
    // MARK: - Update Current User
    
    // update the current user object
    func updateCurrentUser(_ user: User) {
        currentUser = user
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case userNotFound
    case invalidPassword
    case emailAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No account found with this email"
        case .invalidPassword:
            return "Incorrect password"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        }
    }
}
