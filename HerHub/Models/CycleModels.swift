//
//  CycleModels.swift
//  HerHub
//
//  Created by Nihar Sandhu on 28/10/25.
//

import Foundation

// MARK: - One-Time Baseline Profile
struct CycleBaselineProfile: Codable, Equatable {
    var user_id: UUID
    var age: Int
    var baseCycleLength: Int
    var basePeriodLength: Int
    var onBirthControl: Bool
    var hasPCOS: Bool
    var exercisePerWeek: String
    var avgSleepHours: Double
    var baselineStress: Int
    var lastPeriodStart: Date

    enum CodingKeys: String, CodingKey {
        case user_id = "user_id"
        case age
        case baseCycleLength = "base_cycle_length"
        case basePeriodLength = "base_period_length"
        case onBirthControl = "on_birth_control"
        case hasPCOS = "has_pcos"
        case exercisePerWeek = "exercise_per_week"
        case avgSleepHours = "avg_sleep_hours"
        case baselineStress = "baseline_stress"
        case lastPeriodStart = "last_period_start"
    }
}

// MARK: - Recurring Check-In
struct CycleCheckIn: Codable, Equatable {
    var id = UUID()
    var user_id: UUID
    var date: Date
    var symptomsPresent: Bool
    var currentStress: Int
    var sleepHours: Double
    var sickOrMeds: Bool
    var exerciseChange: ExerciseChange
    var periodStartedToday: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case user_id = "user_id"
        case date
        case symptomsPresent = "symptoms_present"
        case currentStress = "current_stress"
        case sleepHours = "sleep_hours"
        case sickOrMeds = "sick_or_meds"
        case exerciseChange = "exercise_change"
        case periodStartedToday = "period_started_today"
    }
}

enum ExerciseChange: String, Codable, CaseIterable {
    case less, same, more
}

// MARK: - Cycle Prediction Summary
struct CyclePrediction: Codable, Equatable {
    var predicted_cycle_length: Int
    var predicted_next_period_start: Date

    enum CodingKeys: String, CodingKey {
        case predicted_cycle_length = "predicted_cycle_length"
        case predicted_next_period_start = "predicted_next_period_start"
    }
}


// MARK: - 7-Day Forecast Data (direct per-user)
struct DailyForecast: Codable, Equatable {
    var id = UUID()
    var user_id: UUID
    var date: Date
    var phase: CyclePhase
    var fertility: FertilityLevel
    var energy: EnergyLevel
    var weatherDescription: String
    var mood: String
    var symptoms: [Symptom]
    var recommendations: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case user_id = "user_id"
        case date
        case phase
        case fertility
        case energy
        case weatherDescription = "weather_description"
        case mood
        case symptoms
        case recommendations
    }
}


struct Symptom: Codable, Equatable {
    var name: String
    var intensity: Int
}

// MARK: - Enums
enum CyclePhase: String, Codable {
    case menstrual, follicular, ovulation, luteal
}

enum FertilityLevel: String, Codable {
    case low, med, high
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .med: return "Med"
        case .high: return "High"
        }
    }
}

enum EnergyLevel: String, Codable {
    case high, medium, low
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

// MARK: - Sample Data
extension CycleBaselineProfile {
    static func sample(userID: UUID = UUID()) -> CycleBaselineProfile {
        return CycleBaselineProfile(
            user_id: userID,
        age: 23,
        baseCycleLength: 28,
        basePeriodLength: 5,
        onBirthControl: false,
        hasPCOS: false,
        exercisePerWeek: "3–5x",
        avgSleepHours: 7.0,
        baselineStress: 5,
        lastPeriodStart: Calendar.current.date(byAdding: .day, value: -20, to: Date())!
    )
    }
}

extension CycleCheckIn {
    static func sample(userID: UUID = UUID()) -> CycleCheckIn {
        return CycleCheckIn(
            id: UUID(),
            user_id: userID,
        date: Date(),
        symptomsPresent: true,
        currentStress: 6,
        sleepHours: 7.5,
        sickOrMeds: false,
        exerciseChange: .same,
        periodStartedToday: false
    )
    }
}

extension DailyForecast {
    static func sampleList(start: Date = Date(), userID: UUID = UUID()) -> [DailyForecast] {
        return (0..<7).map { i in
            DailyForecast(
                id: UUID(),
                user_id: userID,
                date: Calendar.current.date(byAdding: .day, value: i, to: start)!,
                phase: [.follicular, .ovulation, .luteal, .menstrual][i % 4],
                fertility: [.low, .med, .high][i % 3],
                energy: [.high, .medium, .low][i % 3],
                weatherDescription: "Sample Forecast \(i)",
                mood: "Mood \(i)",
                symptoms: [],
                recommendations: ["Recommendation \(i)"]
            )
        }
    }
}

// MARK: - Sample for CyclePrediction
extension CyclePrediction {
    static func sample() -> CyclePrediction {
        return CyclePrediction(
            predicted_cycle_length: 28,
            predicted_next_period_start: Calendar.current.date(byAdding: .day, value: 28, to: Date())!
        )
    }
}
