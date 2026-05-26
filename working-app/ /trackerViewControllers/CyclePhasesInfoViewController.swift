//
//  CyclePhasesInfoViewController.swift
//  HerHub
//
//  Educational screen explaining the 4 menstrual cycle phases.
//  Designed for teen girls — simple, friendly, and easy to understand.
//

import UIKit

class CyclePhasesInfoViewController: UIViewController {
    
    // MARK: - Data Model
    
    private struct PhaseInfo {
        let iconName: String
        let title: String
        let days: String
        let tagline: String
        let details: String
        let color: UIColor
    }
    
    private let phases: [PhaseInfo] = [
        PhaseInfo(
            iconName: "drop.fill",
            title: "Menstrual",
            days: "Days 1–5",
            tagline: "Rest & Recharge",
            details: "Your period is here! Your body is shedding the uterine lining. It's totally normal to feel tired or have cramps. Be kind to yourself — rest, hydrate, and do gentle activities.",
            color: UIColor.systemRed
        ),
        PhaseInfo(
            iconName: "leaf.fill",
            title: "Follicular",
            days: "Days 6–13",
            tagline: "Energy Rising",
            details: "Your body is preparing an egg and your energy starts to climb! You may feel more creative, social, and motivated. Great time to try new things and be active.",
            color: UIColor.systemGreen
        ),
        PhaseInfo(
            iconName: "sparkles",
            title: "Ovulation",
            days: "Days 14–16",
            tagline: "Peak Energy",
            details: "This is when an egg is released. You might feel your best — confident, energetic, and glowing! Your body temperature rises slightly during this window.",
            color: UIColor.systemBlue
        ),
        PhaseInfo(
            iconName: "moon.fill",
            title: "Luteal",
            days: "Days 17–28",
            tagline: "Wind Down",
            details: "Your body is preparing for either pregnancy or your next period. You might notice PMS symptoms like bloating, mood swings, or cravings. Prioritize sleep and comfort foods.",
            color: UIColor.systemPurple
        )
    ]
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupHeader()
        setupScrollView()
        buildPhaseCards()
        buildFooterTip()
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        // Soft gradient matching the Tracker screen
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 1.0, green: 0.96, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.89, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.88, blue: 0.96, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
        view.backgroundColor = .clear
    }
    
    private func setupHeader() {
        // Grab bar (visual cue for sheet)
        let grabBar = UIView()
        grabBar.backgroundColor = UIColor.tertiaryLabel
        grabBar.layer.cornerRadius = 2.5
        grabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grabBar)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Your Cycle Phases"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Understanding what your body goes through"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Close button (X)
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            grabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            grabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabBar.widthAnchor.constraint(equalToConstant: 36),
            grabBar.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: grabBar.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -12),
            
            closeButton.topAnchor.constraint(equalTo: grabBar.bottomAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        // Store subtitle bottom for scroll view anchoring
        scrollView.tag = 1 // marker
        subtitleLabel.tag = 999
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Find subtitle label by tag
        let subtitleLabel = view.viewWithTag(999)!
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    // MARK: - Build Cards
    
    private func buildPhaseCards() {
        for (index, phase) in phases.enumerated() {
            let card = createPhaseCard(phase: phase, index: index)
            contentStack.addArrangedSubview(card)
        }
    }
    
    private func createPhaseCard(phase: PhaseInfo, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.systemBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        
        // Subtle shadow
        card.layer.shadowColor = phase.color.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 14
        card.layer.shouldRasterize = true
        card.layer.rasterizationScale = UIScreen.main.scale
        
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon squircle (Modern iOS style instead of perfect circle)
        let iconContainer = UIView()
        iconContainer.backgroundColor = phase.color.withAlphaComponent(0.12)
        iconContainer.layer.cornerRadius = 12
        iconContainer.layer.cornerCurve = .continuous
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconContainer)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: phase.iconName)
        iconImageView.tintColor = phase.color
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)
        
        // Phase title
        let titleLabel = UILabel()
        titleLabel.text = phase.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // Days badge (right-aligned)
        let daysBadge = UILabel()
        daysBadge.text = " \(phase.days) "
        daysBadge.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        daysBadge.textColor = .secondaryLabel
        daysBadge.backgroundColor = UIColor.secondarySystemBackground
        daysBadge.layer.cornerRadius = 6
        daysBadge.layer.cornerCurve = .continuous
        daysBadge.clipsToBounds = true
        daysBadge.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(daysBadge)
        
        // Description (Now starts below icon)
        let descLabel = UILabel()
        
        // Combine tagline and details for a cleaner read
        let attributedText = NSMutableAttributedString(
            string: phase.tagline + "\n",
            attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: phase.color]
        )
        attributedText.append(NSAttributedString(
            string: phase.details,
            attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.secondaryLabel]
        ))
        
        descLabel.attributedText = attributedText
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            // Icon container at top left
            iconContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            // Title next to icon
            titleLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            
            // Days badge right aligned
            daysBadge.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            daysBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            // Description starts below icon
            descLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
        
        // Entrance animation — cards fade/slide in
        card.alpha = 0
        card.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(
            withDuration: 0.5,
            delay: Double(index) * 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                card.alpha = 1
                card.transform = .identity
            }
        )
        
        return card
    }
    
    private func buildFooterTip() {
        let tipCard = UIView()
        tipCard.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.12)
        tipCard.layer.cornerRadius = 16
        tipCard.layer.cornerCurve = .continuous
        tipCard.translatesAutoresizingMaskIntoConstraints = false
        
        let tipIcon = UIImageView()
        tipIcon.image = UIImage(systemName: "lightbulb.fill")
        tipIcon.tintColor = .systemYellow
        tipIcon.contentMode = .scaleAspectFit
        tipIcon.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(tipIcon)
        
        let tipText = UILabel()
        tipText.text = "Every body is different! These day ranges are averages for a 28-day cycle. Your cycle might be shorter or longer — and that's completely normal."
        tipText.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tipText.textColor = .secondaryLabel
        tipText.numberOfLines = 0
        tipText.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(tipText)
        
        NSLayoutConstraint.activate([
            tipIcon.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 14),
            tipIcon.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor, constant: 14),
            tipIcon.widthAnchor.constraint(equalToConstant: 20),
            tipIcon.heightAnchor.constraint(equalToConstant: 20),
            
            tipText.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 14),
            tipText.leadingAnchor.constraint(equalTo: tipIcon.trailingAnchor, constant: 10),
            tipText.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor, constant: -14),
            tipText.bottomAnchor.constraint(equalTo: tipCard.bottomAnchor, constant: -14),
        ])
        
        contentStack.addArrangedSubview(tipCard)
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // Update gradient on rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradient.frame = view.bounds
        }
    }
}
