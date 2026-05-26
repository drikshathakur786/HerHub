//
//  ForecastViewController.swift
//  HerHub
//
//  Created by Nihar Sandhu on 18/11/25.
//

import UIKit

class ForecastViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var topDateContainer: UIView!
    @IBOutlet weak var selectedDateView: UIView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var selectedDayLabel: UILabel!
    
    @IBOutlet weak var phaseCard: UIView!
    @IBOutlet weak var fertilityCard: UIView!
    @IBOutlet weak var energyCard: UIView!
    
    // MARK: - Specific Card Outlets (Connect these in Storyboard!)
    @IBOutlet weak var phaseDateLabel: UILabel! 
    @IBOutlet weak var phaseNameLabel: UILabel!
    
    // Legacy Outlets (Do not remove: Storyboard still connects to these)
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    
    @IBOutlet weak var fertilityValueLabel: UILabel!
    @IBOutlet weak var energyTitleLabel: UILabel!
    @IBOutlet weak var energyValueLabel: UILabel!
    
    @IBOutlet weak var symptomsStackView: UIStackView!
    @IBOutlet weak var recommendationsStackView: UIStackView!
    
    @IBOutlet weak var symptomsCard: UIView!
    @IBOutlet weak var recommendationsCard: UIView!
    
    // MARK: - Data Properties
    private var forecasts: [DailyForecast] = []
    private var selectedDateIndex: Int = 0
    private var dateButtons: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadForecastData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Prevents the black box jump glitch when hiding the tab bar on push
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Show Nav Bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Make Nav Bar completely transparent so the gradient flows behind the title seamlessly
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - UI Setup
extension ForecastViewController {
    
    func setupUI() {
        // Modern background gradient (matching Tracker screen exactly)
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.96, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.89, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.88, blue: 0.96, alpha: 1.0).cgColor
        ]
        bgGradientLayer.locations = [0.0, 0.5, 1.0]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Remove old gradient if present to avoid stacking
        if let oldLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldLayer.removeFromSuperlayer()
        }
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        // Ensure the root view has clear background so gradient shows
        view.backgroundColor = .clear
        
        // Clear scrollView and its content view so the gradient shines through
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.backgroundColor = .clear
            if let contentView = scrollView.subviews.first {
                contentView.backgroundColor = .clear
            }
        }
        
        setupDateStrip()
        setupCards()
        setupDateButtons()
    }
    
    // MARK: - Date Strip
    private func setupDateStrip() {
        guard let topDateContainer = topDateContainer else { return }
        
        topDateContainer.layer.cornerRadius = 20
        topDateContainer.clipsToBounds = true
        topDateContainer.layer.shadowColor = UIColor.black.cgColor
        topDateContainer.layer.shadowOpacity = 0.05
        topDateContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        topDateContainer.layer.shadowRadius = 8
        topDateContainer.layer.masksToBounds = false
    }
    
    // MARK: - Cards
    private func setupCards() {
        let allCards = [phaseCard, fertilityCard, energyCard, symptomsCard, recommendationsCard]
        
        allCards.forEach { card in
            card?.layer.cornerRadius = 20
            card?.backgroundColor = .white
            card?.layer.shadowColor = UIColor.black.cgColor
            card?.layer.shadowOpacity = 0.05
            card?.layer.shadowOffset = CGSize(width: 0, height: 4)
            card?.layer.shadowRadius = 8
        }
    }
    
    // MARK: - Date Buttons
    private func setupDateButtons() {
        guard let topDateContainer = topDateContainer else { return }
        guard let stackView = topDateContainer.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        
        dateButtons = stackView.arrangedSubviews
        
        for buttonView in dateButtons {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateButtonTapped(_:)))
            buttonView.addGestureRecognizer(tapGesture)
            buttonView.isUserInteractionEnabled = true
        }
    }

    @objc private func dateButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view,
              let index = dateButtons.firstIndex(of: tappedView) else { return }
        selectDate(at: index)
    }
}

// MARK: - Data Loading
extension ForecastViewController {
    
