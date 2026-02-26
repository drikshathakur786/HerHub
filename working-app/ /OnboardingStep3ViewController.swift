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
        
        sleepTextField?.text = "7"
        stressTextField?.text = "5"
        dietTextField?.text = "5"
        cycleLengthTextField?.text = "28"
        
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
        
        let exerciseMap = [0, 2, 4, 7]
        let exercisePerWeek = exerciseMap[exerciseSegment?.selectedSegmentIndex ?? 2]
        
     
        let caffeineMap = [0, 1, 3]
        let caffeineIntake = caffeineMap[caffeineSegment?.selectedSegmentIndex ?? 1]
        
       
        let sleepHours = Double(sleepTextField?.text ?? "7") ?? 7.0
        let stressLevel = Int(stressTextField?.text ?? "5") ?? 5
        let dietQuality = Int(dietTextField?.text ?? "5") ?? 5
        let cycleLength = Int(cycleLengthTextField?.text ?? "28") ?? 28
        
        
        let clampedSleep = max(4.0, min(10.0, sleepHours))
        let clampedStress = max(1, min(10, stressLevel))
        let clampedDiet = max(1, min(10, dietQuality))
        let clampedCycle = max(21, min(45, cycleLength))
        
       
        onBoardingViewController.onboardingData["baseCycleLength"] = clampedCycle
        onBoardingViewController.onboardingData["exercisePerWeek"] = exercisePerWeek
        onBoardingViewController.onboardingData["avgSleepHours"] = clampedSleep
        onBoardingViewController.onboardingData["baselineStress"] = clampedStress
        onBoardingViewController.onboardingData["dietQuality"] = clampedDiet
        onBoardingViewController.onboardingData["caffeineIntake"] = caffeineIntake
        onBoardingViewController.onboardingData["workSchedule"] = workSegment?.selectedSegmentIndex ?? 0
        
        print("[Onboarding Step 2] Lifestyle data saved:")
        print("  - Cycle: \(clampedCycle), Exercise: \(exercisePerWeek)/week")
        print("  - Sleep: \(clampedSleep)h, Stress: \(clampedStress)/10")
        print("  - Diet: \(clampedDiet)/10, Caffeine: \(caffeineIntake) cups")
        print("  - Work: \(workSegment?.selectedSegmentIndex == 0 ? "Day" : "Night")")
        
        performSegue(withIdentifier: "toStep4", sender: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension OnboardingStep3ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
