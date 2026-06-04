//
//  PeriodPredictionService.swift
//  HerHub
//
//  CoreML-based cycle and period prediction service
//

import CoreML
import Foundation

class PeriodPredictionService {
    
    static let shared = PeriodPredictionService()
    
    private var cycleModel: CyclePredictor?
    private var periodModel: PeriodPredictor?
    
    private init() {
        do {
            self.cycleModel = try CyclePredictor(configuration: MLModelConfiguration())
            self.periodModel = try PeriodPredictor(configuration: MLModelConfiguration())
            print("[PeriodPredictionService] CoreML models loaded")
        } catch {
            print("[PeriodPredictionService] Failed to load CoreML models: \(error)")
        }
    }
    
    func predict(baseline: CycleBaselineProfile) -> (cycleLength: Int, periodLength: Int)? {
        guard let cycleModel = cycleModel, let periodModel = periodModel else {
            print("[PeriodPredictionService]  Models not loaded, using fallback")
            return fallbackPredict(baseline: baseline)
        }
        
        let age = Double(baseline.age)
        let heightCm = baseline.heightCm ?? 165.0
        let weightKg = baseline.weightKg ?? 60.0
        let bmi = weightKg / pow(heightCm / 100.0, 2)
        
        let history = baseline.cycleHistory
        let cycleT1 = history.count > 0 ? Double(history[0]) : 28.0
        let cycleT2 = history.count > 1 ? Double(history[1]) : 28.0
        let cycleT3 = history.count > 2 ? Double(history[2]) : 28.0
        let avgLast3 = history.isEmpty ? 28.0 : Double(history.reduce(0, +)) / Double(history.count)
        
       
        
        do {
            let cycleInput = CyclePredictorInput(
                age: age,
                height_cm: heightCm,
                weight_kg: weightKg,
                bmi: bmi,
                has_pcos: baseline.hasPCOS ? 1.0 : 0.0,
                thyroid_issue: baseline.thyroidIssue ? 1.0 : 0.0,
                work_schedule: Double(baseline.workSchedule),
                diet_quality: Double(baseline.dietQuality),
                caffeine_intake: Double(baseline.caffeineIntake),
                stress_level: Double(baseline.baselineStress),
                sleep_hours: baseline.avgSleepHours,
                exercise_freq: Double(baseline.exercisePerWeek),
                cycle_t1: cycleT1,
                cycle_t2: cycleT2,
                cycle_t3: cycleT3,
                avg_last_3: avgLast3
            )
            
            let periodInput = PeriodPredictorInput(
                age: age,
                height_cm: heightCm,
                weight_kg: weightKg,
                bmi: bmi,
                has_pcos: baseline.hasPCOS ? 1.0 : 0.0,
                thyroid_issue: baseline.thyroidIssue ? 1.0 : 0.0,
                work_schedule: Double(baseline.workSchedule),
                diet_quality: Double(baseline.dietQuality),
                caffeine_intake: Double(baseline.caffeineIntake),
                stress_level: Double(baseline.baselineStress),
                sleep_hours: baseline.avgSleepHours,
                exercise_freq: Double(baseline.exercisePerWeek),
                cycle_t1: cycleT1,
                cycle_t2: cycleT2,
                cycle_t3: cycleT3,
                avg_last_3: avgLast3
            )
            
            let cycleResult = try cycleModel.prediction(input: cycleInput)
            let periodResult = try periodModel.prediction(input: periodInput)
            
            let predictedCycle = max(21, min(45, Int(round(cycleResult.predicted_cycle_length))))
            let predictedPeriod = max(3, min(8, Int(round(periodResult.predicted_period_length))))
            
           
            
            return (predictedCycle, predictedPeriod)
            
        } catch {
            print("[PeriodPredictionService]  Prediction error: \(error)")
            return fallbackPredict(baseline: baseline)
        }
    }
    
    private func fallbackPredict(baseline: CycleBaselineProfile) -> (cycleLength: Int, periodLength: Int) {
        var cycleLength = baseline.baseCycleLength
        let periodLength = baseline.basePeriodLength
        
        if baseline.hasPCOS { cycleLength += 5 }
        if baseline.onBirthControl { cycleLength = 28 }
        if baseline.baselineStress >= 7 { cycleLength += 2 }
        
        return (max(21, min(45, cycleLength)), max(3, min(8, periodLength)))
    }

    func calculateNextPeriodDate(baseline: CycleBaselineProfile) -> Date {
        let prediction = predict(baseline: baseline)
        let cycleLength = prediction?.cycleLength ?? baseline.baseCycleLength
        
        return Calendar.current.date(byAdding: .day, value: cycleLength, to: baseline.lastPeriodStart) ?? Date()
    }
    
