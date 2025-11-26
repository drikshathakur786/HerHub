import Foundation
import Supabase

class CycleDataManager {
    static let shared = CycleDataManager()
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Baseline
    func saveBaselineProfile(_ profile: CycleBaselineProfile, forUser userID: UUID) async throws {
        var profileWithUser = profile
        profileWithUser.user_id = userID
        _ = try await client
            .from("cycle_baseline_profiles")
            .insert(profileWithUser)
            .execute()
    }

    func fetchBaselineProfile(forUser userID: UUID) async throws -> [CycleBaselineProfile] {
        let res: PostgrestResponse<[CycleBaselineProfile]> = try await client
            .from("cycle_baseline_profiles")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
        return res.value
    }

    // MARK: - Check-in
    func saveCheckIn(_ checkIn: CycleCheckIn, forUser userID: UUID) async throws {
        var newCheck = checkIn
        newCheck.user_id = userID
        _ = try await client
            .from("cycle_check_ins")
            .insert(newCheck)
            .execute()
    }

    func fetchCheckIns(forUser userID: UUID) async throws -> [CycleCheckIn] {
        let res: PostgrestResponse<[CycleCheckIn]> = try await client
            .from("cycle_check_ins")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
        return res.value
    }

    // MARK: - Daily Forecasts
    func saveDailyForecast(_ forecast: DailyForecast) async throws {
        _ = try await client
            .from("daily_forecasts")
            .insert(forecast)
            .execute()
    }

    func saveDailyForecastList(_ forecasts: [DailyForecast]) async throws {
        _ = try await client
            .from("daily_forecasts")
            .insert(forecasts)   // <-- direct Encodable array insert
            .execute()
    }

    func fetchDailyForecasts(forUser userID: UUID) async throws -> [DailyForecast] {
        let res: PostgrestResponse<[DailyForecast]> = try await client
            .from("daily_forecasts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("date", ascending: true)
            .limit(7)
            .execute()
        return res.value
    }
}
