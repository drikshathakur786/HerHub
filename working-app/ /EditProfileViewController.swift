import UIKit

// screen for editing user profile
class EditProfileViewController: UIViewController {

    // UI outlets from storyboard
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!  // kept for storyboard connection
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!    // kept for storyboard connection
    @IBOutlet weak var cycleLengthTextField: UITextField!
    @IBOutlet weak var periodLengthTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // user data variables
    var currentUser: User?
    
    // Avatar options
    private let avatarNames = ["avatar_flower", "avatar_star", "avatar_glasses", "avatar_heart", "avatar_moon"]
    private var selectedAvatarName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Edit profile screen loaded") // debug
        setupUI() // setup all UI elements
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view appearing, checking user data...")
        if let user = currentUser {
            print("user: \(user.userName ?? "no name")")
        }
        loadUserData() // load user data when screen appears
    }

    // setup all UI elements
    private func setupUI() {
        // make profile image round
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Make profile image tappable for avatar selection
        profileImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)
        
        // Also make the "Change Photo" label tappable (it's a sibling in the storyboard)
        if let changePhotoLabel = profileImageView.superview?.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text == "Change Photo" }) {
            changePhotoLabel.text = "Choose Avatar"
            changePhotoLabel.isUserInteractionEnabled = true
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
            changePhotoLabel.addGestureRecognizer(labelTap)
        }
        
        // round button corners
        saveButton.layer.cornerRadius = 8
       
        nameTextField.delegate = self
        cycleLengthTextField.delegate = self
        periodLengthTextField.delegate = self
        
        // Hide phone number and date of birth sections
        phoneNumberTextField?.superview?.isHidden = true
        dateOfBirthPicker?.superview?.isHidden = true
        
        // tap anywhere to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // add done button to number keyboards
        addDoneButtonToKeyboard(for: cycleLengthTextField)
        addDoneButtonToKeyboard(for: periodLengthTextField)
        
        // Load previously selected avatar
        loadSavedAvatar()
    }
    
    private func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // load user data to display in form
    private func loadUserData() {
        print("loading user data...")
        
        // if no user, try to get from auth manager
        if currentUser == nil {
            print("currentUser is nil, attempting to load from AuthManager")
            guard let authUser = AuthManager.shared.currentUser else {
                print(" No user logged in")
                return
            }
            
            // Load baseline profile and attach it
            Task {
                do {
                    let baseline = try await CycleDataController.shared.getBaselineProfile(forUser: authUser.id)
                    
                    await MainActor.run {
                        var userWithBaseline = authUser
                        userWithBaseline.baselineProfile = baseline
                        self.currentUser = userWithBaseline
                        self.populateFields()
                    }
                } catch {
                    print(" Error loading baseline: \(error)")
                    await MainActor.run {
                        // Even without baseline, set the user
                        self.currentUser = authUser
                        self.populateFields()
                    }
                }
            }
            return
        }
        
        populateFields()
    }
    
    private func populateFields() {
        guard let user = currentUser else {
            print(" ERROR: No user data available in populateFields")
            return
        }
        
        print(" populateFields - user: \(user.userName ?? "no name")")
        print(" populateFields - baseline exists: \(user.baselineProfile != nil)")
    
        nameTextField.text = user.userName
        
        // Load saved avatar
        if let avatarName = user.userPicture, !avatarName.isEmpty {
            selectedAvatarName = avatarName
            profileImageView.image = UIImage(named: avatarName)
        } else {
            loadSavedAvatar()
        }
        
        if let baseline = user.baselineProfile {
            cycleLengthTextField.text = "\(baseline.baseCycleLength)"
            periodLengthTextField.text = "\(baseline.basePeriodLength)"
        }
        
        print(" Loaded user data for editing")
    }
    
    // MARK: - Avatar Selection
    
    private func loadSavedAvatar() {
        if let savedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") {
            selectedAvatarName = savedAvatar
            profileImageView.image = UIImage(named: savedAvatar)
        }
    }
    
    @objc private func profileImageTapped() {
        showAvatarPicker()
    }
    
    private func showAvatarPicker() {
        let pickerVC = UIViewController()
        pickerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        pickerVC.view = containerView
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Choose Your Avatar"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.73, green: 0.33, blue: 0.83, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tap an avatar to select it"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)
        
        // Avatar stack
        let avatarStack = UIStackView()
        avatarStack.axis = .horizontal
        avatarStack.distribution = .equalSpacing
        avatarStack.alignment = .center
        avatarStack.spacing = 12
        avatarStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarStack)
        
        let avatarSize: CGFloat = 60
        
        for (index, name) in avatarNames.enumerated() {
            let avatarButton = UIButton(type: .custom)
            avatarButton.tag = index
            avatarButton.layer.cornerRadius = avatarSize / 2
            avatarButton.clipsToBounds = true
            avatarButton.translatesAutoresizingMaskIntoConstraints = false
            avatarButton.contentMode = .scaleAspectFill
            avatarButton.imageView?.contentMode = .scaleAspectFill
            
            if let img = UIImage(named: name) {
                avatarButton.setImage(img, for: .normal)
            }
            
            // Highlight if this is the currently selected avatar
            if name == selectedAvatarName {
                avatarButton.layer.borderWidth = 3
                avatarButton.layer.borderColor = UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0).cgColor
                avatarButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                avatarButton.layer.borderWidth = 2
                avatarButton.layer.borderColor = UIColor.systemGray4.cgColor
            }
            
            // Shadow
            avatarButton.layer.shadowColor = UIColor.black.cgColor
            avatarButton.layer.shadowOpacity = 0.1
            avatarButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            avatarButton.layer.shadowRadius = 4
            avatarButton.layer.masksToBounds = false
            
            NSLayoutConstraint.activate([
                avatarButton.widthAnchor.constraint(equalToConstant: avatarSize),
                avatarButton.heightAnchor.constraint(equalToConstant: avatarSize)
            ])
            
            avatarButton.addTarget(self, action: #selector(avatarSelected(_:)), for: .touchUpInside)
            avatarStack.addArrangedSubview(avatarButton)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            avatarStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            avatarStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            avatarStack.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            avatarStack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        present(pickerVC, animated: true)
    }
    
    @objc private func avatarSelected(_ sender: UIButton) {
        let index = sender.tag
        guard index < avatarNames.count else { return }
        
        let name = avatarNames[index]
        selectedAvatarName = name
        
        // Update profile image with animation
        UIView.transition(with: profileImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.profileImageView.image = UIImage(named: name)
        }
        
        // Save to UserDefaults immediately
        UserDefaults.standard.set(name, forKey: "selectedAvatar")
        
        // Dismiss the picker
        dismiss(animated: true)
        
        print("Selected avatar: \(name)")
    }

    // when user taps save button
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveProfile() // save the profile
    }

    // when user taps cancel
    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("cancel tapped")
        dismiss(animated: true, completion: nil) // close screen
    }
    
    // save profile function
    private func saveProfile() {
        print("saving profile...")
        print("current user exists: \(currentUser != nil)")
        
        // try to recover if user is nil
        if currentUser == nil {
            print("trying to get user from auth manager")
            guard let authUser = AuthManager.shared.currentUser else {
                showAlert(title: "Error", message: "Unable to save. Please log in again.")
                return
            }
            
            // Create a user object from current auth user
            currentUser = authUser
            print(" Recovered currentUser from AuthManager")
        }
        
        guard var user = currentUser else {
            print(" ERROR: currentUser is still nil after recovery attempt!")
            showAlert(title: "Error", message: "Unable to save profile. Please try again.")
            return
        }
        
        print(" currentUser exists: \(user.userName ?? "no name")")
        print(" baselineProfile exists: \(user.baselineProfile != nil)")
        
        // validate name field
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Error", message: "Name cannot be empty")
            return
        }
        
        if let cycleLengthText = cycleLengthTextField.text, !cycleLengthText.isEmpty {
            guard let cycleLength = Int(cycleLengthText), cycleLength >= 21, cycleLength <= 45 else {
                showAlert(title: "Error", message: "Cycle length must be between 21 and 45 days")
                return
            }
        }
        
        if let periodLengthText = periodLengthTextField.text, !periodLengthText.isEmpty {
            guard let periodLength = Int(periodLengthText), periodLength >= 2, periodLength <= 10 else {
                showAlert(title: "Error", message: "Period length must be between 2 and 10 days")
                return
            }
        }
        
        // Update user name and avatar
        user.userName = name
        user.userPicture = selectedAvatarName
        
        // create baseline profile if it doesnt exist
        if user.baselineProfile == nil {
            // default values for new profile
            user.baselineProfile = CycleBaselineProfile(
                user_id: user.id,
                age: 25,
                baseCycleLength: 28,
                basePeriodLength: 5,
                onBirthControl: false,
                hasPCOS: false,
                exercisePerWeek: 3,
                avgSleepHours: 7.0,
                baselineStress: 5,
                lastPeriodStart: Date(),
                heightCm: nil,
                weightKg: nil,
                thyroidIssue: false,
                workSchedule: 0,
                dietQuality: 5,
                caffeineIntake: 1,
                cycleHistory: [28, 28, 28]
            )
        }
        
        if let cycleLengthText = cycleLengthTextField.text, let cycleLength = Int(cycleLengthText) {
            user.baselineProfile?.baseCycleLength = cycleLength
        }
        
        if let periodLengthText = periodLengthTextField.text, let periodLength = Int(periodLengthText) {
            user.baselineProfile?.basePeriodLength = periodLength
        }
            
        saveButton.isEnabled = false
        saveButton.setTitle("Saving...", for: .normal)
        
        // Keep a clean copy for Supabase (without nested objects that aren't DB columns)
        var userForDB = user
        userForDB.baselineProfile = nil
        userForDB.recentCheckIns = nil
        userForDB.latestPrediction = nil
        
        Task {
            do {
                // Save user object (only DB-compatible fields)
                try await UserController.shared.updateUser(userForDB)
                print(" User profile saved to DB")
                
                // Save the baseline profile separately (it's stored in a different table)
                if let baseline = user.baselineProfile {
                    try await CycleDataController.shared.saveBaselineProfile(baseline, forUser: user.id)
                    print(" Baseline profile saved separately")
                }
                
                // Update AuthManager's current user with the full object (including baseline)
                AuthManager.shared.updateCurrentUser(user)
                
                await MainActor.run {
                    print("Profile updated successfully")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Save Changes", for: .normal)
                    
                    // Show success alert
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Your profile has been updated successfully!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        // Dismiss and return to profile after user taps OK
                        self.dismiss(animated: true) {
                            // Notify previous screen to reload
                            NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
                        }
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    print("Error updating profile: \(error.localizedDescription)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Save Changes", for: .normal)
                    self.showAlert(title: "Error", message: "Failed to update profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
}

