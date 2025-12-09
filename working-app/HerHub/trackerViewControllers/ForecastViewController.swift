//
//  ForecastViewController.swift
//  HerHub
//
//  Created by Nihar Sandhu on 18/11/25.
//

import UIKit

class ForecastViewController: UIViewController {

    // MARK: - Outlets (connect from storyboard)
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
    @IBOutlet weak var aboutCard: UIView!
    
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
        Task { await loadForecastData() }
    }
}

// MARK: - UI Setup
extension ForecastViewController {
    
    func setupUI() {
        // Modern background gradient
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(hex: "#FFF0F5").cgColor, // Lavender Blush
            UIColor(hex: "#F5D3EB").cgColor  // Original soft pink
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        setupDateStrip()
        setupCards()
        setupTagCards()
        setupDateButtons()
        
        // Initial animation
        let cards = [phaseCard, fertilityCard, energyCard, symptomsCard, recommendationsCard, aboutCard]
        for (index, card) in cards.enumerated() {
            card?.animateIn(delay: 0.1 * Double(index))
        }
    }
    
    
    // MARK: TOP DATE STRIP (rounded white box with shadow)
    // MARK: TOP DATE STRIP (rounded white box with shadow)
    private func setupDateStrip() {
        guard let topDateContainer = topDateContainer else {
            print("   topDateContainer is nil in setupDateStrip")
            return
        }
        
        // iOS-native design with rounded corners
        topDateContainer.layer.cornerRadius = 24
        topDateContainer.clipsToBounds = true
        
        // Modern shadow
        topDateContainer.layer.shadowColor = UIColor.black.cgColor
        topDateContainer.layer.shadowOpacity = 0.08
        topDateContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        topDateContainer.layer.shadowRadius = 12
        topDateContainer.layer.masksToBounds = false
        
        // Remove any existing blur views if present (from previous implementations)
        topDateContainer.subviews.forEach { if $0 is UIVisualEffectView { $0.removeFromSuperview() } }
    }
    
    
    // MARK: SELECTED DATE (purple rounded pill)
    // MARK: SELECTED DATE (purple rounded pill)
    private func setupSelectedDate() {
        guard let selectedDateView = selectedDateView,
              let selectedDayLabel = selectedDayLabel,
              let selectedDateLabel = selectedDateLabel else {
            print("   Selected date view or labels are nil")
            return
        }
        
        selectedDateView.layer.cornerRadius = 16
        // Gradient for selected date
        selectedDateView.applyGradient(colors: [
            UIColor(hex: "#D96FF8"),
            UIColor(hex: "#B84BE2")
        ])
        
        selectedDateView.applyModernShadow(color: UIColor(hex: "#B84BE2"), alpha: 0.3, y: 4, blur: 10)
        
        selectedDayLabel.textColor = .white
        selectedDateLabel.textColor = .white
        selectedDayLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        selectedDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    
    // MARK: BIG WHITE CARDS (phase, symptoms, recommendations, about)
    // MARK: BIG WHITE CARDS (phase, symptoms, recommendations, about)
    private func setupCards() {
        
        let allCards = [phaseCard, symptomsCard, recommendationsCard, aboutCard]
        
        allCards.forEach { card in
            card?.layer.cornerRadius = 24
            card?.backgroundColor = .white
            card?.applyModernShadow(color: .black, alpha: 0.06, y: 8, blur: 24)
        }
    }
    
    
    // MARK: FERTILITY + ENERGY TAG CARDS
    // MARK: FERTILITY + ENERGY TAG CARDS
    private func setupTagCards() {
        guard let fertilityCard = fertilityCard,
              let energyCard = energyCard else {
            print("   Fertility or energy card is nil")
            return
        }
        
        fertilityCard.layer.cornerRadius = 18
        fertilityCard.backgroundColor = UIColor(hex: "#FFF0F5") // Lighter pink
        fertilityCard.layer.borderWidth = 1
        fertilityCard.layer.borderColor = UIColor(hex: "#FFB6C1").withAlphaComponent(0.3).cgColor
        fertilityCard.applyModernShadow(color: UIColor(hex: "#FFB6C1"), alpha: 0.15, y: 4, blur: 12)
        
        energyCard.layer.cornerRadius = 18
        energyCard.backgroundColor = UIColor(hex: "#F3E5FF") // Lighter purple
        energyCard.layer.borderWidth = 1
        energyCard.layer.borderColor = UIColor(hex: "#D8BFD8").withAlphaComponent(0.3).cgColor
        energyCard.applyModernShadow(color: UIColor(hex: "#D8BFD8"), alpha: 0.15, y: 4, blur: 12)
    }
    
    // MARK: Setup Date Buttons
    // MARK: Setup Date Buttons
    private func setupDateButtons() {
        guard let topDateContainer = topDateContainer else {
            print("   topDateContainer is nil")
            return
        }
        
        // Find the stack view containing date buttons
        guard let stackView = topDateContainer.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            print("   Could not find date buttons stack view")
            return
        }
        
        // Extract date button views from stack view
        dateButtons = stackView.arrangedSubviews
        
        for buttonView in dateButtons {
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(dateButtonTapped(_:)))
            buttonView.addGestureRecognizer(tapGesture)
            buttonView.isUserInteractionEnabled = true
        }
    }

    
    @objc private func dateButtonTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view,
              let index = dateButtons.firstIndex(of: tappedView) else {
            print("   dateButtonTapped: view not found")
            return
        }

        print("👉 Date button tapped at index:", index)
        selectDate(at: index)
    }

}

