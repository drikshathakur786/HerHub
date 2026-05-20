//
//  OnboardingStep4ViewController.swift
//  HerHub
//
//  Step 3: Final Details (Height, Weight, Period Length, Last Period Date)
//

import UIKit

class OnboardingStep4ViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var periodLengthTextField: UITextField!
    @IBOutlet weak var lastPeriodDatePicker: UIDatePicker!
    @IBOutlet weak var completeButton: UIButton!
    
    private var buttonGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonGradient?.frame = completeButton?.bounds ?? .zero
    }
    
    private func setupOnboardingUI() {
    
        if let card = contentCardView {
            setupContentCard(card)
        }
        
        if let btn = completeButton {
            styleCompleteButton(btn)
        }
        
        lastPeriodDatePicker?.maximumDate = Date()
        
        [heightTextField, weightTextField, periodLengthTextField].forEach {
            $0?.delegate = self
            $0?.layer.cornerRadius = 8
        }
        heightTextField?.keyboardType = .decimalPad
        weightTextField?.keyboardType = .decimalPad
        periodLengthTextField?.keyboardType = .numberPad
        
        // Placeholder hints instead of default values
        heightTextField?.placeholder = "e.g. 165 (100-220 cm)"
        weightTextField?.placeholder = "e.g. 60 (30-200 kg)"
        periodLengthTextField?.placeholder = "e.g. 5 (2-10 days)"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func styleCompleteButton(_ button: UIButton) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.45, blue: 0.70, alpha: 1.0).cgColor,
            UIColor(red: 0.75, green: 0.55, blue: 0.95, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 25
        gradient.frame = button.bounds
        
        button.layer.insertSublayer(gradient, at: 0)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        buttonGradient = gradient
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func completeButtonTapped(_ sender: Any) {
        
        var invalidFields: [UITextField] = []
        var errorMessages: [String] = []
        
        // Reset all field borders first
        [heightTextField, weightTextField, periodLengthTextField].forEach {
            clearErrorBorder($0)
        }
        
        // Validate height
        let heightText = heightTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if heightText.isEmpty {
            invalidFields.append(heightTextField!)
            errorMessages.append("Height")
        } else if let val = Double(heightText), val < 100.0 || val > 220.0 {
            invalidFields.append(heightTextField!)
            errorMessages.append("Height (100-220 cm)")
        } else if Double(heightText) == nil {
            invalidFields.append(heightTextField!)
            errorMessages.append("Height (enter a number)")
        }
        
        // Validate weight
        let weightText = weightTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if weightText.isEmpty {
            invalidFields.append(weightTextField!)
            errorMessages.append("Weight")
        } else if let val = Double(weightText), val < 30.0 || val > 200.0 {
            invalidFields.append(weightTextField!)
            errorMessages.append("Weight (30-200 kg)")
        } else if Double(weightText) == nil {
            invalidFields.append(weightTextField!)
            errorMessages.append("Weight (enter a number)")
        }
        
        // Validate period length
        let periodText = periodLengthTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if periodText.isEmpty {
            invalidFields.append(periodLengthTextField!)
            errorMessages.append("Period length")
        } else if let val = Int(periodText), val < 2 || val > 10 {
            invalidFields.append(periodLengthTextField!)
            errorMessages.append("Period length (2-10 days)")
        } else if Int(periodText) == nil {
            invalidFields.append(periodLengthTextField!)
            errorMessages.append("Period length (enter a number)")
        }
        
        // If there are invalid fields, highlight them red and show alert
        if !invalidFields.isEmpty {
            for field in invalidFields {
                setErrorBorder(field)
            }
            let message = "Please fill in: " + errorMessages.joined(separator: ", ")
            showValidationAlert(message: message)
            return
        }
        
        // All valid — parse values
        let heightCm = Double(heightText)!
        let weightKg = Double(weightText)!
        let periodLength = Int(periodText)!
        let lastPeriodStart = lastPeriodDatePicker?.date ?? Date()
        
        let baseCycleLength = onBoardingViewController.onboardingData["baseCycleLength"] as? Int ?? 28
        let cycleHistory = [baseCycleLength]
        
        guard let currentUser = AuthManager.shared.currentUser else {
            print("[Onboarding] Error: No user logged in - cannot save profile")
            showErrorAlert(message: "Please log in to continue")
            return
        }
        
        let userID = currentUser.id
        print("[Onboarding] Saving profile for user: \(currentUser.email ?? "unknown") | ID: \(userID)")
        
        let baseline = CycleBaselineProfile(
            user_id: userID,
            age: onBoardingViewController.onboardingData["age"] as? Int ?? 25,
            baseCycleLength: baseCycleLength,
            basePeriodLength: periodLength,
            onBirthControl: onBoardingViewController.onboardingData["onBirthControl"] as? Bool ?? false,
            hasPCOS: onBoardingViewController.onboardingData["hasPCOS"] as? Bool ?? false,
            exercisePerWeek: onBoardingViewController.onboardingData["exercisePerWeek"] as? Int ?? 3,
            avgSleepHours: onBoardingViewController.onboardingData["avgSleepHours"] as? Double ?? 7.0,
            baselineStress: onBoardingViewController.onboardingData["baselineStress"] as? Int ?? 5,
            lastPeriodStart: lastPeriodStart,
            heightCm: heightCm,
            weightKg: weightKg,
            thyroidIssue: onBoardingViewController.onboardingData["thyroidIssue"] as? Bool ?? false,
            workSchedule: onBoardingViewController.onboardingData["workSchedule"] as? Int ?? 0,
            dietQuality: onBoardingViewController.onboardingData["dietQuality"] as? Int ?? 5,
            caffeineIntake: onBoardingViewController.onboardingData["caffeineIntake"] as? Int ?? 1,
            cycleHistory: cycleHistory
        )
        
        print("")
        print("[Onboarding Step 3] Physical data:")
        print("  - Height: \(heightCm) cm, Weight: \(weightKg) kg")
        print("  - Period: \(periodLength) days")
        print("  - Last period: \(lastPeriodStart)")
        
        // Save and generate forecasts
        completeButton?.isEnabled = false
        completeButton?.setTitle("Saving...", for: .normal)
        
        Task {
            do {
                try await CycleDataController.shared.saveBaselineProfile(baseline, forUser: userID)
                let forecasts = try await CycleDataController.shared.generateAndSaveForecasts(forUser: userID)
                
                await MainActor.run {
                    print("[Onboarding] Complete! Generated \(forecasts.count) forecasts")
                    self.showCompletionAlert()
                }
            } catch {
                await MainActor.run {
                    print("[Onboarding] Error: \(error)")
                    self.completeButton?.isEnabled = true
                    self.completeButton?.setTitle("Complete", for: .normal)
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Field Error Highlighting
    
    private func setErrorBorder(_ textField: UITextField?) {
        guard let field = textField else { return }
        field.layer.borderWidth = 1.5
        field.layer.borderColor = UIColor.systemRed.cgColor
        
        // Shake animation for extra visual feedback
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-6, 6, -4, 4, -2, 2, 0]
        field.layer.add(shake, forKey: "shake")
    }
    
    private func clearErrorBorder(_ textField: UITextField?) {
        guard let field = textField else { return }
        field.layer.borderWidth = 0
        field.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showCompletionAlert() {
        onBoardingViewController.onboardingData = [:]
        
        let alert = UIAlertController(
            title: "🎉 Setup Complete!",
            message: "Your personalized cycle predictions are ready.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "View Forecast", style: .default) { _ in
            self.navigateToTracker()
        })
        present(alert, animated: true)
    }
    
    private func navigateToTracker() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateInitialViewController() {
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Required Fields", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension OnboardingStep4ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear red border when user starts typing in the field
        clearErrorBorder(textField)
    }
}
