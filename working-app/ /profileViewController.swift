//
//  ProfileViewController.swift
//  HerHub
//
// this is the profile screen where user can see their info

import UIKit

class profileViewController: UIViewController {

    // UI elements - connected from storyboard
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
    @IBOutlet weak var About: UIView!
    @IBOutlet weak var LogOut: UIView!

    // gradient layers for background
    private let profileGradient = CAGradientLayer()
    private let backgroundGradient = CAGradientLayer()
    
    // store the current logged in user
    private var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile view loaded!") // debug
        setupUI() // setup all the UI stuff
        
        // Load user data when screen loads
        loadUserData()
        
        // listen for profile updates
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
        // Refresh data when view appears (in case it was updated elsewhere)
        loadUserData()
    }
    
    // reload the profile when data changes
    @objc private func reloadProfileData() {
        print("reloading profile data...")
        loadUserData()
    }
    
    // handle edit button tap
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        guard let user = currentUser else {
            print("No user data! trying to reload")
            
            // tell user to wait
            let alert = UIAlertController(
                title: "Loading Profile",
                message: "Please wait while we load your profile data...",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            // try loading again
            loadUserData()
            return
        }
        
        print("opening edit screen for user: \(user.userName ?? "no name")")
        
        // open edit profile screen
        let storyboard = UIStoryboard(name: "editProfile", bundle: nil)
        if let editVC = storyboard.instantiateInitialViewController() as? EditProfileViewController {
            editVC.currentUser = user // pass current user data
            editVC.modalPresentationStyle = .fullScreen
            present(editVC, animated: true, completion: nil)
        }
    }
    
    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
      
        AuthManager.shared.signOut()
        

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
            if let authVC = storyboard.instantiateInitialViewController() {
                window.rootViewController = authVC
                window.makeKeyAndVisible()
            }
        }
    }
}

// UI setup functions
extension profileViewController {

    func setupUI() {
        // call all setup methods
        setupBackground()
        setupNavigationBar()
        setupProfileCard()
        setupCards()
        setupSettings()
    }
    
    // setup background gradient with modern soft colors
    private func setupBackground() {
        backgroundGradient.frame = view.bounds
        // Soft pink to lavender gradient
        backgroundGradient.colors = [
            UIColor(red: 1.0, green: 0.96, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.89, blue: 0.95, alpha: 1.0).cgColor,
            UIColor(red: 0.95, green: 0.88, blue: 0.96, alpha: 1.0).cgColor
        ]
        backgroundGradient.locations = [0.0, 0.5, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupNavigationBar() {
        // Make navigation bar transparent like Resources page
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    // setup the profile card at top with vibrant gradient
    private func setupProfileCard() {
        profileCard.layer.cornerRadius = 24 // more rounded corners
        profileCard.clipsToBounds = true  // Clip to fix shadow issues

        // Vibrant multi-color gradient (purple → pink → coral)
        profileGradient.colors = [
            UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 1.0).cgColor,  // Purple
            UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0).cgColor,  // Pink
            UIColor(red: 0.98, green: 0.55, blue: 0.62, alpha: 1.0).cgColor   // Coral
        ]
        profileGradient.locations = [0.0, 0.5, 1.0]
        profileGradient.startPoint = CGPoint(x: 0, y: 0)
        profileGradient.endPoint = CGPoint(x: 1, y: 1)
        profileCard.layer.insertSublayer(profileGradient, at: 0)
        
        // Add subtle shadow to profile card
        profileCard.layer.shadowColor = UIColor.black.cgColor
        profileCard.layer.shadowOpacity = 0.15
        profileCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        profileCard.layer.shadowRadius = 16

        // make profile image circular with border
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.white.cgColor

        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textColor = .white
    }

    // setup cycle and period cards with enhanced styling
    private func setupCards() {
        let cards = [cycleCard, periodCard]

        for card in cards {
            guard let card = card else { continue }
            card.layer.cornerRadius = 20
            card.backgroundColor = .white
            // Enhanced shadow for more depth
            card.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.3).cgColor
            card.layer.shadowOpacity = 0.18
            card.layer.shadowOffset = CGSize(width: 0, height: 6)
            card.layer.shadowRadius = 12
            card.layer.masksToBounds = false
            
            // Add subtle border for definition
            card.layer.borderWidth = 0.5
            card.layer.borderColor = UIColor(red: 0.95, green: 0.88, blue: 0.96, alpha: 0.5).cgColor
        }
    }