// MARK: - Data Loading from Supabase
extension ForecastViewController {
    
   

    private func loadForecastData() async {
        do {
            // 1️⃣ Get user from SessionManager
            guard let user = SessionManager.shared.currentUser else {
                print("  No user logged in")
                return
            }
            
            // 2️⃣ Fetch daily forecasts directly from Supabase
            let daily = try await CycleDataController.shared.getDailyForecasts(forUser: user.id)
            
            guard daily.count >= 7 else {
                print("   No daily forecasts found or not enough data")
                return
            }
            
            // 3️⃣ store
            self.forecasts = daily
            
            // 4️⃣ update UI
            DispatchQueue.main.async {
                self.updateDateStrip()
                // Fix: Maintain selected index if valid, otherwise default to 0
                let indexToSelect = (self.selectedDateIndex < self.forecasts.count) ? self.selectedDateIndex : 0
                self.selectDate(at: indexToSelect)
            }
        }
        catch {
            print("  Error loading forecast data:", error.localizedDescription)
        }
    }

}

// MARK: - Date Selection
extension ForecastViewController {
    
    private func updateDateStrip() {
        guard forecasts.count >= 7 else {
            print("   Not enough forecasts to populate date strip")
            return
        }
        
        guard !dateButtons.isEmpty else {
            print("   Date buttons not initialized")
            return
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        // Update each date button
        for (index, buttonView) in dateButtons.enumerated() {
            guard index < forecasts.count else { continue }
            
            let forecast = forecasts[index]
            
            // Find labels recursively in the button view
            let labels = findAllLabels(in: buttonView)
            
            // First label is day name, second is date number
            if labels.count >= 2 {
                labels[0].text = dayFormatter.string(from: forecast.date)
                labels[1].text = dateFormatter.string(from: forecast.date)
            }
            
            // Reset button appearance
            buttonView.backgroundColor = .clear
            buttonView.layer.cornerRadius = 20
            
            // Add rounded corners to first and last buttons for visual appeal
            if index == 0 {
                // First button - round left corners
                buttonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            } else if index == dateButtons.count - 1 {
                // Last button - round right corners
                buttonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            } else {
                // Middle buttons - no specific corner masking (all corners rounded)
                buttonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            
            // Set initial text color to dark gray
            labels.forEach { $0.textColor = UIColor(hex: "#4A4A4A") }
        }
    }
    
    private func selectDate(at index: Int) {
        if forecasts.isEmpty {
            print("   selectDate called but forecasts is EMPTY")
            return
        }
        
        guard index >= 0 && index < forecasts.count else {
            print("   Invalid index:", index, "count:", forecasts.count)
            return
        }
        
        selectedDateIndex = index
        let selectedForecast = forecasts[index]
        
        updateSelectedDateAppearance(at: index)
        updateForecastUI(for: selectedForecast)
    }

    private func updateSelectedDateAppearance(at index: Int) {
        // Reset all buttons
        dateButtons.forEach { buttonView in
            buttonView.backgroundColor = .clear // Clear background for unselected
            // Remove gradient layer if present
            if let sublayers = buttonView.layer.sublayers {
                for layer in sublayers where layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
            // Remove shadow
            buttonView.layer.shadowOpacity = 0
            
            // Reset labels to dark
            let labels = findAllLabels(in: buttonView)
            labels.forEach { $0.textColor = UIColor(hex: "#4A4A4A") }
        }
        
        // Highlight selected button
        if index < dateButtons.count {
            let selectedButton = dateButtons[index]
            selectedButton.layer.cornerRadius = 20
            
            // Apply gradient
            selectedButton.applyGradient(colors: [
                UIColor(hex: "#D96FF8"),
                UIColor(hex: "#B84BE2")
            ])
            
            // Add shadow
            selectedButton.applyModernShadow(color: UIColor(hex: "#B84BE2"), alpha: 0.4, y: 4, blur: 8)
            
            // Animate selection
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                selectedButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    selectedButton.transform = .identity
                }
            }
            
            // Update labels in selected button to white
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
        updateAboutCard(forecast: forecast)
    }
    
    // MARK: Helper function to find all labels recursively
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
    
    // MARK: Phase Card
    private func updatePhaseCard(forecast: DailyForecast) {
        guard let phaseCard = phaseCard else {
            print("   phaseCard is nil")
            return
        }
        
        // Find labels in phase card recursively
        let labels = findAllLabels(in: phaseCard)
        guard labels.count >= 2 else { return }
        
        // First label is date (bold, larger), second is phase name (gray, smaller)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        // Find the date label (bold, larger font)
        if let dateLabel = labels.first(where: { $0.font.pointSize >= 17 }) {
            dateLabel.text = dateFormatter.string(from: forecast.date)
        }
        
        // Find the phase label (smaller font, gray color)
        if let phaseLabel = labels.first(where: { $0.font.pointSize <= 15 && $0.textColor == .gray }) {
            phaseLabel.text = forecast.phase.rawValue.capitalized + " Phase"
        }
    }
    
    // MARK: Fertility Card
    private func updateFertilityCard(forecast: DailyForecast) {
        guard let fertilityCard = fertilityCard else {
            print("   fertilityCard is nil")
            return
        }
        
        // Find fertility value label (the bold large label in fertility card)
        let labels = findAllLabels(in: fertilityCard)
        guard labels.count >= 2 else { 
            print("   Found only \(labels.count) labels in fertility card")
            return 
        }
        
        // Check response first - if high, use hardcoded "High"
        let displayText: String
        if forecast.fertility == .high {
            displayText = "High"  // Hardcoded to ensure correct spelling
        } else {
            displayText = forecast.fertility.displayName  // "Low" or "Med"
        }
        print(forecast.fertility.displayName )
        
//        // Debug: Check the forecast data
//        print("📊 Forecast fertility value: \(forecast.fertility.rawValue) → displayText: '\(displayText)'")
//        
//        // Debug: Print all labels found
//        print("🔍 Fertility Card - Found \(labels.count) labels:")
//        for (index, label) in labels.enumerated() {
//            print("  Label \(index): text='\(label.text ?? "nil")', font=\(label.font.pointSize), color=\(label.textColor)")
//        }
//        
        // Update ALL labels with large font (18+) that are NOT the title "Fertility"
        var updatedCount = 0
        for label in labels {
            // Check if it's a large font label (value label)
            if label.font.pointSize >= 18 {
                let text = label.text?.lowercased() ?? ""
                // Update if it's NOT the title label (exclude "Fertility" title)
                if text != "fertility" && !text.contains("fertility") {
                    // Force update - set text directly (hardcoded "High" if response is high)
                    label.text = displayText
                    updatedCount += 1
                    
                    // Update color based on fertility level
                    switch forecast.fertility {
                    case .low:
                        label.textColor = .systemPink
                    case .med:
                        label.textColor = .systemOrange
                    case .high:
                        label.textColor = .systemBlue
                    }
                    
                    print("✅ Updated fertility label: '\(text)' → '\(displayText)'")
                }
            }
        }
        
        // Also explicitly check for and fix typos in ANY label (any font size, any position)
        for label in labels {
            if let text = label.text {
                let lowerText = text.lowercased().trimmingCharacters(in: .whitespaces)
                // Check for common typos: "hiah", "hight", etc.
                if lowerText == "hight" || text.contains("Hight") || text.contains("hight") {
//                    print("hig")  // Print "hig" when "hight" is detected
//                    print("🔧 Found 'hight' typo in fertility label: '\(text)' → fixing to '\(displayText)'")
                    label.text = displayText
                    switch forecast.fertility {
                    case .low: label.textColor = .systemPink
                    case .med: label.textColor = .systemOrange
                    case .high: label.textColor = .systemBlue
                    }
//                    print("✅ Fixed typo: '\(text)' → '\(displayText)'")
                } else if lowerText == "hiah" || text.contains("Hiah") || text.contains("hiah") {
//                    print("🔧 Found 'hiah' typo in fertility label: '\(text)' → fixing to '\(displayText)'")
                    label.text = displayText
                    switch forecast.fertility {
                    case .low: label.textColor = .systemPink
                    case .med: label.textColor = .systemOrange
                    case .high: label.textColor = .systemBlue
                    }
                    print("✅ Fixed typo: '\(text)' → '\(displayText)'")
                }
            }
        }
        
        // Final safety: Update ALL large font labels except title (most aggressive approach)
        if updatedCount == 0 {
            print("   No labels updated with normal logic, trying aggressive update...")
            for label in labels where label.font.pointSize >= 18 {
                let text = label.text?.lowercased() ?? ""
                if text != "fertility" {
                    label.text = displayText
                    switch forecast.fertility {
                    case .low: label.textColor = .systemPink
                    case .med: label.textColor = .systemOrange
                    case .high: label.textColor = .systemBlue
                    }
//                    print("🔧 Aggressively updated label with text '\(label.text ?? "nil")'")
                }
            }
        }
        
        if updatedCount == 0 {
            print("   No fertility value labels were updated!")
        }
    }
    
    // MARK: Energy Card
    private func updateEnergyCard(forecast: DailyForecast) {
        guard let energyCard = energyCard else {
            print("   energyCard is nil")
            return
        }
        
        // Find energy value label (the bold large label in energy card)
        let labels = findAllLabels(in: energyCard)
        guard labels.count >= 2 else { 
            print("   Found only \(labels.count) labels in energy card")
            return 
        }
        
        // Check response first - if high, use hardcoded "High"
        let displayText: String
        if forecast.energy == .high {
            displayText = "High"  // Hardcoded to ensure correct spelling
        } else {
            displayText = forecast.energy.displayName  // "Medium" or "Low"
        }
        
        // Debug: Check the forecast data
        print("📊 Forecast energy value: \(forecast.energy.rawValue) → displayText: '\(displayText)'")
        
        // Debug: Print all labels found
        print("🔍 Energy Card - Found \(labels.count) labels:")
        for (index, label) in labels.enumerated() {
            print("  Label \(index): text='\(label.text ?? "nil")', font=\(label.font.pointSize), color=\(label.textColor)")
        }
        
        // Update ALL labels with large font (18+) that are NOT the title "Energy Level"
        var updatedCount = 0
        for label in labels {
            // Check if it's a large font label (value label)
            if label.font.pointSize >= 18 {
                let text = label.text?.lowercased() ?? ""
                // Update if it's NOT the title label (exclude "Energy Level" title)
                if text != "energy level" && !text.contains("energy") {
                    // Force update - set text directly (hardcoded "High" if response is high)
                    label.text = displayText
                    updatedCount += 1
                    
                    // Update color based on energy level
                    switch forecast.energy {
                    case .high:
                        label.textColor = .systemGreen
                    case .medium:
                        label.textColor = .systemPurple
                    case .low:
                        label.textColor = .systemGray
                    }
                    
                    print("✅ Updated energy label: '\(text)' → '\(displayText)'")
                }
            }
        }
        
        // Also explicitly check for and fix typos in ANY label (any font size, any position)
        for label in labels {
            if let text = label.text {
                let lowerText = text.lowercased().trimmingCharacters(in: .whitespaces)
                // Check for common typos: "hiah", "hight", etc.
                if lowerText == "hight" || text.contains("Hight") || text.contains("hight") {
                    print("hig")  // Print "hig" when "hight" is detected
                    print("🔧 Found 'hight' typo in energy label: '\(text)' → fixing to '\(displayText)'")
                    label.text = displayText
                    switch forecast.energy {
                    case .high: label.textColor = .systemGreen
                    case .medium: label.textColor = .systemPurple
                    case .low: label.textColor = .systemGray
                    }
                    print("✅ Fixed typo: '\(text)' → '\(displayText)'")
                } else if lowerText == "hiah" || text.contains("Hiah") || text.contains("hiah") {
                    print("🔧 Found 'hiah' typo in energy label: '\(text)' → fixing to '\(displayText)'")
                    label.text = displayText
                    switch forecast.energy {
                    case .high: label.textColor = .systemGreen
                    case .medium: label.textColor = .systemPurple
                    case .low: label.textColor = .systemGray
                    }
                    print("✅ Fixed typo: '\(text)' → '\(displayText)'")
                }
            }
        }
        
        // Final safety: Update ALL large font labels except title (most aggressive approach)
        if updatedCount == 0 {
            print("   No labels updated with normal logic, trying aggressive update...")
            for label in labels where label.font.pointSize >= 18 {
                let text = label.text?.lowercased() ?? ""
                if text != "energy level" && !text.contains("energy") {
                    label.text = displayText
                    switch forecast.energy {
                    case .high: label.textColor = .systemGreen
                    case .medium: label.textColor = .systemPurple
                    case .low: label.textColor = .systemGray
                    }
                    print("🔧 Aggressively updated label with text '\(label.text ?? "nil")'")
                }
            }
        }
        
        if updatedCount == 0 {
            print("   No energy value labels were updated!")
        }
    }
    
    // MARK: Symptoms Card
    private func updateSymptomsCard(forecast: DailyForecast) {
        guard let symptomsCard = symptomsCard else {
            print("   symptomsCard is nil")
            return
        }
        
        // Find symptoms stack view
        guard let symptomsStackView = symptomsCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            print("   Could not find symptoms stack view")
            return
        }
        
        // Clear existing symptom views
        symptomsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add symptom views
        if forecast.symptoms.isEmpty {
            // Add a "No symptoms expected" view
            let noSymptomsView = createSymptomItemView(text: "No symptoms expected")
            symptomsStackView.addArrangedSubview(noSymptomsView)
        } else {
            for symptom in forecast.symptoms {
                let symptomText = "\(symptom.name) (Intensity: \(symptom.intensity)/10)"
                let symptomView = createSymptomItemView(text: symptomText)
                symptomsStackView.addArrangedSubview(symptomView)
            }
        }
    }
    
    private func createSymptomItemView(text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "heart.text.clipboard"))
        imageView.tintColor = UIColor(hex: "#D96FF8") // Match theme
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 40),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
        ])
        
        containerView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return containerView
    }
    
    // MARK: Recommendations Card
    private func updateRecommendationsCard(forecast: DailyForecast) {
        guard let recommendationsCard = recommendationsCard else {
            print("   recommendationsCard is nil")
            return
        }
        
        // Find recommendations stack view
        guard let recommendationsStackView = recommendationsCard.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            print("   Could not find recommendations stack view")
            return
        }
        
        // Find the stack view that contains recommendation items (it's nested)
        var targetStackView: UIStackView?
        for subview in recommendationsStackView.arrangedSubviews {
            if let stackView = subview.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
                targetStackView = stackView
                break
            }
        }
        
        guard let targetStack = targetStackView else {
            // Try to find it directly in recommendationsCard
            if let directStack = recommendationsCard.subviews.first(where: { ($0 as? UIStackView)?.axis == .vertical }) as? UIStackView {
                updateRecommendationsInStackView(directStack, recommendations: forecast.recommendations)
                return
            }
            print("   Could not find recommendations items stack view")
            return
        }
        
        updateRecommendationsInStackView(targetStack, recommendations: forecast.recommendations)
    }
    
    private func updateRecommendationsInStackView(_ stackView: UIStackView, recommendations: [String]) {
        // Clear existing recommendation views (except the first one which might be a container)
        let existingViews = stackView.arrangedSubviews
        for view in existingViews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Add recommendation views
        if recommendations.isEmpty {
            let noRecsView = createRecommendationItemView(text: "No specific recommendations")
            stackView.addArrangedSubview(noRecsView)
        } else {
            for recommendation in recommendations {
                let recView = createRecommendationItemView(text: recommendation)
                stackView.addArrangedSubview(recView)
            }
        }
    }
    
    private func createRecommendationItemView(text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        imageView.tintColor = UIColor(hex: "#D96FF8") // Match theme
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    // MARK: About Card
    private func updateAboutCard(forecast: DailyForecast) {
        guard let aboutCard = aboutCard else {
            print("   aboutCard is nil")
            return
        }
        
        // Find labels in about card recursively
        let labels = findAllLabels(in: aboutCard)
        
        // Update with weather description if available
        if let firstLabel = labels.first {
            firstLabel.text = forecast.weatherDescription
            firstLabel.font = UIFont.systemFont(ofSize: 15)
            firstLabel.numberOfLines = 0
        }
        
        // If there's a second label, update with mood
        if labels.count > 1 {
            labels[1].text = "Mood: \(forecast.mood)"
            labels[1].font = UIFont.systemFont(ofSize: 14)
            labels[1].textColor = .systemGray
        }
    }
}

// MARK: UIColor HEX helper
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - UI Enhancements Extension
extension UIView {
    func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.cornerRadius = layer.cornerRadius
        
        // Remove existing gradient layers to avoid stacking
        if let sublayers = layer.sublayers {
            for layer in sublayers where layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applyModernShadow(color: UIColor = .black, alpha: Float = 0.08, x: CGFloat = 0, y: CGFloat = 8, blur: CGFloat = 16, spread: CGFloat = 0) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
        layer.masksToBounds = false
    }
    
    func animateIn(delay: TimeInterval = 0) {
        self.transform = CGAffineTransform(translationX: 0, y: 20).concatenating(CGAffineTransform(scaleX: 0.95, y: 0.95))
        self.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1
        }
    }
    
}
