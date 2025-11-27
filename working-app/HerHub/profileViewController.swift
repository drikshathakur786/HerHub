//
//  ProfileViewController.swift
//  HerHub
//

import UIKit

class profileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var profileCard: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var cycleCard: UIView!
    @IBOutlet weak var periodCard: UIView!

    @IBOutlet weak var cycleValueLabel: UILabel!
    @IBOutlet weak var periodValueLabel: UILabel!

    @IBOutlet weak var settingsStackContainer: UIView!   // 🔥 add outlet for full settings section bg
    @IBOutlet weak var notificationRow: UIView!
    @IBOutlet weak var  EditProfile: UIView!
    @IBOutlet weak var LogOut: UIView!

    private let profileGradient = CAGradientLayer()
    private let backgroundGradient = CAGradientLayer()  // New background gradient

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileGradient.frame = profileCard.bounds
        backgroundGradient.frame = view.bounds  // Update background gradient frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData(email: "beth@herhub.com") // Load data when view appears
    }
}

// MARK: - UI SETUP
extension profileViewController {

    func setupUI() {
        setupBackgroundGradient()
        setupNavigationBar()
        setupProfileCard()
        setupMetricCards()
        setupSettingsRows()
    }
    
    // MARK: Background Gradient (matching Tracker & Forecast)
    private func setupBackgroundGradient() {
        backgroundGradient.frame = view.bounds
        backgroundGradient.colors = [
            UIColor(hex: "#FFF0F5").cgColor, // Lavender Blush
            UIColor(hex: "#F5D3EB").cgColor  // Soft pink
        ]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    // MARK: Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: Profile Card (Gradient + Round Corners)
    private func setupProfileCard() {
        profileCard.layer.cornerRadius = 24
        profileCard.clipsToBounds = true

        // gradient
        profileGradient.colors = [
            UIColor.systemPurple.withAlphaComponent(0.75).cgColor,
            UIColor.systemPink.withAlphaComponent(0.75).cgColor
        ]
        profileGradient.startPoint = CGPoint(x: 0, y: 0)
        profileGradient.endPoint = CGPoint(x: 1, y: 1)
        profileCard.layer.insertSublayer(profileGradient, at: 0)

        // profile image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = UIColor.white.withAlphaComponent(0.35)

        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textColor = .white
    }

    // MARK: Metric Cards
    private func setupMetricCards() {
        let cards = [cycleCard, periodCard]

        for card in cards {
            guard let card = card else { continue }
            card.layer.cornerRadius = 18
            card.backgroundColor = .white

            // Enhanced shadow (matching Tracker/Forecast)
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowOffset = CGSize(width: 0, height: 8)
            card.layer.shadowRadius = 24
            card.layer.masksToBounds = false
        }
    }

    // MARK: Settings Rows (Rounded only TOP + BOTTOM rows)
    private func setupSettingsRows() {

        // Round full container
        settingsStackContainer.layer.cornerRadius = 18
        settingsStackContainer.clipsToBounds = true
        settingsStackContainer.backgroundColor = .clear

        // 🔥 Top row
        notificationRow.layer.cornerRadius = 18
        notificationRow.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        notificationRow.backgroundColor = .white

        // Middle row – no rounding
        EditProfile.layer.cornerRadius = 0
        EditProfile.backgroundColor = .white

        // 🔥 Bottom row
       LogOut.layer.cornerRadius = 18
        LogOut.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        LogOut.backgroundColor = .white

        // Shadow on the container (enhanced to match Tracker/Forecast)
        settingsStackContainer.layer.shadowColor = UIColor.black.cgColor
        settingsStackContainer.layer.shadowOpacity = 0.06
        settingsStackContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        settingsStackContainer.layer.shadowRadius = 24
        settingsStackContainer.layer.masksToBounds = false
    }
}

// MARK: - Data Loading
extension profileViewController {
    
    func loadUserData(email: String) {
        Task {
            do {
                print("🔍 Loading profile data for: \(email)")
                
                // Fetch user
                guard let user = try await UserController.shared.fetchUser(byEmail: email) else {
                    print("❌ User not found")
                    return
                }
                
                print("✅ User found: \(user.email ?? "no email")")
                
                // Fetch baseline profile
                let baseline = try await CycleDataController.shared.getBaselineProfile(forUser: user.id)
                
                if let baseline = baseline {
                    print("✅ Baseline found: Cycle=\(baseline.baseCycleLength), Period=\(baseline.basePeriodLength)")
                } else {
                    print("⚠️ No baseline profile found")
                }
                
                // Update UI on main thread
                await MainActor.run {
                    updateProfileUI(user: user, baseline: baseline)
                }
            } catch {
                print("❌ Error loading profile: \(error.localizedDescription)")
            }
        }
    }
    
    func updateProfileUI(user: User, baseline: CycleBaselineProfile?) {
        // Update name label
        nameLabel.text = user.email ?? user.phoneNumber ?? "User"
        
        // Update cycle length
        if let cycleLength = baseline?.baseCycleLength {
            cycleValueLabel.text = "\(cycleLength) days"
        } else {
            cycleValueLabel.text = "-- days"
        }
        
        // Update period length
        if let periodLength = baseline?.basePeriodLength {
            periodValueLabel.text = "\(periodLength) days"
        } else {
            periodValueLabel.text = "-- days"
        }
        
        print("✅ Profile UI updated")
    }
}
