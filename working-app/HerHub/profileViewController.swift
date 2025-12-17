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

    @IBOutlet weak var settingsStackContainer: UIView!
    @IBOutlet weak var notificationRow: UIView!
    @IBOutlet weak var EditProfile: UIView!
    @IBOutlet weak var LogOut: UIView!

    private let profileGradient = CAGradientLayer()
    private let backgroundGradient = CAGradientLayer()
    
    // Store current user
    private var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Listen for profile updates
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileData), name: NSNotification.Name("UserProfileUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileGradient.frame = profileCard.bounds
        backgroundGradient.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
    }
    
    @objc private func reloadProfileData() {
        print("🔄 Reloading profile data")
        loadUserData()
    }
    
    // MARK: - Actions
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        guard let user = currentUser else {
            print("No user data available for editing")
            return
        }
        
        let storyboard = UIStoryboard(name: "editProfile", bundle: nil)
        if let editVC = storyboard.instantiateInitialViewController() as? EditProfileViewController {
            editVC.currentUser = user
            editVC.modalPresentationStyle = .fullScreen
            present(editVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UI Setup
extension profileViewController {

    func setupUI() {
        setupBackgroundGradient()
        setupNavigationBar()
        setupProfileCard()
        setupMetricCards()
        setupSettingsRows()
    }
    
    // MARK: - Background Gradient
    private func setupBackgroundGradient() {
        backgroundGradient.frame = view.bounds
        backgroundGradient.colors = [
            UIColor(red: 1.0, green: 0.941, blue: 0.961, alpha: 1.0).cgColor, // #FFF0F5
            UIColor(red: 0.961, green: 0.827, blue: 0.922, alpha: 1.0).cgColor  // #F5D3EB
        ]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Profile Card
    private func setupProfileCard() {
        profileCard.layer.cornerRadius = 24
        profileCard.clipsToBounds = true

        // Gradient
        profileGradient.colors = [
            UIColor.systemPurple.withAlphaComponent(0.75).cgColor,
            UIColor.systemPink.withAlphaComponent(0.75).cgColor
        ]
        profileGradient.startPoint = CGPoint(x: 0, y: 0)
        profileGradient.endPoint = CGPoint(x: 1, y: 1)
        profileCard.layer.insertSublayer(profileGradient, at: 0)

        // Profile image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = UIColor.white.withAlphaComponent(0.35)

        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textColor = .white
    }

    // MARK: - Metric Cards
    private func setupMetricCards() {
        let cards = [cycleCard, periodCard]

        for card in cards {
            guard let card = card else { continue }
            card.layer.cornerRadius = 18
            card.backgroundColor = .white
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowOffset = CGSize(width: 0, height: 8)
            card.layer.shadowRadius = 24
            card.layer.masksToBounds = false
        }
    }

    // MARK: - Settings Rows
    private func setupSettingsRows() {
        // Container
        settingsStackContainer.layer.cornerRadius = 18
        settingsStackContainer.clipsToBounds = true
        settingsStackContainer.backgroundColor = .clear

        // Top row
        notificationRow.layer.cornerRadius = 18
        notificationRow.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        notificationRow.backgroundColor = .white

        // Middle row
        EditProfile.layer.cornerRadius = 0
        EditProfile.backgroundColor = .white

        // Bottom row
        LogOut.layer.cornerRadius = 18
        LogOut.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        LogOut.backgroundColor = .white

        // Shadow on container
        settingsStackContainer.layer.shadowColor = UIColor.black.cgColor
        settingsStackContainer.layer.shadowOpacity = 0.06
        settingsStackContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        settingsStackContainer.layer.shadowRadius = 24
        settingsStackContainer.layer.masksToBounds = false
    }
}

// MARK: - Data Loading
extension profileViewController {
    
    func loadUserData() {
        Task {
            do {
                // Use test user ID
                let testUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
                
                // Fetch user
                guard let user = try await UserController.shared.fetchUser(byID: testUserID) else {
                    print("User not found")
                    return
                }
                
                // Fetch baseline profile
                let baseline = try await CycleDataController.shared.getBaselineProfile(forUser: user.id)
                
                // Update UI on main thread
                await MainActor.run {
                    updateProfileUI(user: user, baseline: baseline)
                }
            } catch {
                print("Error loading profile: \(error)")
            }
        }
    }
    
    func updateProfileUI(user: User, baseline: CycleBaselineProfile?) {
        // Store user for editing
        self.currentUser = user
        
        // Update name
        nameLabel.text = user.userName ?? user.email ?? user.phoneNumber ?? "User"
        
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
