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
    
    // Save or update a check-in for a user
    func saveCheckIn(_ checkIn: CycleCheckIn, forUser userID: UUID) async throws {
        var checkIn = checkIn
        checkIn.user_id = userID
        
        var checkIns: [CycleCheckIn] = (try? storage.load(from: checkInsFileName)) ?? []
        
        // Update if exists for the same day, else append
        if let index = checkIns.firstIndex(where: { $0.user_id == userID && Calendar.current.isDate($0.date, inSameDayAs: checkIn.date) }) {
            checkIns[index] = checkIn
        } else {
            checkIns.append(checkIn)
        }
        
        try storage.save(checkIns, to: checkInsFileName)
    }
    
    // Fetch all check-ins for a user
    func getCheckIns(forUser userID: UUID) async throws -> [CycleCheckIn] {
        print(" [CycleData] Fetching check-ins for userID: \(userID)")
        let checkIns: [CycleCheckIn] = try storage.load(from: checkInsFileName)
        let filtered = checkIns.filter { $0.user_id == userID }
        print(" [CycleData] Found \(filtered.count) check-ins for user")
        return filtered
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
    // Auto-generates forecasts if none exist or if stale
    func getUpcomingForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        print(" [CycleData] Fetching forecasts for userID: \(userID)")
        let existingForecasts = try await getDailyForecasts(forUser: userID)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        
        let upcomingForecasts = existingForecasts
            .filter { $0.date >= startOfToday }
            .prefix(7)
        
        // If we have less than 7 upcoming forecasts, regenerate
        if upcomingForecasts.count < 7 {
            let newForecasts = try await generateAndSaveForecasts(forUser: userID)
            return Array(newForecasts.prefix(7))
        }
        
        return Array(upcomingForecasts)
    }
    
    // Generate forecasts using CoreML PeriodPredictionService
    func generateAndSaveForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        // Get baseline profile
        guard let baseline = try await getBaselineProfile(forUser: userID) else {
            print("[CycleDataController] No baseline profile for user")
            return []
        }
        

        
        // Generate forecasts using CoreML prediction service
        let forecasts = PeriodPredictionService.shared.generateForecasts(
            baseline: baseline,
            startDate: Date()
        )
   
     
        
        // Save forecasts
        try await saveDailyForecasts(forecasts)
        
        print("[CycleDataController]  Generated \(forecasts.count) forecasts using CoreML")
        return forecasts
    }
    
    // MARK: - Sample Data Initialization
    
    private func initializeSampleDataIfNeeded() {
        if storage.exists(fileName: baselineFileName) {
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
        
        // Generate forecasts using CoreML prediction service
        let forecasts = PeriodPredictionService.shared.generateForecasts(
            baseline: baseline,
            startDate: Date()
        )
        try? storage.save(forecasts, to: forecastsFileName)
        
        print("[CycleDataController] Sample data initialized with CoreML predictions")
    }
}