    private func loadForecastData() {
        Task {
            do {
                // Get the logged-in user from AuthManager
                guard let currentUser = AuthManager.shared.currentUser,
                      !currentUser.isGuest else {
                    // Guest or no user — show demo forecasts
                    await MainActor.run { self.loadDemoForecasts() }
                    return
                }
                
                let userID = currentUser.id
                
                // Fetch forecasts from CycleDataController
                let daily = try await CycleDataController.shared.getUpcomingForecasts(forUser: userID)
                
                guard daily.count >= 7 else {
                    print("Not enough forecasts — showing demo data")
                    await MainActor.run { self.loadDemoForecasts() }
                    return
                }
                
                self.forecasts = daily
                
                await MainActor.run {
                    self.updateDateStrip()
                    self.selectDate(at: 0)
                }
            } catch {
                print("Error loading forecast data: \(error)")
                await MainActor.run { self.loadDemoForecasts() }
            }
        }
    }
    
    @MainActor
    private func loadDemoForecasts() {
        let phases: [CyclePhase] = [.follicular, .follicular, .follicular, .ovulation, .ovulation, .luteal, .luteal]
        let fertilities: [FertilityLevel] = [.low, .low, .med, .high, .high, .med, .low]
        let energies: [EnergyLevel] = [.medium, .high, .high, .high, .medium, .medium, .low]
        let moods = ["Good", "Great", "Energetic", "Happy", "Calm", "Okay", "Tired"]
        let sampleSymptoms: [[Symptom]] = [
            [Symptom(name: "Mild cramps", intensity: 3)],
            [Symptom(name: "Increased energy", intensity: 2)],
            [Symptom(name: "Clear skin", intensity: 1)],
            [Symptom(name: "Bloating", intensity: 4), Symptom(name: "Breast tenderness", intensity: 3)],
            [Symptom(name: "Mood swings", intensity: 5)],
            [Symptom(name: "Fatigue", intensity: 4), Symptom(name: "Cravings", intensity: 3)],
            [Symptom(name: "Headache", intensity: 3)],
        ]
        let sampleRecs: [[String]] = [
            ["Stay hydrated", "Light exercises recommended"],
            ["Great day for cardio", "Include iron-rich foods"],
            ["Yoga or stretching", "Stay hydrated"],
            ["Rest when needed", "Eat balanced meals"],
            ["Gentle walks", "Practice mindfulness"],
            ["Prioritise sleep", "Reduce caffeine"],
            ["Light stretching", "Warm compress for cramps"],
        ]
        
        let demoUserID = UUID()
        var demoForecasts: [DailyForecast] = []
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: Date()) ?? Date()
            let forecast = DailyForecast(
                id: UUID(),
                user_id: demoUserID,
                date: date,
                phase: phases[i],
                fertility: fertilities[i],
                energy: energies[i],
                weatherDescription: "Sunny",
                mood: moods[i],
                symptoms: sampleSymptoms[i],
                recommendations: sampleRecs[i],
                confidence: 0.78
            )
            demoForecasts.append(forecast)
        }
        
        self.forecasts = demoForecasts
        self.updateDateStrip()
        self.selectDate(at: 0)
    }
}

// MARK: - Date Selection
extension ForecastViewController {
    