    func generateForecasts(baseline: CycleBaselineProfile, startDate: Date = Date()) -> [DailyForecast] {
        let prediction = predict(baseline: baseline)
        let cycleLength = prediction?.cycleLength ?? baseline.baseCycleLength
        let periodLength = prediction?.periodLength ?? baseline.basePeriodLength
        
        let lastPeriodStart = baseline.lastPeriodStart
        
        return (0..<7).map { dayOffset in
            let forecastDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
            
            let daysSinceLastPeriod = Calendar.current.dateComponents([.day], from: lastPeriodStart, to: forecastDate).day ?? 0
            let dayInCycle = (daysSinceLastPeriod % cycleLength) + 1
            
            let phase = determinePhase(dayInCycle: dayInCycle, cycleLength: cycleLength, periodLength: periodLength)
            let fertility = determineFertility(dayInCycle: dayInCycle, cycleLength: cycleLength)
            let energy = determineEnergy(phase: phase)
            let confidence = calculateConfidence(baseline: baseline) // Use the same confidence for all 7 days for now
            
            return DailyForecast(
                id: UUID(),
                user_id: baseline.user_id,
                date: forecastDate,
                phase: phase,
                fertility: fertility,
                energy: energy,
                weatherDescription: getPhaseDescription(phase: phase),
                mood: getMood(for: phase),
                symptoms: getSymptoms(for: phase, dayInCycle: dayInCycle),
                recommendations: getRecommendations(for: phase),
                confidence: confidence
            )
        }
    }
    
    func calculateConfidence(baseline: CycleBaselineProfile) -> Double {
        let history = baseline.cycleHistory
        if history.isEmpty { return 0.7 } 
        
        let average = Double(history.reduce(0, +)) / Double(history.count)
       
        let sumOfSquaredDiffs = history.map { pow(Double($0) - average, 2.0) }.reduce(0, +)
        let standardDeviation = sqrt(sumOfSquaredDiffs / Double(history.count))
        
        let confidence = 1.0 - (standardDeviation / average)
        return max(0.4, min(1.0, confidence)) 
    }
    
    func getLateDays(baseline: CycleBaselineProfile, cycleLength: Int) -> Int {
        let lastPeriod = baseline.lastPeriodStart
        let expectedNext = Calendar.current.date(byAdding: .day, value: cycleLength, to: lastPeriod)!
        
        let startOfExpected = Calendar.current.startOfDay(for: expectedNext)
        let today = Calendar.current.startOfDay(for: Date())
        
        if today > startOfExpected {
            return Calendar.current.dateComponents([.day], from: startOfExpected, to: today).day ?? 0
        }
        return 0
    }
    
    func getMismatchInsight(phase: CyclePhase, actualEnergy: String, baseline: CycleBaselineProfile) -> (insight: String, isAnomaly: Bool)? {
        let expectedEnergy = determineEnergy(phase: phase)
       
        if (expectedEnergy == .high || expectedEnergy == .medium) && actualEnergy.lowercased() == "low" {
          
            if baseline.baselineStress >= 7 {
                return (insight: "Lower energy than expected for the \(phase.rawValue.capitalized) phase? Your High Stress baseline can sometimes delay the usual Estrogen energy peak.", isAnomaly: true)
            }
           
            let heightCm = baseline.heightCm ?? 165.0
            let weightKg = baseline.weightKg ?? 60.0
            let bmi = weightKg / pow(heightCm / 100.0, 2)
            if bmi > 25.0 || bmi < 18.5 {
                return (insight: "Feeling low energy? Your BMI suggest metabolic fluctuations that might be dampening your hormonal energy today.", isAnomaly: true)
            }
           
            return (insight: "Estrogen is usually rising now. If you're feeling low, your body might be prioritizing recovery over activity today.", isAnomaly: true)
        }
      
        if phase == .luteal && actualEnergy.lowercased() == "high" {
            return (insight: "Feeling high energy during your Luteal phase? That's great! Your body is responding exceptionally well to your current routine.", isAnomaly: false)
        }
        
        return nil
    }
   
