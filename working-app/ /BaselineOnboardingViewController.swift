//
//  BaselineOnboardingViewController.swift
//  HerHub
//
//  collects user baseline data for ML prediction
//

import UIKit

class BaselineOnboardingViewController: UIViewController {
    
    // track which step user is on
    private var currentStep = 1
    private let totalSteps = 4
    
    // store all the data we collect from user
    private var baseCycleLength: Int = 28
    private var basePeriodLength: Int = 5
    private var lastPeriodStart: Date = Date()
    private var age: Int = 25
    private var hasPCOS: Bool = false
    private var thyroidIssue: Bool = false
    private var onBirthControl: Bool = false
    private var exercisePerWeek: Int = 3
    private var avgSleepHours: Double = 7.0
    private var baselineStress: Int = 5
    private var dietQuality: Int = 5
    private var caffeineIntake: Int = 1
    private var workSchedule: Int = 0
    private var heightCm: Double = 165.0
    private var weightKg: Double = 60.0
    private var cycleHistory: [Int] = []
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var cycleLengthTextField: UITextField!
    @IBOutlet weak var periodLengthTextField: UITextField!
    @IBOutlet weak var lastPeriodDatePicker: UIDatePicker!
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var pcosSwitch: UISwitch!
    @IBOutlet weak var thyroidSwitch: UISwitch!
    @IBOutlet weak var birthControlSwitch: UISwitch!
    
    @IBOutlet weak var exerciseSegment: UISegmentedControl!
    @IBOutlet weak var sleepSlider: UISlider!
    @IBOutlet weak var stressSlider: UISlider!
    @IBOutlet weak var dietSlider: UISlider!
    @IBOutlet weak var caffeineTextField: UITextField!
    @IBOutlet weak var workScheduleSegment: UISegmentedControl!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var cycle1TextField: UITextField!
    @IBOutlet weak var cycle2TextField: UITextField!
    @IBOutlet weak var cycle3TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("onboarding started") // debug
        setupUI() // setup all text fields
        updateStepUI() // show step 1
    }
    
    private func setupUI() {
       
        let textFields = [cycleLengthTextField, periodLengthTextField, ageTextField,
                          caffeineTextField, heightTextField, weightTextField,
                          cycle1TextField, cycle2TextField, cycle3TextField]
        textFields.forEach { $0?.delegate = self }
      
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateStepUI() {
        let progress = Float(currentStep) / Float(totalSteps)
        progressView?.progress = progress
        stepLabel?.text = "Step \(currentStep) of \(totalSteps)"
        percentLabel?.text = "\(Int(progress * 100))%"
        
        nextButton?.setTitle(currentStep == totalSteps ? "Complete" : "Next", for: .normal)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
 
        saveCurrentStepData()
        
        if currentStep < totalSteps {
            currentStep += 1
            updateStepUI()
            transitionToStep(currentStep)
        } else {
            
            completeOnboarding()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if currentStep > 1 {
            currentStep -= 1
            updateStepUI()
            transitionToStep(currentStep)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func transitionToStep(_ step: Int) {
       
        print("[Onboarding] Transitioning to step \(step)")
    }
    
    private func saveCurrentStepData() {
        switch currentStep {
        case 1:
            baseCycleLength = Int(cycleLengthTextField?.text ?? "") ?? 28
            basePeriodLength = Int(periodLengthTextField?.text ?? "") ?? 5
            lastPeriodStart = lastPeriodDatePicker?.date ?? Date()
            
        case 2:
            age = Int(ageTextField?.text ?? "") ?? 25
            hasPCOS = pcosSwitch?.isOn ?? false
            thyroidIssue = thyroidSwitch?.isOn ?? false
            onBirthControl = birthControlSwitch?.isOn ?? false
            
            if hasPCOS {
                UserDefaults.standard.set(["pcod"], forKey: "userHealthConditions")
            } else {
                UserDefaults.standard.set([String](), forKey: "userHealthConditions")
            }
            NotificationCenter.default.post(name: NSNotification.Name("HealthConditionUpdated"), object: nil)
            
        case 3:
           
            let exerciseMap = [0, 1, 3, 7]
            exercisePerWeek = exerciseMap[exerciseSegment?.selectedSegmentIndex ?? 2]
            avgSleepHours = Double(sleepSlider?.value ?? 7.0)
            baselineStress = Int(stressSlider?.value ?? 5)
            dietQuality = Int(dietSlider?.value ?? 5)
            caffeineIntake = Int(caffeineTextField?.text ?? "") ?? 1
            workSchedule = workScheduleSegment?.selectedSegmentIndex ?? 0
            
        case 4:
            heightCm = Double(heightTextField?.text ?? "") ?? 165.0
            weightKg = Double(weightTextField?.text ?? "") ?? 60.0
           
            cycleHistory = []
            if let c1 = Int(cycle1TextField?.text ?? "") { cycleHistory.append(c1) }
            if let c2 = Int(cycle2TextField?.text ?? "") { cycleHistory.append(c2) }
            if let c3 = Int(cycle3TextField?.text ?? "") { cycleHistory.append(c3) }
            if cycleHistory.isEmpty { cycleHistory = [baseCycleLength] }
            
        default:
            break
        }
    }
    
    private func completeOnboarding() {
        // Get the logged-in user from AuthManager
        guard let currentUser = AuthManager.shared.currentUser else {
            print("[Onboarding] Error: No user logged in - cannot save profile")
            showErrorAlert(message: "Please log in to continue")
            return
        }
        
        let userID = currentUser.id
        print("[Onboarding] Saving profile for: \(currentUser.email ?? "unknown") | ID: \(userID)")
        
        let baseline = CycleBaselineProfile(
            user_id: userID,
            age: age,
            baseCycleLength: baseCycleLength,
            basePeriodLength: basePeriodLength,
            onBirthControl: onBirthControl,
            hasPCOS: hasPCOS,
            exercisePerWeek: exercisePerWeek,
            avgSleepHours: avgSleepHours,
            baselineStress: baselineStress,
            lastPeriodStart: lastPeriodStart,
            heightCm: heightCm,
            weightKg: weightKg,
            thyroidIssue: thyroidIssue,
            workSchedule: workSchedule,
            dietQuality: dietQuality,
            caffeineIntake: caffeineIntake,
            cycleHistory: cycleHistory
        )
        
        Task {
            do {
                try await CycleDataController.shared.saveBaselineProfile(baseline, forUser: userID)
                let _ = try await CycleDataController.shared.generateAndSaveForecasts(forUser: userID)
                
                await MainActor.run {
                    print("[Onboarding] Baseline saved, forecasts generated")
                    self.showCompletionAlert()
                }
            } catch {
                await MainActor.run {
                    print("[Onboarding] Error: \(error)")
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Setup Complete!",
            message: "Your personalized predictions are ready.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension BaselineOnboardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
