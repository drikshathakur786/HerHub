//
//  OnboardingStep3ViewController.swift
//  HerHub
//
//  Step 2: Lifestyle Factors (Exercise, Sleep, Stress, Diet, Caffeine, Work, Cycle)
//

import UIKit

class OnboardingStep3ViewController: OnboardingBaseViewController {

    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exerciseSegment: UISegmentedControl!
    @IBOutlet weak var sleepTextField: UITextField!
    @IBOutlet weak var stressTextField: UITextField!
    @IBOutlet weak var dietTextField: UITextField!
    @IBOutlet weak var caffeineSegment: UISegmentedControl!
    @IBOutlet weak var workSegment: UISegmentedControl!
    @IBOutlet weak var cycleLengthTextField: UITextField!
    
    private var buttonGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buttonGradient?.frame = nextBtn?.bounds ?? .zero
    }
    
    private func setupOnboardingUI() {
        
        if let card = contentCardView {
            setupContentCard(card)
        }
        
        if let btn = nextBtn {
            styleNextButton(btn)
        }
        
        [sleepTextField, stressTextField, dietTextField, cycleLengthTextField].forEach {
            $0?.delegate = self
            $0?.layer.cornerRadius = 8
        }
        
        sleepTextField?.placeholder = "e.g. 7 (4-14 hrs)"
        stressTextField?.placeholder = "e.g. 5 (1-10)"
        dietTextField?.placeholder = "e.g. 5 (1-10)"
        cycleLengthTextField?.placeholder = "e.g. 28 (21-45 days)"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func styleNextButton(_ button: UIButton) {
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
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        var invalidFields: [UITextField] = []
        var errorMessages: [String] = []
        
        // Reset all field borders first
        [sleepTextField, stressTextField, dietTextField, cycleLengthTextField].forEach {
            clearErrorBorder($0)
        }
        
        // Validate sleep
        let sleepText = sleepTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if sleepText.isEmpty {
            invalidFields.append(sleepTextField!)
            errorMessages.append("Sleep hours")
        } else if let val = Double(sleepText), val < 4.0 || val > 14.0 {
            invalidFields.append(sleepTextField!)
            errorMessages.append("Sleep hours (4-14)")
        } else if Double(sleepText) == nil {
            invalidFields.append(sleepTextField!)
            errorMessages.append("Sleep hours (enter a number)")
        }
        
        // Validate stress
        let stressText = stressTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if stressText.isEmpty {
            invalidFields.append(stressTextField!)
            errorMessages.append("Stress level")
        } else if let val = Int(stressText), val < 1 || val > 10 {
            invalidFields.append(stressTextField!)
            errorMessages.append("Stress level (1-10)")
        } else if Int(stressText) == nil {
            invalidFields.append(stressTextField!)
            errorMessages.append("Stress level (enter a number)")
        }
        
        // Validate diet
        let dietText = dietTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if dietText.isEmpty {
            invalidFields.append(dietTextField!)
            errorMessages.append("Diet quality")
        } else if let val = Int(dietText), val < 1 || val > 10 {
            invalidFields.append(dietTextField!)
            errorMessages.append("Diet quality (1-10)")
        } else if Int(dietText) == nil {
            invalidFields.append(dietTextField!)
            errorMessages.append("Diet quality (enter a number)")
        }
        
        // Validate cycle length
        let cycleText = cycleLengthTextField?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if cycleText.isEmpty {
            invalidFields.append(cycleLengthTextField!)
            errorMessages.append("Cycle length")
        } else if let val = Int(cycleText), val < 21 || val > 45 {
            invalidFields.append(cycleLengthTextField!)
            errorMessages.append("Cycle length (21-45 days)")
        } else if Int(cycleText) == nil {
            invalidFields.append(cycleLengthTextField!)
            errorMessages.append("Cycle length (enter a number)")
        }
        
        // If there are invalid fields, highlight them red and show alert
        if !invalidFields.isEmpty {
            for field in invalidFields {
                setErrorBorder(field)
            }
            let message = "Please fill in: " + errorMessages.joined(separator: ", ")
            showAlert(message: message)
            return
        }
        
        // All valid — parse values
        let sleepHours = Double(sleepText)!
        let stressLevel = Int(stressText)!
        let dietQuality = Int(dietText)!
        let cycleLength = Int(cycleText)!
        
        let exerciseMap = [0, 2, 4, 7]
        let exercisePerWeek = exerciseMap[exerciseSegment?.selectedSegmentIndex ?? 2]
        
        let caffeineMap = [0, 1, 3]
        let caffeineIntake = caffeineMap[caffeineSegment?.selectedSegmentIndex ?? 1]
        
        onBoardingViewController.onboardingData["baseCycleLength"] = cycleLength
        onBoardingViewController.onboardingData["exercisePerWeek"] = exercisePerWeek
        onBoardingViewController.onboardingData["avgSleepHours"] = sleepHours
        onBoardingViewController.onboardingData["baselineStress"] = stressLevel
        onBoardingViewController.onboardingData["dietQuality"] = dietQuality
        onBoardingViewController.onboardingData["caffeineIntake"] = caffeineIntake
        onBoardingViewController.onboardingData["workSchedule"] = workSegment?.selectedSegmentIndex ?? 0
        
        print("[Onboarding Step 2] Lifestyle data saved:")
        print("  - Cycle: \(cycleLength), Exercise: \(exercisePerWeek)/week")
        print("  - Sleep: \(sleepHours)h, Stress: \(stressLevel)/10")
        print("  - Diet: \(dietQuality)/10, Caffeine: \(caffeineIntake) cups")
        print("  - Work: \(workSegment?.selectedSegmentIndex == 0 ? "Day" : "Night")")
        
        performSegue(withIdentifier: "toStep4", sender: self)
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
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Required Fields", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension OnboardingStep3ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear red border when user starts typing in the field
        clearErrorBorder(textField)
    }
}
