import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var checkInContainerView: UIView!
    @IBOutlet weak var forecastContainerView: UIView!
    @IBOutlet weak var todayInsightContainerView: UIView!
    
    @IBOutlet weak var insightTitleLabel: UILabel!
    @IBOutlet weak var insightDescriptionLabel: UILabel!
    
    @IBOutlet weak var moodValueLabel: UILabel!
    
    @IBOutlet weak var cycleDayValueLabel: UILabel!
    @IBOutlet weak var nextPeriodValueLabel: UILabel!
    
    @IBOutlet weak var energyValueLabel: UILabel!
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet var dateLabels: [UILabel]!
    @IBOutlet var moodLabels: [UILabel]!
    @IBOutlet var fertilityBoxes: [UILabel]!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationTitle()
//        DummyDataSeeder.seedAllDummyData()
      

    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Modern background gradient (matching Forecast screen)
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(hex: "#FFF0F5").cgColor, // Lavender Blush
            UIColor(hex: "#F5D3EB").cgColor  // Soft pink
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        // Animate cards on load
        let cards = [checkInContainerView, forecastContainerView, todayInsightContainerView]
        for (index, card) in cards.enumerated() {
            card?.animateIn(delay: 0.1 * Double(index))
        }
        
        debugLoadUserData(email: "beth@herhub.com")
    }
    
    private func setupNavigationTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Body Climate"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.82, green: 0.23, blue: 0.56, alpha: 1) // Figma pink
        titleLabel.textAlignment = .left
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let currentDate = dateFormatter.string(from: Date())
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = currentDate
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .left
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        
        navigationItem.titleView = stack
    }

    
    
    
    
    // Update gradient on layout changes (important!)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame if it exists
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}