    // setup settings section - separate cards design
    private func setupSettings() {
        // Container settings
        settingsStackContainer.layer.cornerRadius = 0
        settingsStackContainer.clipsToBounds = false
        settingsStackContainer.backgroundColor = .clear
        settingsStackContainer.layer.shadowColor = UIColor.clear.cgColor
        settingsStackContainer.layer.shadowOpacity = 0

        // Notification row - standalone card
        notificationRow.layer.cornerRadius = 20
        notificationRow.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // All corners
        notificationRow.backgroundColor = .white
        notificationRow.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        notificationRow.layer.shadowOpacity = 0.12
        notificationRow.layer.shadowOffset = CGSize(width: 0, height: 4)
        notificationRow.layer.shadowRadius = 10
        notificationRow.layer.masksToBounds = false

        // Edit Profile row - standalone card  
        EditProfile.layer.cornerRadius = 20
        EditProfile.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // All corners
        EditProfile.backgroundColor = .white
        EditProfile.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        EditProfile.layer.shadowOpacity = 0.12
        EditProfile.layer.shadowOffset = CGSize(width: 0, height: 4)
        EditProfile.layer.shadowRadius = 10
        EditProfile.layer.masksToBounds = false

        // About row - standalone card
        About.layer.cornerRadius = 20
        About.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // All corners
        About.backgroundColor = .white
        About.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        About.layer.shadowOpacity = 0.12
        About.layer.shadowOffset = CGSize(width: 0, height: 4)
        About.layer.shadowRadius = 10
        About.layer.masksToBounds = false

        // Logout row - standalone card matching other cards
        LogOut.layer.cornerRadius = 20
        LogOut.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // All corners
        LogOut.backgroundColor = .white  // Match other cards
        LogOut.layer.shadowColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 0.25).cgColor
        LogOut.layer.shadowOpacity = 0.12
        LogOut.layer.shadowOffset = CGSize(width: 0, height: 4)
        LogOut.layer.shadowRadius = 10
        LogOut.layer.masksToBounds = false
        
        // add tap gesture for logout
        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        LogOut.isUserInteractionEnabled = true
        LogOut.addGestureRecognizer(logoutTap)
    }
}

// loading and displaying user data
extension profileViewController {
    
    // load user data from database
    func loadUserData() {
        Task {
            do {
                // get current user from auth manager
                guard let user = AuthManager.shared.currentUser else {
                    print("❌ no user logged in!")
                    return
                }
                
                print("🔄 Loading profile for: \(user.email ?? "unknown")")
                
                // get baseline profile data
                let baseline = try await CycleDataController.shared.getBaselineProfile(forUser: user.id)
                
                print("✅ Baseline data loaded:")
                print("   Cycle Length: \(baseline?.baseCycleLength ?? -1)")
                print("   Period Length: \(baseline?.basePeriodLength ?? -1)")
                
                // update UI on main thread
                await MainActor.run {
                    updateProfileUI(user: user, baseline: baseline)
                }
            } catch {
                print("❌ error loading profile: \(error)")
                // Still update UI with user data, even if baseline fails
                await MainActor.run {
                    updateProfileUI(user: AuthManager.shared.currentUser!, baseline: nil)
                }
            }
        }
    }
    
    // update UI with user data
    func updateProfileUI(user: User, baseline: CycleBaselineProfile?) {
        // add baseline to user
        var updatedUser = user
        updatedUser.baselineProfile = baseline
        
        self.currentUser = updatedUser
        
        // set name label
        nameLabel.text = user.userName ?? user.email ?? user.phoneNumber ?? "User"
        
        // display cycle length with 'days' text
        if let cycleLength = baseline?.baseCycleLength {
            cycleValueLabel.text = "\(cycleLength) days"
            print("✅ Set cycle value: \(cycleLength) days")
        } else {
            cycleValueLabel.text = "28 days"
            print("⚠️ No cycle length data available, showing default")
        }
        
        // display period length with 'days' text
        if let periodLength = baseline?.basePeriodLength {
            periodValueLabel.text = "\(periodLength) days"
            print("✅ Set period value: \(periodLength) days")
        } else {
            periodValueLabel.text = "5 days"
            print("⚠️ No period length data available, showing default")
        }
        
        print("✅ profile UI updated successfully")
        print("   Name: \(nameLabel.text ?? "nil")")
        print("   Cycle: \(cycleValueLabel.text ?? "nil")")
        print("   Period: \(periodValueLabel.text ?? "nil")")
    }
}