    private func updateDateStrip() {
        guard forecasts.count >= 7, !dateButtons.isEmpty else { return }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        for (index, buttonView) in dateButtons.enumerated() {
            guard index < forecasts.count else { continue }
            
            let forecast = forecasts[index]
            let labels = findAllLabels(in: buttonView)
            
            if labels.count >= 2 {
                labels[0].text = dayFormatter.string(from: forecast.date)
                labels[1].text = dateFormatter.string(from: forecast.date)
            }
            
            buttonView.backgroundColor = .clear
            buttonView.layer.cornerRadius = 20
            labels.forEach { $0.textColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0) }
        }
    }
    
    private func selectDate(at index: Int) {
        guard !forecasts.isEmpty, index >= 0, index < forecasts.count else { return }
        
        selectedDateIndex = index
        let selectedForecast = forecasts[index]
        
        updateSelectedDateAppearance(at: index)
        updateForecastUI(for: selectedForecast)
    }

    private func updateSelectedDateAppearance(at index: Int) {
        // Reset all buttons
        dateButtons.forEach { buttonView in
            buttonView.backgroundColor = .clear
            buttonView.layer.sublayers?.forEach {
                if $0 is CAGradientLayer { $0.removeFromSuperlayer() }
            }
            buttonView.layer.shadowOpacity = 0
            
            let labels = findAllLabels(in: buttonView)
            labels.forEach { $0.textColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0) }
        }
        
        // Highlight selected button
        if index < dateButtons.count {
            let selectedButton = dateButtons[index]
            selectedButton.layer.cornerRadius = 20
            
            // Add gradient
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = selectedButton.bounds
            gradientLayer.colors = [
                UIColor(red: 0.85, green: 0.44, blue: 0.97, alpha: 1.0).cgColor,
                UIColor(red: 0.72, green: 0.29, blue: 0.89, alpha: 1.0).cgColor 
            ]
            gradientLayer.cornerRadius = 20
            selectedButton.layer.insertSublayer(gradientLayer, at: 0)
            
            // Add shadow
            selectedButton.layer.shadowColor = UIColor(red: 0.72, green: 0.29, blue: 0.89, alpha: 1.0).cgColor
            selectedButton.layer.shadowOpacity = 0.4
            selectedButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            selectedButton.layer.shadowRadius = 8
            
            // Update labels to white
            let labels = findAllLabels(in: selectedButton)
            labels.forEach { $0.textColor = .white }
        }
    }
}

// MARK: - UI Update Methods
extension ForecastViewController {
    
    private func updateForecastUI(for forecast: DailyForecast) {
        updatePhaseCard(forecast: forecast)
        updateFertilityCard(forecast: forecast)
        updateEnergyCard(forecast: forecast)
        updateSymptomsCard(forecast: forecast)
        updateRecommendationsCard(forecast: forecast)
    }
    
    
    // MARK: - Phase Card
    private func updatePhaseCard(forecast: DailyForecast) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        // 1. Try New Specific Outlets
        if let dateLbl = phaseDateLabel, let nameLbl = phaseNameLabel {
            dateLbl.text = dateFormatter.string(from: forecast.date)
            nameLbl.text = forecast.phase.rawValue.capitalized + " Phase"
            return
        }
        
        // 2. Try Legacy Outlets (from existing Storyboard)
        if let dateLbl = dateLabel, let nameLbl = phaseLabel {
            dateLbl.text = dateFormatter.string(from: forecast.date)
            nameLbl.text = forecast.phase.rawValue.capitalized + " Phase"
            return
        }
        
        // 3. Fallback: Old fragile "Find Label" logic (Last resort)
        guard let phaseCard = phaseCard else { return }
        let labels = findAllLabels(in: phaseCard)
        // ... (Keeping fallback slightly safer or asking user to connect)
        print("⚠️ Please connect phaseDateLabel and phaseNameLabel in Storyboard for better performance.")
        
