//
//  CycleDataController.swift
//  HerHub
//
//  Created by Dhruv on 10/11/25.


import Foundation

// Controller for Cycle Data CRUD operations using local JSON storage
final class CycleDataController {
    
    static let shared = CycleDataController()
    
    private let storage = JsonStorageManager.shared
    
    // File names for each data type
    private let baselineFileName = "baseline_profiles"
    private let checkInsFileName = "check_ins"
    private let forecastsFileName = "daily_forecasts"
    
    private init() {
        initializeSampleDataIfNeeded()
    }
    
    // MARK: - Baseline Profile
    
    // Save or update baseline profile for a user
    func saveBaselineProfile(_ profile: CycleBaselineProfile, forUser userID: UUID) async throws {
        var profile = profile
        profile.user_id = userID
        
        var profiles: [CycleBaselineProfile] = (try? storage.load(from: baselineFileName)) ?? []
        
        // Replace if exists, else append
        if let index = profiles.firstIndex(where: { $0.user_id == userID }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        
        try storage.save(profiles, to: baselineFileName)
    }
    
    // Fetch baseline profile for a user
    func getBaselineProfile(forUser userID: UUID) async throws -> CycleBaselineProfile? {
        let profiles: [CycleBaselineProfile] = try storage.load(from: baselineFileName)
        return profiles.first { $0.user_id == userID }
    }
    
    // MARK: - Check-Ins
    
    // Save a new check-in for a user
    func saveCheckIn(_ checkIn: CycleCheckIn, forUser userID: UUID) async throws {
        var checkIn = checkIn
        checkIn.user_id = userID
        
        var checkIns: [CycleCheckIn] = (try? storage.load(from: checkInsFileName)) ?? []
        checkIns.append(checkIn)
        try storage.save(checkIns, to: checkInsFileName)
    }
    
    // Fetch all check-ins for a user
    func getCheckIns(forUser userID: UUID) async throws -> [CycleCheckIn] {
        let checkIns: [CycleCheckIn] = try storage.load(from: checkInsFileName)
        return checkIns.filter { $0.user_id == userID }
    }
    
    // Fetch today's check-in for a user
    func getTodayCheckIn(forUser userID: UUID) async throws -> CycleCheckIn? {
        let checkIns = try await getCheckIns(forUser: userID)
        let today = Date()
        return checkIns.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    // MARK: - Daily Forecasts
    
    // Save list of forecasts (replaces existing for same user)
    func saveDailyForecasts(_ forecasts: [DailyForecast]) async throws {
        var existingForecasts: [DailyForecast] = (try? storage.load(from: forecastsFileName)) ?? []
        
        // Remove old forecasts for users in the new list
        let newUserIDs = Set(forecasts.map { $0.user_id })
        existingForecasts.removeAll { newUserIDs.contains($0.user_id) }
        
        existingForecasts.append(contentsOf: forecasts)
        try storage.save(existingForecasts, to: forecastsFileName)
    }
    
    // Fetch forecasts for a user (sorted by date)
    func getDailyForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        let forecasts: [DailyForecast] = try storage.load(from: forecastsFileName)
        return forecasts
            .filter { $0.user_id == userID }
            .sorted { $0.date < $1.date }
    }
    
    // Fetch upcoming 7-day forecast for a user (from today)
    func getUpcomingForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        let forecasts = try await getDailyForecasts(forUser: userID)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        
        return Array(
            forecasts
                .filter { $0.date >= startOfToday }
                .prefix(7)
        )
    }
    
    // MARK: - Sample Data Initialization
    
    private func initializeSampleDataIfNeeded() {
        if storage.exists(fileName: forecastsFileName) {
            print("[CycleDataController] Data files exist")
            return
        }
        
        print("[CycleDataController] Initializing sample data...")
        
        let testUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
        
        // Sample baseline
        let baseline = CycleBaselineProfile.sample(userID: testUserID)
        try? storage.save([baseline], to: baselineFileName)
        
        // Sample check-in
        let checkIn = CycleCheckIn.sample(userID: testUserID)
        try? storage.save([checkIn], to: checkInsFileName)
        
        // 7-day forecast
        let forecasts = DailyForecast.sampleList(start: Date(), userID: testUserID)
        try? storage.save(forecasts, to: forecastsFileName)
        
        print("[CycleDataController] Sample data initialized")
    }
}
