//
//  AuthManager.swift
//  HerHub
//
//  Manages user login and signup using Supabase Auth
//

import Foundation
import Supabase

// singleton class for managing authentication

final class AuthManager {
    
    // singleton instance
    static let shared = AuthManager()
    
    private let supabase = SupabaseManager.shared
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
        return currentUser != nil || supabase.isAuthenticated
    }
    
    // load user from saved ID
    private func loadCurrentUser() {
        // Check Supabase session first
        if supabase.isAuthenticated, let userID = supabase.currentUserID {
            Task {
                do {
                    currentUser = try await SupabaseService.shared.fetchUser(byID: userID)
                } catch {
                    print("[AuthManager] Error loading user: \(error)")
                }
            }
            return
        }
        
        // Fallback to UserDefaults for migration
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
    
    // MARK: - Sign In with Supabase
    
    // sign in with email and password using Supabase Auth
    func signIn(email: String, password: String) async throws -> User {
        do {
            // Sign in with Supabase Auth
            let session = try await supabase.client.auth.signIn(email: email, password: password)
            
            print("[Supabase] Signed in: \(email)")
            print("[Supabase] Session user ID: \(session.user.id)")
            
            // Fetch user profile from database
            let uuid = session.user.id
            
            // Try to fetch user (trigger should have created it)
            if let user = try await SupabaseService.shared.fetchUser(byID: uuid) {
                currentUser = user
                userDefaults.set(user.id.uuidString, forKey: currentUserKey)
                print("signed in: \(email)")
                print("user name: \(user.userName ?? "not set")")
                print("user ID: \(user.id)")
                return user
            } else {
                // User exists in Auth but not in database - create profile
                // This handles legacy users created before the trigger
                let newUser = User(
                    id: uuid,
                    email: email,
                    phoneNumber: nil,
                    password: nil,
                    userName: session.user.userMetadata["name"]?.stringValue,
                    userPicture: session.user.userMetadata["avatar_url"]?.stringValue,
                    baselineProfile: nil,
                    recentCheckIns: nil,
                    latestPrediction: nil
                )
                
                // Try to insert, ignore if already exists (race condition with trigger)
                do {
                    try await SupabaseService.shared.createUser(newUser)
                } catch {
                    // If duplicate key error, fetch the existing user
                    if let existingUser = try await SupabaseService.shared.fetchUser(byID: uuid) {
                        currentUser = existingUser
                        userDefaults.set(existingUser.id.uuidString, forKey: currentUserKey)
                        return existingUser
                    }
                    throw error
                }
                currentUser = newUser
                userDefaults.set(newUser.id.uuidString, forKey: currentUserKey)
                return newUser
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("[Supabase] Sign in error: \(error)")
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign Up with Supabase
    
    // create new account using Supabase Auth
    func signUp(name: String, email: String, password: String) async throws -> User {
        do {
            // Sign up with Supabase Auth
            let response = try await supabase.client.auth.signUp(
                email: email,
                password: password,
                data: ["name": .string(name)]
            )
            
            print("[Supabase] Signed up: \(email)")
            
            let uuid = response.user.id
            
            // The trigger creates the user in public.users automatically
            // Fetch the user that was created by the trigger
            if let user = try await SupabaseService.shared.fetchUser(byID: uuid) {
                currentUser = user
                userDefaults.set(user.id.uuidString, forKey: currentUserKey)
                print("created account: \(email)")
                print("user name: \(user.userName ?? "not set")")
                print("user ID: \(user.id)")
                return user
            } else {
                // Fallback: create user manually if trigger didn't work
                let newUser = User(
                    id: uuid,
                    email: email,
                    phoneNumber: nil,
                    password: nil,
                    userName: name,
                    userPicture: nil,
                    baselineProfile: nil,
                    recentCheckIns: nil,
                    latestPrediction: nil
                )
                
                try await SupabaseService.shared.createUser(newUser)
                currentUser = newUser
                userDefaults.set(newUser.id.uuidString, forKey: currentUserKey)
                return newUser
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("[Supabase] Sign up error: \(error)")
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    // MARK: - OAuth Sign In
    
    // sign in with OAuth provider (Google, Apple, etc.)
    func signInWithOAuth(provider: Provider) async throws {
        do {
            _ = try await supabase.client.auth.signInWithOAuth(
                provider: provider,
                redirectTo: URL(string: "herhub://auth-callback")
            )
            print("[Supabase] OAuth sign in started for \(provider.rawValue)")
        } catch {
            print("[Supabase] OAuth error: \(error)")
            throw AuthError.oauthFailed(error.localizedDescription)
        }
    }
    
    // Handle OAuth callback URL
    func handleOAuthCallback(url: URL) async throws {
        do {
            let session = try await supabase.client.auth.session(from: url)
            print("[Supabase] OAuth callback successful")
            
            let uuid = session.user.id
            
            // Fetch or create user profile
            if let user = try await SupabaseService.shared.fetchUser(byID: uuid) {
                currentUser = user
                userDefaults.set(user.id.uuidString, forKey: currentUserKey)
            } else {
                let newUser = User(
                    id: uuid,
                    email: session.user.email,
                    phoneNumber: nil,
                    password: nil,
                    userName: session.user.userMetadata["name"]?.stringValue,
                    userPicture: session.user.userMetadata["avatar_url"]?.stringValue,
                    baselineProfile: nil,
                    recentCheckIns: nil,
                    latestPrediction: nil
                )
                try await SupabaseService.shared.createUser(newUser)
                currentUser = newUser
                userDefaults.set(newUser.id.uuidString, forKey: currentUserKey)
            }
        } catch {
            print("[Supabase] OAuth callback error: \(error)")
            throw AuthError.oauthFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Sign Out
    
    // logout user
    func signOut() async {
        do {
            try await supabase.client.auth.signOut()
            print("[Supabase] Signed out")
        } catch {
            print("[Supabase] Sign out error: \(error)")
        }
        
        currentUser = nil
        userDefaults.removeObject(forKey: currentUserKey)
        print("user signed out")
    }
    
    // MARK: - Password Reset
    
    // send password reset email
    func sendPasswordReset(email: String) async throws {
        do {
            try await supabase.client.auth.resetPasswordForEmail(email)
            print("[Supabase] Password reset email sent to \(email)")
        } catch {
            print("[Supabase] Password reset error: \(error)")
            throw AuthError.passwordResetFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Update Current User
    
    // update the current user object
    func updateCurrentUser(_ user: User) {
        currentUser = user
    }
    
    // refresh user data from database
    func refreshCurrentUser() async {
        guard let user = currentUser else { return }
        do {
            currentUser = try await SupabaseService.shared.fetchUser(byID: user.id)
        } catch {
            print("[AuthManager] Error refreshing user: \(error)")
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case userNotFound
    case invalidPassword
    case emailAlreadyExists
    case invalidUserID
    case signInFailed(String)
    case signUpFailed(String)
    case oauthFailed(String)
    case passwordResetFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No account found with this email"
        case .invalidPassword:
            return "Incorrect password"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .invalidUserID:
            return "Invalid user ID format"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signUpFailed(let message):
            return "Sign up failed: \(message)"
        case .oauthFailed(let message):
            return "OAuth authentication failed: \(message)"
        case .passwordResetFailed(let message):
            return "Password reset failed: \(message)"
        }
    }
}
