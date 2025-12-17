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
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    
    @IBOutlet weak var symptomsCard: UIView!
    @IBOutlet weak var recommendationsCard: UIView!
    
    // MARK: - Data Properties
    private var forecasts: [DailyForecast] = []
    private var selectedDateIndex: Int = 0
    private var dateButtons: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadForecastData()
    }
}

// MARK: - UI Setup
extension ForecastViewController {
    
    func setupUI() {
        // Modern background gradient
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.941, blue: 0.961, alpha: 1.0).cgColor, // Lavender Blush #FFF0F5
            UIColor(red: 0.961, green: 0.827, blue: 0.922, alpha: 1.0).cgColor  // Soft pink #F5D3EB
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        setupDateStrip()
        setupCards()
        setupDateButtons()
    }
    
    // MARK: - Date Strip
    private func setupDateStrip() {
        guard let topDateContainer = topDateContainer else { return }
        
        topDateContainer.layer.cornerRadius = 24
        topDateContainer.clipsToBounds = true
        topDateContainer.layer.shadowColor = UIColor.black.cgColor
        topDateContainer.layer.shadowOpacity = 0.08
        topDateContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        topDateContainer.layer.shadowRadius = 12
        topDateContainer.layer.masksToBounds = false
    }
    
    // MARK: - Cards
    private func setupCards() {
        let allCards = [phaseCard, fertilityCard, energyCard, symptomsCard, recommendationsCard]
        
        allCards.forEach { card in
            card?.layer.cornerRadius = 18
            card?.backgroundColor = .white
            card?.layer.shadowColor = UIColor.black.cgColor
            card?.layer.shadowOpacity = 0.06
            card?.layer.shadowOffset = CGSize(width: 0, height: 4)
            card?.layer.shadowRadius = 12
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
                let testUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
                
                // Fetch forecasts from CycleDataController
                let daily = try await CycleDataController.shared.getUpcomingForecasts(forUser: testUserID)
                
                guard daily.count >= 7 else {
                    print("Not enough forecasts")
                    return
                }
                
                self.forecasts = daily
                
                await MainActor.run {
                    self.updateDateStrip()
                    self.selectDate(at: 0)
                }
            } catch {
                print("Error loading forecast data: \(error)")
            }
        }
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
                UIColor(red: 0.85, green: 0.44, blue: 0.97, alpha: 1.0).cgColor, // #D96FF8
                UIColor(red: 0.72, green: 0.29, blue: 0.89, alpha: 1.0).cgColor  // #B84BE2
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
    
    // MARK: - Phase Card
    private func updatePhaseCard(forecast: DailyForecast) {
        guard let phaseCard = phaseCard else { return }
        
        let labels = findAllLabels(in: phaseCard)
        guard labels.count >= 2 else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        if let dateLabel = labels.first(where: { $0.font.pointSize >= 17 }) {
            dateLabel.text = dateFormatter.string(from: forecast.date)
        }
        
        if let phaseLabel = labels.first(where: { $0.font.pointSize <= 15 }) {
            phaseLabel.text = forecast.phase.rawValue.capitalized + " Phase"
        }
    }
    
    // MARK: - Fertility Card
    private func updateFertilityCard(forecast: DailyForecast) {
        guard let fertilityCard = fertilityCard else { return }
        
        let labels = findAllLabels(in: fertilityCard)
        let displayText = forecast.fertility.displayName
        
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
    
    // MARK: - Energy Card
    private func updateEnergyCard(forecast: DailyForecast) {
        guard let energyCard = energyCard else { return }
        
        let labels = findAllLabels(in: energyCard)
        let displayText = forecast.energy.displayName
        
        for label in labels where label.font.pointSize >= 18 {
            let text = label.text?.lowercased() ?? ""
            if text != "energy level" && !text.contains("energy") {
                label.text = displayText
                
                switch forecast.energy {
                case .high: label.textColor = .systemGreen
                case .medium: label.textColor = .systemPurple
                case .low: label.textColor = .systemGray
                }
            }
        }
    }
    
    // MARK: - Symptoms Card
    private func updateSymptomsCard(forecast: DailyForecast) {
        guard let symptomsCard = symptomsCard else { return }
        guard let symptomsStackView = symptomsCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        
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
        guard let recommendationsCard = recommendationsCard else { return }
        guard let stackView = recommendationsCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if forecast.recommendations.isEmpty {
            let noRecLabel = UILabel()
            noRecLabel.text = "No specific recommendations"
            noRecLabel.font = UIFont.systemFont(ofSize: 13)
            stackView.addArrangedSubview(noRecLabel)
        } else {
            for recommendation in forecast.recommendations {
                let recLabel = UILabel()
                recLabel.text = "• \(recommendation)"
                recLabel.font = UIFont.systemFont(ofSize: 13)
                recLabel.numberOfLines = 0
                stackView.addArrangedSubview(recLabel)
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
