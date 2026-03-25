//
//  AboutViewController.swift
//  HerHub
//
//  Created on 2025-12-20.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gradientHeaderView: UIView!
    @IBOutlet weak var logoContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var missionTextView: UITextView!
    @IBOutlet weak var whatWeDoView: UIView!
    @IBOutlet weak var whatWeDoLabel: UILabel!
    @IBOutlet weak var trackerLabel: UILabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var resourcesLabel: UILabel!
    @IBOutlet weak var teamSectionView: UIView!
    @IBOutlet weak var teamTitleLabel: UILabel!
    @IBOutlet weak var teamMember1ImageView: UIImageView!
    @IBOutlet weak var teamMember1NameLabel: UILabel!
    @IBOutlet weak var teamMember2ImageView: UIImageView!
    @IBOutlet weak var teamMember2NameLabel: UILabel!
    @IBOutlet weak var teamMember3ImageView: UIImageView!
    @IBOutlet weak var teamMember3NameLabel: UILabel!
    @IBOutlet weak var teamMember4ImageView: UIImageView!
    @IBOutlet weak var teamMember4NameLabel: UILabel!
    @IBOutlet weak var appInfoView: UIView!
    @IBOutlet weak var appInfoTitleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    
    private var headerGradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupScrollView()
        setupHeaderCard()
        setupSectionCards()
        setupTeamSection()
        setupAppInfo()
        populateContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer?.frame = gradientHeaderView.bounds
        logoContainerView.layer.cornerRadius = logoContainerView.frame.width / 2
        makeTeamImagesCircular()
    }
    
    // MARK: - Navigation
    private func setupNavigationBar() {
        self.title = "About"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0)
    }
    
    // MARK: - Scroll View
    private func setupScrollView() {
        view.backgroundColor = .systemGroupedBackground
        scrollView.backgroundColor = .clear
    }
    
    // MARK: - Header
    private func setupHeaderCard() {
        // Gradient matching profile card
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 1.0).cgColor,
            UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.55, blue: 0.62, alpha: 1.0).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 16
        gradientHeaderView.layer.insertSublayer(gradient, at: 0)
        headerGradientLayer = gradient
        
        gradientHeaderView.layer.cornerRadius = 16
        gradientHeaderView.clipsToBounds = true
        
        // Logo
        logoContainerView.backgroundColor = .white
        logoContainerView.clipsToBounds = true
        
        // Typography
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        
        missionTextView.isEditable = false
        missionTextView.isScrollEnabled = false
        missionTextView.backgroundColor = .clear
        missionTextView.textColor = UIColor.white.withAlphaComponent(0.8)
        missionTextView.textAlignment = .center
        missionTextView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    // MARK: - Section Cards
    private func setupSectionCards() {
        // What We Do - native grouped style
        styleCard(whatWeDoView)
        
        whatWeDoLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        whatWeDoLabel.textColor = .label
        
        let featureLabels = [trackerLabel, communityLabel, resourcesLabel]
        for label in featureLabels {
            label?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label?.textColor = .secondaryLabel
        }
    }
    
    // MARK: - Team
    private func setupTeamSection() {
        styleCard(teamSectionView)
        
        teamTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        teamTitleLabel.textColor = .label
        
        let nameLabels = [teamMember1NameLabel, teamMember2NameLabel,
                          teamMember3NameLabel, teamMember4NameLabel]
        for label in nameLabels {
            label?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            label?.textColor = .secondaryLabel
        }
    }
    
    // MARK: - App Info
    private func setupAppInfo() {
        styleCard(appInfoView)
        appInfoView.backgroundColor = .secondarySystemGroupedBackground
        
        appInfoTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        appInfoTitleLabel.textColor = .label
        
        versionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = .tertiaryLabel
        
        releaseDateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        releaseDateLabel.textColor = .tertiaryLabel
        
        footerLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        footerLabel.textColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 1.0)
    }
    
    // MARK: - Shared Card Style
    private func styleCard(_ card: UIView) {
        card.layer.cornerRadius = 16
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.masksToBounds = false
    }

    // MARK: - Team Images
    private func makeTeamImagesCircular() {
        let imageViews = [teamMember1ImageView, teamMember2ImageView,
                          teamMember3ImageView, teamMember4ImageView]

        for imageView in imageViews {
            guard let imgView = imageView else { continue }
            imgView.layer.cornerRadius = imgView.frame.width / 2
            imgView.clipsToBounds = true
            imgView.contentMode = .scaleAspectFill
            imgView.layer.borderWidth = 2.0
            imgView.layer.borderColor = UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 0.35).cgColor
        }
    }

    // MARK: - Content
    private func populateContent() {
        titleLabel.text = "HerHub"
        subtitleLabel.text = "Because periods shouldn't be a puzzle"
        missionTextView.text = "Helping you understand your body without fear or confusion. Track, learn, and feel confident every day."

        whatWeDoLabel.text = "What We Do"
        trackerLabel.text = "Track your cycle, moods, and symptoms — always know what to expect next."
        communityLabel.text = "Connect in a safe, judgment-free space with people who understand."
        resourcesLabel.text = "Read trusted, personalized health articles curated just for you."

        teamTitleLabel.text = "Meet Our Team"
        teamMember1NameLabel.text = "Driksha Thakur"
        teamMember2NameLabel.text = "Mahika Behal"
        teamMember3NameLabel.text = "Nihar Sandhu"
        teamMember4NameLabel.text = "Dhruv Dogra"

        teamMember1ImageView.image = UIImage(named: "Driksha")?.withRenderingMode(.alwaysOriginal)
        teamMember2ImageView.image = UIImage(named: "Mahika")?.withRenderingMode(.alwaysOriginal)
        teamMember3ImageView.image = UIImage(named: "Nihar")?.withRenderingMode(.alwaysOriginal)
        teamMember4ImageView.image = UIImage(named: "Dhruv")?.withRenderingMode(.alwaysOriginal)

        appInfoTitleLabel.text = "App Information"
        versionLabel.text = "Version 1.1.0"
        releaseDateLabel.text = "Released December 2025"
        footerLabel.text = "Made with love for women everywhere"
    }
}
