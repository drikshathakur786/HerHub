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
    
    
    
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradient()
        populateContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = gradientHeaderView.bounds
        makeTeamImagesCircular()
    }

    private func setupUI() {

        self.title = "About HerHub"

        // Logo with enhanced styling
        logoContainerView.layer.cornerRadius = logoContainerView.frame.width / 2
        logoContainerView.clipsToBounds = true
        logoContainerView.backgroundColor = .white
        logoContainerView.layer.shadowColor = UIColor.white.withAlphaComponent(0.5).cgColor
        logoContainerView.layer.shadowOpacity = 1.0
        logoContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        logoContainerView.layer.shadowRadius = 12
        logoContainerView.layer.masksToBounds = false

        missionTextView.isEditable = false
        missionTextView.isScrollEnabled = false
        missionTextView.backgroundColor = .clear
        missionTextView.textColor = .white
        missionTextView.textAlignment = .center
        missionTextView.font = UIFont.systemFont(ofSize: 15, weight: .regular)

        // What We Do section - premium card design
        whatWeDoView.layer.cornerRadius = 20
        whatWeDoView.backgroundColor = .white
        whatWeDoView.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        whatWeDoView.layer.shadowOpacity = 0.15
        whatWeDoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        whatWeDoView.layer.shadowRadius = 12
        whatWeDoView.layer.masksToBounds = false

        // Team section - premium card design
        teamSectionView.layer.cornerRadius = 20
        teamSectionView.backgroundColor = .white
        teamSectionView.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        teamSectionView.layer.shadowOpacity = 0.15
        teamSectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        teamSectionView.layer.shadowRadius = 12
        teamSectionView.layer.masksToBounds = false

        // App Info section - premium card design with pink tint
        appInfoView.layer.cornerRadius = 20
        appInfoView.backgroundColor = UIColor(red: 1.0, green: 0.925, blue: 0.973, alpha: 1.0)
        appInfoView.layer.shadowColor = UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 0.25).cgColor
        appInfoView.layer.shadowOpacity = 0.15
        appInfoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        appInfoView.layer.shadowRadius = 12
        appInfoView.layer.masksToBounds = false
    }

    private func setupGradient() {
        // Enhanced 3-color vibrant gradient
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 1).cgColor,  // Purple
            UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 1).cgColor,   // Pink
            UIColor(red: 1.0, green: 0.50, blue: 0.50, alpha: 1).cgColor    // Coral
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.cornerRadius = 20
        gradientHeaderView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Add corner radius and shadow to the header
        gradientHeaderView.layer.cornerRadius = 20
        gradientHeaderView.layer.masksToBounds = true
        gradientHeaderView.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.3).cgColor
        gradientHeaderView.layer.shadowOpacity = 0.2
        gradientHeaderView.layer.shadowOffset = CGSize(width: 0, height: 6)
        gradientHeaderView.layer.shadowRadius = 16
    }

    private func makeTeamImagesCircular() {
        let imageViews = [
            teamMember1ImageView,
            teamMember2ImageView,
            teamMember3ImageView,
            teamMember4ImageView
        ]

        for imageView in imageViews {
            guard let imgView = imageView else { continue }
            imgView.layer.cornerRadius = imgView.frame.width / 2
            imgView.clipsToBounds = true
            imgView.contentMode = .scaleAspectFill
        }
    }

    private func populateContent() {

        titleLabel.text = "HerHub"
        subtitleLabel.text = "Because periods shouldn't be a puzzle"

        missionTextView.text =
        "Our mission is to help you understand your body without fear or confusion. HerHub empowers you to track, learn, and feel confident every day."

        whatWeDoLabel.text = "What We Do"
        trackerLabel.text = "• The Tracker: Log your cycle, moods, and symptoms."
        communityLabel.text = "• The Community: A safe space with no judgment."
        resourcesLabel.text = "• The Resources: Trusted answers you’ll love reading."

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
        versionLabel.text = "Version 11.0"
        releaseDateLabel.text = "Released December 2025"
        footerLabel.text = "Made with 💜 for women everywhere"
    }
}

