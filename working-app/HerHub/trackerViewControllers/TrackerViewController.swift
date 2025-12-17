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
        loadData() // Fetch data
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Modern background gradient (matching Forecast screen)
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.941, blue: 0.961, alpha: 1.0).cgColor, // Lavender Blush #FFF0F5
            UIColor(red: 0.961, green: 0.827, blue: 0.922, alpha: 1.0).cgColor  // Soft pink #F5D3EB
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
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
    
    func loadData() {
        // Use Task since we're calling async functions
        Task {
            do {
                // For MVP, we're using a hardcoded test user ID (same as in JsonManagers)
                let testUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
                
                // 1. Fetch all check-ins
                let checkIns = try await CycleDataController.shared.getCheckIns(forUser: testUserID)
                
                // 2. Find check-in for TODAY
                let today = Date()
                if let todayCheckIn = checkIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                    updateCheckInUI(todayCheckIn)
                } else {
                    // Handle empty state if needed, or clear labels
                     print("No check-in for today yet.")
                }
                
                // 3. Fetch upcoming 7-day forecasts (using dedicated method)
                let upcomingForecasts = try await CycleDataController.shared.getUpcomingForecasts(forUser: testUserID)
                
                // 4. Update UI
                updateForecastUI(upcomingForecasts)
                
            } catch {
                print("Error loading tracker data: \(error)")
            }
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
    

    
    
    
    // MARK: - Update 7-Day Forecast Section (Using forecastContainerView)
    @MainActor
    private func updateForecastUI(_ items: [DailyForecast]) {
        
        guard items.count >= 7 else {
            print("updateForecastUI: Expected 7 forecasts, got \(items.count)")
            return
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        // Safety check: Make sure IBOutlets have exactly 7 labels
        // Note: Check if outlets are connected before accessing count to avoid crash if nil
        guard let dayLabels = dayLabels, dayLabels.count == 7,
              let dateLabels = dateLabels, dateLabels.count == 7,
              let moodLabels = moodLabels, moodLabels.count == 7,
              let fertilityBoxes = fertilityBoxes, fertilityBoxes.count == 7 else {
            print("Forecast UI arrays are not connected or length != 7.")
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


