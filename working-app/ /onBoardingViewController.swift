//
//  onBoardingViewController.swift
//  HerHub
//
//  Step 1: Cycle Length - First step of baseline onboarding
//

import UIKit

class onBoardingViewController: OnboardingBaseViewController {
    
    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var cycleLengthTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
   
    static var onboardingData: [String: Any] = [:]
    
    private var buttonGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update button gradient frame
        buttonGradient?.frame = nextBtn?.bounds ?? .zero
    }
    
    private func setupOnboardingUI() {
      
        if let card = contentCardView {
            setupContentCard(card)
        }
        
        if let btn = nextBtn {
            styleNextButton(btn)
        }
        
        if let back = backBtn {
            setupBackButton(back)
        }
        
        if let label = titleLabel {
            setupQuestionLabel(label)
        }
        
        cycleLengthTextField?.delegate = self
        cycleLengthTextField?.keyboardType = .numberPad
        cycleLengthTextField?.textAlignment = .center
        cycleLengthTextField?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        cycleLengthTextField?.layer.borderWidth = 0
        cycleLengthTextField?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        cycleLengthTextField?.layer.cornerRadius = 12
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func styleNextButton(_ button: UIButton) {

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.45, blue: 0.70, alpha: 1.0).cgColor,  // Pink
            UIColor(red: 0.75, green: 0.55, blue: 0.95, alpha: 1.0).cgColor   // Purple
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
    
        guard let cycleText = cycleLengthTextField?.text,
              let cycleLength = Int(cycleText),
              cycleLength >= 21 && cycleLength <= 45 else {
            showAlert(message: "Please enter a valid cycle length (21-45 days)")
            return
        }
        
        onBoardingViewController.onboardingData["baseCycleLength"] = cycleLength
        print("[Onboarding Step 1] Cycle length: \(cycleLength)")
        
        performSegue(withIdentifier: "toStep2", sender: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension onBoardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
