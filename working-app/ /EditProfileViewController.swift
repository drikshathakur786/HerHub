import UIKit

// screen for editing user profile
class EditProfileViewController: UIViewController {

    // UI outlets from storyboard
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var cycleLengthTextField: UITextField!
    @IBOutlet weak var periodLengthTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // user data variables
    var currentUser: User?
    var userEmail: String? // TODO: maybe remove this later if not needed

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
        
        // round button corners
        saveButton.layer.cornerRadius = 8
       
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        cycleLengthTextField.delegate = self
        periodLengthTextField.delegate = self
        
        dateOfBirthPicker.datePickerMode = .date
        dateOfBirthPicker.maximumDate = Date() // cant be born in future
        // set minimum date to 100 years ago
        if let minDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) {
            dateOfBirthPicker.minimumDate = minDate
        }
        
        // tap anywhere to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // add done button to number keyboards
        addDoneButtonToKeyboard(for: cycleLengthTextField)
        addDoneButtonToKeyboard(for: periodLengthTextField)
        addDoneButtonToKeyboard(for: phoneNumberTextField)
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
        phoneNumberTextField.text = user.phoneNumber
   
        if let dob = user.dateOfBirth {
            dateOfBirthPicker.date = dob
        }
        
        if let baseline = user.baselineProfile {
            cycleLengthTextField.text = "\(baseline.baseCycleLength)"
            periodLengthTextField.text = "\(baseline.basePeriodLength)"
        }
        
        print(" Loaded user data for editing")
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
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Name cannot be empty")
            return
        }
        
        if let cycleLengthText = cycleLengthTextField.text, !cycleLengthText.isEmpty {
            guard let cycleLength = Int(cycleLengthText), cycleLength > 0, cycleLength <= 100 else {
                showAlert(title: "Error", message: "Cycle length must be a positive number between 1 and 100")
                return
            }
        }
        
        if let periodLengthText = periodLengthTextField.text, !periodLengthText.isEmpty {
            guard let periodLength = Int(periodLengthText), periodLength > 0, periodLength <= 30 else {
                showAlert(title: "Error", message: "Period length must be a positive number between 1 and 30")
                return
            }
        }
        
        user.userName = name
        user.phoneNumber = phoneNumberTextField.text?.isEmpty == false ? phoneNumberTextField.text : nil
        user.dateOfBirth = dateOfBirthPicker.date
        
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
        
        Task {
            do {
                // Save the user object
                try await UserController.shared.updateUser(user)
                
                // Also save the baseline profile separately (it's stored in a different file)
                if let baseline = user.baselineProfile {
                    try await CycleDataController.shared.saveBaselineProfile(baseline, forUser: user.id)
                    print(" Baseline profile saved separately")
                }
                
                // Update AuthManager's current user using the proper method
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
