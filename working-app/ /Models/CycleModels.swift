//
//  CycleModels.swift
//  HerHub
//
//  Created by Nihar Sandhu on 28/10/25.
//

import Foundation

struct CycleBaselineProfile: Codable, Equatable {
    var user_id: UUID
    var age: Int
    var baseCycleLength: Int
    var basePeriodLength: Int
    var onBirthControl: Bool
    var hasPCOS: Bool
    var exercisePerWeek: Int  
    var avgSleepHours: Double
    var baselineStress: Int
    var lastPeriodStart: Date
    
    var heightCm: Double?       
    var weightKg: Double?       
    var thyroidIssue: Bool      
    var workSchedule: Int      
    var dietQuality: Int        
    var caffeineIntake: Int     
    var cycleHistory: [Int]     

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
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case thyroidIssue = "thyroid_issue"
        case workSchedule = "work_schedule"
        case dietQuality = "diet_quality"
        case caffeineIntake = "caffeine_intake"
        case cycleHistory = "cycle_history"
    }
}

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
    var isAnomaly: Bool = false

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
        case isAnomaly = "is_anomaly"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        date = try container.decode(Date.self, forKey: .date)
        symptomsPresent = try container.decode(Bool.self, forKey: .symptomsPresent)
        currentStress = try container.decode(Int.self, forKey: .currentStress)
        sleepHours = try container.decode(Double.self, forKey: .sleepHours)
        sickOrMeds = try container.decode(Bool.self, forKey: .sickOrMeds)
        exerciseChange = try container.decode(ExerciseChange.self, forKey: .exerciseChange)
        periodStartedToday = try container.decodeIfPresent(Bool.self, forKey: .periodStartedToday)
        isAnomaly = try container.decodeIfPresent(Bool.self, forKey: .isAnomaly) ?? false
    }
    
    init(id: UUID = UUID(), user_id: UUID, date: Date, symptomsPresent: Bool, currentStress: Int, sleepHours: Double, sickOrMeds: Bool, exerciseChange: ExerciseChange, periodStartedToday: Bool? = nil, isAnomaly: Bool = false) {
        self.id = id
        self.user_id = user_id
        self.date = date
        self.symptomsPresent = symptomsPresent
        self.currentStress = currentStress
        self.sleepHours = sleepHours
        self.sickOrMeds = sickOrMeds
        self.exerciseChange = exerciseChange
        self.periodStartedToday = periodStartedToday
        self.isAnomaly = isAnomaly
    }
}

enum ExerciseChange: String, Codable, CaseIterable {
    case less, same, more
}

struct CyclePrediction: Codable, Equatable {
    var predicted_cycle_length: Int
    var predicted_next_period_start: Date

    enum CodingKeys: String, CodingKey {
        case predicted_cycle_length = "predicted_cycle_length"
        case predicted_next_period_start = "predicted_next_period_start"
    }
}


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
    var confidence: Double // 0.0 to 1.0

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
        case confidence
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        date = try container.decode(Date.self, forKey: .date)
        phase = try container.decode(CyclePhase.self, forKey: .phase)
        fertility = try container.decode(FertilityLevel.self, forKey: .fertility)
        energy = try container.decode(EnergyLevel.self, forKey: .energy)
        weatherDescription = try container.decode(String.self, forKey: .weatherDescription)
        mood = try container.decode(String.self, forKey: .mood)
        symptoms = try container.decode([Symptom].self, forKey: .symptoms)
        recommendations = try container.decode([String].self, forKey: .recommendations)
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence) ?? 0.7
    }
    
    init(id: UUID, user_id: UUID, date: Date, phase: CyclePhase, fertility: FertilityLevel, energy: EnergyLevel, weatherDescription: String, mood: String, symptoms: [Symptom], recommendations: [String], confidence: Double) {
        self.id = id
        self.user_id = user_id
        self.date = date
        self.phase = phase
        self.fertility = fertility
        self.energy = energy
        self.weatherDescription = weatherDescription
        self.mood = mood
        self.symptoms = symptoms
        self.recommendations = recommendations
        self.confidence = confidence
    }
}


struct Symptom: Codable, Equatable {
    var name: String
    var intensity: Int
}

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

extension CycleBaselineProfile {
    static func sample(userID: UUID = UUID()) -> CycleBaselineProfile {
        return CycleBaselineProfile(
            user_id: userID,
            age: 23,
            baseCycleLength: 28,
            basePeriodLength: 5,
            onBirthControl: false,
            hasPCOS: false,
            exercisePerWeek: 3,
            avgSleepHours: 7.0,
            baselineStress: 5,
            lastPeriodStart: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
            heightCm: 165.0,
            weightKg: 58.0,
            thyroidIssue: false,
            workSchedule: 0,
            dietQuality: 6,
            caffeineIntake: 2,
            cycleHistory: [28, 29, 27]
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
                recommendations: ["Recommendation \(i)"],
                confidence: 0.85
            )
        }
    }
}

extension CyclePrediction {
    static func sample() -> CyclePrediction {
        return CyclePrediction(
            predicted_cycle_length: 28,
            predicted_next_period_start: Calendar.current.date(byAdding: .day, value: 28, to: Date())!
        )
    }
}