    func analyzeLatenessReasons(checkIns: [CycleCheckIn], baseline: CycleBaselineProfile) -> String? {

        let recentCheckIns = checkIns.sorted(by: { $0.date > $1.date }).prefix(10) // Look at last 10 entries
        
        guard !recentCheckIns.isEmpty else { return nil }
      
        let avgStress = Double(recentCheckIns.map { $0.currentStress }.reduce(0, +)) / Double(recentCheckIns.count)
        if avgStress >= 6.5 {
            return "High stress levels detected recently (Avg: \(String(format: "%.1f", avgStress))/10). Cortisol can delay ovulation and push back your period."
        }
        
        let avgSleep = Double(recentCheckIns.map { $0.sleepHours }.reduce(0, +)) / Double(recentCheckIns.count)
        if avgSleep < 6.0 {
            return "Consistent lack of sleep (Avg: \(String(format: "%.1f", avgSleep))h) may be disrupting your hormonal rhythm, causing a delay."
        }
        
        let intenseExerciseCount = recentCheckIns.filter { $0.exerciseChange == .more }.count
        if intenseExerciseCount >= 3 {
             return "Recent increases in exercise intensity detected. Sudden physical changes can sometimes temporarily delay your cycle."
        }
        
        if baseline.hasPCOS {
            return "Delays are common with PCOS due to irregular ovulation. Monitor for any new symptoms."
        }
        
        return "Your cycle might just be fluctuating naturally. Keep logging to help the AI adapt."
    }
    
    func calculateBioCapacity(phase: CyclePhase, checkIn: CycleCheckIn?, baseline: CycleBaselineProfile) -> Int {
      
        let hormonalBaseline: Int = {
            switch phase {
            case .menstrual: return 40   // Low estrogen/progesterone
            case .follicular: return 85  // Rising estrogen
            case .ovulation: return 95   // Peak estrogen
            case .luteal: return 65      // Progesterone dominant
            }
        }()
        
        var penalties = 0
        
        if let checkIn = checkIn {
           
            if checkIn.sleepHours < 7 {
                penalties += Int((7 - checkIn.sleepHours) * 5)
            }
            
            
            if checkIn.currentStress > 5 {
                penalties += (checkIn.currentStress - 5) * 3
            }
        
            if checkIn.exerciseChange == .less || checkIn.exerciseChange == .more {
                penalties += 10
            }
        } else {
       
            if baseline.baselineStress > 5 {
                penalties += (baseline.baselineStress - 5) * 3
            }
        }
        
 
        return max(0, min(100, hormonalBaseline - penalties))
    }
    
    
    private func determinePhase(dayInCycle: Int, cycleLength: Int, periodLength: Int) -> CyclePhase {
        if dayInCycle <= periodLength {
            return .menstrual
        } else if dayInCycle <= cycleLength / 2 - 2 {
            return .follicular
        } else if dayInCycle <= cycleLength / 2 + 2 {
            return .ovulation
        } else {
            return .luteal
        }
    }
    
    private func determineFertility(dayInCycle: Int, cycleLength: Int) -> FertilityLevel {
        let ovulationDay = cycleLength / 2
        let distance = abs(dayInCycle - ovulationDay)
        
        if distance <= 2 { return .high }
        else if distance <= 5 { return .med }
        else { return .low }
    }
    
    private func determineEnergy(phase: CyclePhase) -> EnergyLevel {
        switch phase {
        case .menstrual: return .low
        case .follicular: return .high
        case .ovulation: return .high
        case .luteal: return .medium
        }
    }
    
    private func getMood(for phase: CyclePhase) -> String {
        switch phase {
        case .menstrual: return "May feel tired, introspective"
        case .follicular: return "Rising energy, optimistic"
        case .ovulation: return "Confident, social, energetic"
        case .luteal: return "Calm, turning inward"
        }
    }
    
    private func getSymptoms(for phase: CyclePhase, dayInCycle: Int) -> [Symptom] {
        switch phase {
        case .menstrual:
            return [Symptom(name: "Cramps", intensity: dayInCycle <= 2 ? 7 : 4), Symptom(name: "Fatigue", intensity: 5)]
        case .follicular:
            return []
        case .ovulation:
            return [Symptom(name: "Mild cramping", intensity: 2)]
        case .luteal:
            return [Symptom(name: "Bloating", intensity: 4), Symptom(name: "Mood changes", intensity: 3)]
        }
    }
    
    private func getRecommendations(for phase: CyclePhase) -> [String] {
        switch phase {
        case .menstrual:
            return ["Rest and gentle movement", "Iron-rich foods", "Warm compresses for cramps"]
        case .follicular:
            return ["Great time for new projects", "High-intensity workouts", "Creative work"]
        case .ovulation:
            return ["Peak energy - tackle challenges", "Strength training", "Important conversations"]
        case .luteal:
            return ["Prioritize self-care", "Moderate exercise", "Extra sleep if needed"]
        }
    }
    
    private func getPhaseDescription(phase: CyclePhase) -> String {
        switch phase {
        case .menstrual: return "Your body is renewing. Honor your need for rest."
        case .follicular: return "Estrogen is rising, bringing fresh energy."
        case .ovulation: return "You're at your peak! Energy is high."
        case .luteal: return "Progesterone rises. Time to wind down."
        }
    }
}
