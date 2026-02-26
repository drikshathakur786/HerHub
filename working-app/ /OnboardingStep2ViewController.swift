//
//  OnboardingStep2ViewController.swift
//  HerHub
//
//  Step 1: Health Factors (Age, PCOS, Thyroid, Birth Control)
//

import UIKit

class OnboardingStep2ViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var pcosSwitch: UISwitch!
    @IBOutlet weak var thyroidSwitch: UISwitch!
    @IBOutlet weak var birthControlSwitch: UISwitch!
    
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
        
        ageTextField?.delegate = self
        ageTextField?.keyboardType = .numberPad
        ageTextField?.layer.cornerRadius = 12
        ageTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        ageTextField?.leftViewMode = .always
        
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
        guard let ageText = ageTextField?.text,
              let age = Int(ageText),
              age >= 13 && age <= 60 else {
            showAlert(message: "Please enter a valid age (13-60)")
            return
        }
        
        onBoardingViewController.onboardingData["age"] = age
        onBoardingViewController.onboardingData["hasPCOS"] = pcosSwitch?.isOn ?? false
        onBoardingViewController.onboardingData["thyroidIssue"] = thyroidSwitch?.isOn ?? false
        onBoardingViewController.onboardingData["onBirthControl"] = birthControlSwitch?.isOn ?? false
        
        if pcosSwitch?.isOn == true {
            let condition = "pcod"
            UserDefaults.standard.set([condition], forKey: "userHealthConditions")
        } else {
            UserDefaults.standard.set([String](), forKey: "userHealthConditions")
        }
        NotificationCenter.default.post(name: NSNotification.Name("HealthConditionUpdated"), object: nil)
        
        print("[Onboarding Step 1] Age: \(age), PCOS: \(pcosSwitch?.isOn ?? false), Thyroid: \(thyroidSwitch?.isOn ?? false)")
        
        performSegue(withIdentifier: "toStep3", sender: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
     
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension OnboardingStep2ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
