import Foundation

final class CycleDataController {
    static let shared = CycleDataController()
    private let manager = CycleDataManager.shared
    
    private init() {}

    // MARK: - Baseline
    func uploadBaselineProfile(_ profile: CycleBaselineProfile, forUser userID: UUID) async throws {
        try await manager.saveBaselineProfile(profile, forUser: userID)
    }
    
    func getBaselineProfile(forUser userID: UUID) async throws -> CycleBaselineProfile? {
        return try await manager.fetchBaselineProfile(forUser: userID).first
    }

    // MARK: - Check-In
    func uploadCheckIn(_ checkIn: CycleCheckIn, forUser userID: UUID) async throws {
        try await manager.saveCheckIn(checkIn, forUser: userID)
    }

    func getCheckIns(forUser userID: UUID) async throws -> [CycleCheckIn] {
        return try await manager.fetchCheckIns(forUser: userID)
    }

    // MARK: - Daily Forecasts
    func uploadDailyForecasts(_ list: [DailyForecast]) async throws {
        try await manager.saveDailyForecastList(list)
    }

    func getDailyForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        try await manager.fetchDailyForecasts(forUser: userID)
    }
}
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dict = jsonObject as? [String: Any] else {
            throw NSError(
                domain: "Encodable.asDictionary",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"]
            )
        }
        return dict
    }
}
