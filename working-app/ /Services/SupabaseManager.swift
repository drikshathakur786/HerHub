//
//  SupabaseManager.swift
//  HerHub
//
//  Supabase client configuration and management
//

import Foundation
import Supabase

/// Centralized Supabase client manager
/// Replace the URL and ANON_KEY with your actual Supabase project credentials
final class SupabaseManager {
    
    // MARK: - Singleton
    static let shared = SupabaseManager()
    
    // MARK: - Configuration
    private let supabaseURL: URL = URL(string: "https://xcjulmctkuisrlxuvuzj.supabase.co")!
    private let supabaseAnonKey: String = "sb_publishable_oCHM7ltK5xwqFI1JT6IsHA_ta6AbTqW"
    
    // MARK: - Client
    let client: SupabaseClient
    
    // MARK: - Initialization
    private init() {
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
        
        print("[SupabaseManager] Initialized with URL: \(supabaseURL.absoluteString)")
    }
    
    // MARK: - Auth Helpers
    
    /// Get the current authenticated user ID
    var currentUserID: UUID? {
        return client.auth.currentSession?.user.id
    }
    
    /// Get the current session
    var currentSession: Session? {
        return client.auth.currentSession
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return client.auth.currentSession != nil
    }
}

// MARK: - Table Names
extension SupabaseManager {
    struct Tables {
        static let users = "users"
        static let communities = "communities"
        static let posts = "posts"
        static let comments = "comments"
        static let reports = "reports"
        static let cycleCheckIns = "cycle_checkins"
        static let cyclePredictions = "cycle_predictions"
        static let dailyForecasts = "daily_forecasts"
    }
}

// MARK: - Storage Buckets
extension SupabaseManager {
    struct StorageBuckets {
        static let userAvatars = "user-avatars"
        static let postImages = "post-images"
    }
}

