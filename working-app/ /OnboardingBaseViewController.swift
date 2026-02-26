//
//  OnboardingBaseViewController.swift
//  HerHub
//
//  Base class for onboarding screens with gradient background and card style
//

import UIKit

class OnboardingBaseViewController: UIViewController {
    
    private let backgroundGradient = CAGradientLayer()
    var contentCard: UIView?
    var nextButton: UIButton?
    var backButton: UIButton?
    var questionLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func setupGradientBackground() {
        backgroundGradient.colors = [
            UIColor(red: 0.98, green: 0.78, blue: 0.92, alpha: 1.0).cgColor,  // Light pink
            UIColor(red: 0.85, green: 0.68, blue: 0.95, alpha: 1.0).cgColor   // Lilac
        ]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    func setupContentCard(_ card: UIView) {
        self.contentCard = card
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 24
        card.clipsToBounds = false
    }
    
    func setupGradientButton(_ button: UIButton) {
        self.nextButton = button
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.45, blue: 0.70, alpha: 1.0).cgColor,  // Pink
            UIColor(red: 0.75, green: 0.55, blue: 0.95, alpha: 1.0).cgColor   // Purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 25
        gradientLayer.frame = button.bounds
        
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        
      
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
    
        button.layer.shadowColor = UIColor(red: 0.95, green: 0.45, blue: 0.70, alpha: 0.5).cgColor
        button.layer.shadowOpacity = 0.6
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 16
        button.layer.masksToBounds = false
    }
    
    func setupBackButton(_ button: UIButton) {
        self.backButton = button
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .darkGray
    }
    
    func setupQuestionLabel(_ label: UILabel) {
        self.questionLabel = label
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
    }
}

extension UIButton {
    func applyGradient(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        // Remove old gradient layers
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