        if let dateLabel = labels.first(where: { $0.font.pointSize >= 17 }) {
            dateLabel.text = dateFormatter.string(from: forecast.date)
        }
        if let pLabel = labels.first(where: { $0.font.pointSize <= 15 }) {
            pLabel.text = forecast.phase.rawValue.capitalized + " Phase"
        }
    }
    
    // MARK: - Fertility Card
    private func updateFertilityCard(forecast: DailyForecast) {
        let displayText = forecast.fertility.displayName
        
        // Preferred
        if let valLbl = fertilityValueLabel {
            valLbl.text = displayText
            switch forecast.fertility {
            case .low: valLbl.textColor = .systemPink
            case .med: valLbl.textColor = .systemOrange
            case .high: valLbl.textColor = .systemBlue
            }
            return
        }
        
        // Fallback
        guard let fertilityCard = fertilityCard else { return }
        let labels = findAllLabels(in: fertilityCard)
        
        for label in labels where label.font.pointSize >= 18 {
            let text = label.text?.lowercased() ?? ""
            if text != "fertility" && !text.contains("fertility") {
                label.text = displayText
                switch forecast.fertility {
                case .low: label.textColor = .systemPink
                case .med: label.textColor = .systemOrange
                case .high: label.textColor = .systemBlue
                }
            }
        }
    }
    
    // MARK: - Energy / Confidence Card
    private func updateEnergyCard(forecast: DailyForecast) {
        let confPercent = Int(forecast.confidence * 100)
        let displayText = "\(confPercent)%"
        
        // Preferred
        if let valLbl = energyValueLabel {
            valLbl.text = displayText
            energyTitleLabel?.text = "CONFIDENCE" // Update title if outlet exists
            
            if confPercent >= 80 {
                valLbl.textColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1)
            } else if confPercent >= 50 {
                valLbl.textColor = .orange
            } else {
                valLbl.textColor = .gray
            }
            return
        }
        
        // Fallback
        guard let energyCard = energyCard else { return }
        let labels = findAllLabels(in: energyCard)
        
        for label in labels where label.font.pointSize >= 18 {
            let text = label.text?.lowercased() ?? ""
            if text != "energy level" && !text.contains("energy") && !text.contains("confidence") {
                label.text = displayText
                if confPercent >= 80 {
                    label.textColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1)
                } else if confPercent >= 50 {
                     label.textColor = .orange
                } else {
                     label.textColor = .gray
                }
            }
        }
        if let titleLabel = labels.first(where: { ($0.text?.lowercased().contains("energy") ?? false) || ($0.text?.lowercased().contains("confidence") ?? false) }) {
            titleLabel.text = "CONFIDENCE"
        }
    }
    
    private func findAllLabels(in view: UIView) -> [UILabel] {
        var labels: [UILabel] = []
        for subview in view.subviews {
            if let label = subview as? UILabel {
                labels.append(label)
            }
            labels.append(contentsOf: findAllLabels(in: subview))
        }
        return labels
    }
    
    // MARK: - Symptoms Card
    private func updateSymptomsCard(forecast: DailyForecast) {
        var stackView: UIStackView? = symptomsStackView
        
        // Fallback if Outlet not connected
        if stackView == nil {
            guard let card = symptomsCard else { return }
            stackView = card.subviews.first(where: { $0 is UIStackView }) as? UIStackView
        }
        
        guard let symptomsStackView = stackView else { return }
        
        symptomsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if forecast.symptoms.isEmpty {
            let noSymptomsLabel = UILabel()
            noSymptomsLabel.text = "No symptoms expected"
            noSymptomsLabel.font = UIFont.systemFont(ofSize: 15)
            symptomsStackView.addArrangedSubview(noSymptomsLabel)
        } else {
            for symptom in forecast.symptoms {
                let symptomLabel = UILabel()
                symptomLabel.text = "• \(symptom.name) (Intensity: \(symptom.intensity)/10)"
                symptomLabel.font = UIFont.systemFont(ofSize: 15)
                symptomLabel.numberOfLines = 0
                symptomsStackView.addArrangedSubview(symptomLabel)
            }
        }
    }
    
    // MARK: - Recommendations Card
    private func updateRecommendationsCard(forecast: DailyForecast) {
        var stackView: UIStackView? = recommendationsStackView
        
        // Fallback
        if stackView == nil {
            guard let card = recommendationsCard else { return }
            stackView = card.subviews.first(where: { $0 is UIStackView }) as? UIStackView
        }
        
        guard let finalStackView = stackView else { return }
        
        finalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if forecast.recommendations.isEmpty {
            let noRecLabel = UILabel()
            noRecLabel.text = "No specific recommendations"
            noRecLabel.font = UIFont.systemFont(ofSize: 13)
            finalStackView.addArrangedSubview(noRecLabel)
        } else {
            for recommendation in forecast.recommendations {
                let recLabel = UILabel()
                recLabel.text = "• \(recommendation)"
                recLabel.font = UIFont.systemFont(ofSize: 13)
                recLabel.numberOfLines = 0
                finalStackView.addArrangedSubview(recLabel)
            }
        }
    }
    
    // Update gradient frame on layout changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}