// MARK: - Load Cycle Data
extension TrackerViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task { await loadCycleData() }
    }
    
    // MARK: - Debug Function: Load User Data by Email
    /// Call this to fetch + display ALL user-related data in console + UI
    /// Example: debugLoadUserData(email: "alice@herhub.com")
    func debugLoadUserData(email: String) {
        Task {
            do {
                print("\n🔍 [DEBUG] Loading user data for: \(email)")

                // ------------------------------------------------------
                // 1️⃣ Fetch USER
                // ------------------------------------------------------
                guard let user = try await UserController.shared.fetchUser(byEmail: email) else {
                    print("❌ [DEBUG] User not found for email:", email)
                    await showDebugAlertAsync(
                        title: "User Not Found",
                        message: "No user found with email: \(email)"
                    )
                    return
                }

                print("👤 [DEBUG] User found")
                print("   - ID: \(user.id.uuidString)")
                print("   - Email: \(user.email ?? "nil")")
                print("   - Phone: \(user.phoneNumber ?? "nil")")

                // ------------------------------------------------------
                // 2️⃣ Fetch Baseline Profile
                // ------------------------------------------------------
                if let baseline = try await CycleDataController.shared.getBaselineProfile(forUser: user.id) {
                    print("📊 [DEBUG] Baseline Profile:")
                    print("   - Age: \(baseline.age)")
                    print("   - Cycle Length: \(baseline.baseCycleLength)")
                    print("   - Period Length: \(baseline.basePeriodLength)")
                    print("   - Last Period Start: \(baseline.lastPeriodStart)")
                    print("   - On Birth Control: \(baseline.onBirthControl)")
                    print("   - Has PCOS: \(baseline.hasPCOS)")
                } else {
                    print("⚠️ [DEBUG] No baseline profile found for this user")
                }

                // ------------------------------------------------------
                // 3️⃣ Fetch All Check-ins
                // ------------------------------------------------------
                let checkIns = try await CycleDataController.shared.getCheckIns(forUser: user.id)
                
                if !checkIns.isEmpty {
                    print("📝 [DEBUG] Check-ins: \(checkIns.count) found")
                    for (i, c) in checkIns.enumerated() {
                        print("   Check-in \(i+1):")
                        print("     - ID: \(c.id.uuidString)")
                        print("     - Date: \(c.date)")
                        print("     - Symptoms: \(c.symptomsPresent)")
                        print("     - Stress: \(c.currentStress)")
                        print("     - Sleep: \(c.sleepHours)")
                        print("     - Period Started: \(c.periodStartedToday ?? false)")
                    }

                    // Update UI with latest
                    if let last = checkIns.last {
                        await MainActor.run {
                            self.updateCheckInUI(last)
                        }
                    }
                } else {
                    print("⚠️ [DEBUG] No check-ins found")
                }

                // ------------------------------------------------------
                // 4️⃣ Get Prediction from User (stored in user.latestPrediction JSONB field)
                // ------------------------------------------------------
                if let prediction = user.latestPrediction {
                    print("🔮 [DEBUG] Latest Prediction (from user.latest_prediction):")
                    print("   - Cycle Length: \(prediction.predicted_cycle_length)")
                    print("   - Next Period: \(prediction.predicted_next_period_start)")
                } else {
                    print("⚠️ [DEBUG] No prediction found in user.latestPrediction")
                }

                // ------------------------------------------------------
                // 5️⃣ Fetch DAILY FORECASTS for this user
                // ------------------------------------------------------
                do {
                    let forecasts = try await CycleDataController.shared.getDailyForecasts(forUser: user.id)

                    if forecasts.isEmpty {
                        print("⚠️ [DEBUG] No daily forecasts found for user")
                    } else {
                        print("🌤️ [DEBUG] Daily Forecasts: \(forecasts.count) found")
                        for (i, f) in forecasts.enumerated() {
                            print("   Day \(i+1):")
                            print("     - Date: \(f.date)")
                            print("     - Phase: \(f.phase.rawValue)")
                            print("     - Fertility: \(f.fertility.rawValue)")
                            print("     - Energy: \(f.energy.rawValue)")
                            print("     - Mood: \(f.mood)")
                            print("     - Weather: \(f.weatherDescription)")
                            print("     - Symptoms: \(f.symptoms.count)")
                            print("     - Recommendations: \(f.recommendations.count)")
                        }

                        // Update UI
                        await MainActor.run {
                            self.updateForecastUI(forecasts)
                            self.updateInsightUI(for: user.id)
                        }
                    }
                } catch {
                    print("❌ [DEBUG] Error fetching forecasts:", error)
                    print("   Error details:", error.localizedDescription)
                    // Don't throw - continue to show success message
                }

                // ------------------------------------------------------
                print("✅ [DEBUG] FINISHED loading data for:", email)
                await showDebugAlertAsync(
                    title: "Debug Loaded",
                    message: "User data for \(email) has been loaded and displayed."
                )

            } catch {
                print("❌ [DEBUG] Error:", error)
                await showDebugAlertAsync(
                    title: "Error",
                    message: "Failed to load user data: \(error.localizedDescription)"
                )
            }
        }
    }

    // MARK: - Alert Helper (async)
    @MainActor
    private func showDebugAlertAsync(title: String, message: String) async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    
    
    
    
    private func loadCycleData() async {
        do {
            // 1️⃣ Get user (TEMP until auth)
            guard let user = try await UserController.shared.fetchUser(byEmail: "carol@herhub.com") else {
                print("❌ No user found")
                return
            }
            
            // 2️⃣ Get last check-in FOR this user
            do {
                let checkIns = try await CycleDataController.shared.getCheckIns(forUser: user.id)
                if let last = checkIns.last {
                    DispatchQueue.main.async {
                        self.updateCheckInUI(last)
                    }
                }
            } catch {
                print("⚠️ Error loading check-ins:", error.localizedDescription)
            }
            
            // 3️⃣ Fetch this user's 7 daily forecasts
            do {
                let forecasts = try await CycleDataController.shared.getDailyForecasts(forUser: user.id)
                
                guard !forecasts.isEmpty else {
                    print("⚠️ No daily forecasts found")
                    return
                }
                
                // 4️⃣ Update UI
                DispatchQueue.main.async {
                    self.updateInsightUI(for: user.id)
                    self.updateForecastUI(forecasts)   // <-- IMPORTANT
                }
            } catch {
                print("❌ Error loading forecasts:", error.localizedDescription)
                print("   Full error:", error)
            }
            
        } catch {
            print("❌ Error loading data:", error.localizedDescription)
        }
    }

    
    
    // MARK: - Update Check-In Section
    private func updateCheckInUI(_ checkIn: CycleCheckIn) {
        moodValueLabel.text = checkIn.symptomsPresent ? "Mixed" : "Good"
        cycleDayValueLabel.text = formattedDay(checkIn.date)
        nextPeriodValueLabel.text = checkIn.periodStartedToday == true ? "Started" : "No"
        energyValueLabel.text = checkIn.sleepHours >= 7 ? "High" : "Low"
    }
    
    private func formattedDay(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
    
    // MARK: - Update Insight Section
    private func updateInsightUI(for userID: UUID) {
        Task {
            do {
                // 1️⃣ Fetch this user's 7-day forecasts
                let forecasts = try await CycleDataController.shared.getDailyForecasts(forUser: userID)
                
                // 2️⃣ Find today's forecast
                let todayDate = Calendar.current.startOfDay(for: Date())
                let todayForecast = forecasts.first {
                    Calendar.current.isDate($0.date, inSameDayAs: todayDate)
                }
                
                // 3️⃣ Update UI
                DispatchQueue.main.async {
                    self.insightTitleLabel.text = "Today's Insight"
                    self.insightDescriptionLabel.text =
                    todayForecast?.weatherDescription ?? "No insight available."
                }
                
            } catch {
                print("❌ Error in updateInsightUI:", error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: - Update 7-Day Forecast Section (Using forecastContainerView)
    @MainActor
    private func updateForecastUI(_ items: [DailyForecast]) {
        
        guard items.count >= 7 else {
            print("⚠️ updateForecastUI: Expected 7 forecasts, got \(items.count)")
            return
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        // Safety check: Make sure IBOutlets have exactly 7 labels
        guard dayLabels.count == 7,
              dateLabels.count == 7,
              moodLabels.count == 7,
              fertilityBoxes.count == 7 else {
            print("❌ Forecast UI arrays are not length 7.")
            return
        }
        
        for i in 0..<7 {
            let forecast = items[i]
            
            // DAY LABEL
            dayLabels[i].text = dayFormatter.string(from: forecast.date)
            dayLabels[i].textColor = .systemGray
            dayLabels[i].font = UIFont.systemFont(ofSize: 12, weight: .medium)
            
            // DATE LABEL
            dateLabels[i].text = dateFormatter.string(from: forecast.date)
            dateLabels[i].font = UIFont.boldSystemFont(ofSize: 14)
            dateLabels[i].textColor = .black
            
            // MOOD LABEL (uses phaseDescription added in extension)
            moodLabels[i].text = forecast.phaseDescription
            moodLabels[i].font = UIFont.systemFont(ofSize: 12)
            moodLabels[i].textColor = .systemGray2
            
            // FERTILITY BOX
            let box = fertilityBoxes[i]
            box.text = forecast.fertility.displayName
            box.textAlignment = .center
            box.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            box.textColor = .white
            box.layer.cornerRadius = 6
            box.layer.masksToBounds = true
            
            switch forecast.fertility {
            case .low:
                box.backgroundColor = UIColor(red: 1, green: 0.35, blue: 0.47, alpha: 1) // FF5A78
            case .med:
                box.backgroundColor = UIColor(red: 1, green: 0.80, blue: 0.25, alpha: 1) // FFCC3F
            case .high:
                box.backgroundColor = UIColor(red: 0.25, green: 0.51, blue: 1, alpha: 1) // 3F82FF
            }
        }
    }
}
//    private func loadCycleData() async {
//
//        // --------------------------------------
//        // ✅ DUMMY DATA FOR INSTANT TESTING
//        // --------------------------------------
//
//        let dummyCheckIn = CycleCheckIn(
//            date: Date(),
//            symptomsPresent: false,
//            currentStress: 3,
//            sleepHours: 7.5,
//            sickOrMeds: false,
//            exerciseChange: .same,
//            periodStartedToday: false
//        )
//
//        let dummyForecast: [DailyForecast] = [
//            DailyForecast(
//                date: Date(),
//                phase: .follicular,
//                fertility: .low,
//                energy: .high,
//                weatherDescription: "Sunny: strong focus + energy",
//                mood: "Energetic",
//                symptoms: [],
//                recommendations: ["Go for a walk", "Start a new project"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 1),
//                phase: .follicular,
//                fertility: .med,
//                energy: .high,
//                weatherDescription: "Clear skies: stable mood",
//                mood: "Stable",
//                symptoms: [Symptom(name: "Mild Bloating", intensity: 2)],
//                recommendations: ["Eat well", "Focus on productivity"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 2),
//                phase: .ovulation,
//                fertility: .high,
//                energy: .high,
//                weatherDescription: "Peak day: confidence high",
//                mood: "Confident",
//                symptoms: [Symptom(name: "Increased Libido", intensity: 8)],
//                recommendations: ["Schedule social activities", "Do high-energy tasks"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 3),
//                phase: .luteal,
//                fertility: .med,
//                energy: .medium,
//                weatherDescription: "Cloudy: slight emotional dip",
//                mood: "Moody",
//                symptoms: [Symptom(name: "Cramps", intensity: 3)],
//                recommendations: ["Take rest breaks", "Eat magnesium-rich foods"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 4),
//                phase: .luteal,
//                fertility: .low,
//                energy: .medium,
//                weatherDescription: "Light rain: take breaks",
//                mood: "Calm",
//                symptoms: [Symptom(name: "Headache", intensity: 1)],
//                recommendations: ["Rest as needed"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 5),
//                phase: .menstrual,
//                fertility: .low,
//                energy: .low,
//                weatherDescription: "Rainy day: rest recommended",
//                mood: "Tired",
//                symptoms: [Symptom(name: "Fatigue", intensity: 5)],
//                recommendations: ["Use a heating pad", "Avoid intense workouts"]
//            ),
//            DailyForecast(
//                date: Date().addingTimeInterval(86400 * 6),
//                phase: .menstrual,
//                fertility: .low,
//                energy: .low,
//                weatherDescription: "Heavy clouds: go easy today",
//                mood: "Low",
//                symptoms: [Symptom(name: "Back Pain", intensity: 4)],
//                recommendations: ["Prioritize self-care"]
//            )
//        ]
//
//        // --------------------------------------
//        // 🔥 INJECT DUMMY DATA INTO EXISTING UI
//        // --------------------------------------
//        DispatchQueue.main.async {
//            self.updateCheckInUI(dummyCheckIn)
////            self.updateInsightUI(dummyPrediction)
//            self.updateForecastUI(dummyForecast)
//        }
//
//        // --------------------------------------
//        // ❗ REMOVE BELOW WHEN READY FOR SUPABASE
//        // ❗ Just delete this whole function and restore your old one
//        // --------------------------------------
//    }

extension DailyForecast {
    var phaseDescription: String {
        switch phase {
        case .follicular: return "Good"
        case .ovulation:  return "Happy"
        case .luteal:     return "Okay"
        case .menstrual:  return "Calm"
        }
    }
}


