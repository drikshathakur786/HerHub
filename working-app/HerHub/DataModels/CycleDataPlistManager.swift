//
//  CycleDataPlistManager.swift
//  HerHub
//
//  Local plist storage for cycle data (replaces Supabase)
//

import Foundation

/// Manages local plist storage for cycle-related data
final class CycleDataPlistManager {
    
    static let shared = CycleDataPlistManager()
    
    private let storage = PlistStorageManager.shared
    
    // MARK: - File Names
    private let baselineFileName = "baseline_profiles"
    private let checkInsFileName = "check_ins"
    private let forecastsFileName = "daily_forecasts"
    
    private init() {
        // Initialize with sample data if files don't exist
        initializeSampleDataIfNeeded()
    }
    
    // MARK: - Baseline Profile
    
    func saveBaselineProfile(_ profile: CycleBaselineProfile, forUser userID: UUID) throws {
        var profile = profile
        profile.user_id = userID
        
        // Load existing profiles, replace if exists for this user, otherwise append
        var profiles: [CycleBaselineProfile] = (try? storage.load(from: baselineFileName)) ?? []
        
        if let index = profiles.firstIndex(where: { $0.user_id == userID }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        
        try storage.save(profiles, to: baselineFileName)
    }
    
    func fetchBaselineProfile(forUser userID: UUID) throws -> [CycleBaselineProfile] {
        let profiles: [CycleBaselineProfile] = try storage.load(from: baselineFileName)
        return profiles.filter { $0.user_id == userID }
    }
    
    // MARK: - Check-In
    
    func saveCheckIn(_ checkIn: CycleCheckIn, forUser userID: UUID) throws {
        var checkIn = checkIn
        checkIn.user_id = userID
        
        var checkIns: [CycleCheckIn] = (try? storage.load(from: checkInsFileName)) ?? []
        checkIns.append(checkIn)
        try storage.save(checkIns, to: checkInsFileName)
    }
    
    func fetchCheckIns(forUser userID: UUID) throws -> [CycleCheckIn] {
        let checkIns: [CycleCheckIn] = try storage.load(from: checkInsFileName)
        return checkIns.filter { $0.user_id == userID }
    }
    
    // MARK: - Daily Forecasts
    
    func saveDailyForecast(_ forecast: DailyForecast) throws {
        var forecasts: [DailyForecast] = (try? storage.load(from: forecastsFileName)) ?? []
        forecasts.append(forecast)
        try storage.save(forecasts, to: forecastsFileName)
    }
    
    func saveDailyForecastList(_ forecasts: [DailyForecast]) throws {
        // Load existing, remove old forecasts for same user, add new ones
        var existingForecasts: [DailyForecast] = (try? storage.load(from: forecastsFileName)) ?? []
        
        // Get user IDs from new forecasts
        let newUserIDs = Set(forecasts.map { $0.user_id })
        
        // Remove old forecasts for these users
        existingForecasts.removeAll { newUserIDs.contains($0.user_id) }
        
        // Add new forecasts
        existingForecasts.append(contentsOf: forecasts)
        
        try storage.save(existingForecasts, to: forecastsFileName)
    }
    
    func fetchDailyForecasts(forUser userID: UUID) throws -> [DailyForecast] {
        let forecasts: [DailyForecast] = try storage.load(from: forecastsFileName)
        return forecasts
            .filter { $0.user_id == userID }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - Sample Data Initialization
    
    private func initializeSampleDataIfNeeded() {
        // Check if forecasts already exist
        if storage.exists(fileName: forecastsFileName) {
            print("📁 [CycleDataPlist] Data files already exist, skipping initialization")
            return
        }
        
        print("🌱 [CycleDataPlist] Initializing sample data...")
        
        // Create a test user ID (matches SessionManager test user)
        let testUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        
        // Create sample baseline profile
        let baseline = CycleBaselineProfile.sample(userID: testUserID)
        try? storage.save([baseline], to: baselineFileName)
        
        // Create sample check-in
        let checkIn = CycleCheckIn.sample(userID: testUserID)
        try? storage.save([checkIn], to: checkInsFileName)
        
        // Create 7-day forecast starting from today
        let forecasts = DailyForecast.sampleList(start: Date(), userID: testUserID)
        try? storage.save(forecasts, to: forecastsFileName)
        
        print("✅ [CycleDataPlist] Sample data initialized successfully")
    }
}
