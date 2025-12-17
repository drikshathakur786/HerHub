import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // User data passed from profile screen
    var currentUser: User?
    var userEmail: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }

    private func setupUI() {
        // Circular profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        // Button styling
        saveButton.layer.cornerRadius = 10
        
        // Email field is read-only
        emailTextField.isEnabled = false
        
        // Set text field delegates
        nameTextField.delegate = self
        bioTextField.delegate = self
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadUserData() {
        guard let user = currentUser else {
            print("   No user data available")
            return
        }
        
        // Populate fields with existing data
        emailTextField.text = user.email ?? user.phoneNumber ?? ""
        nameTextField.text = user.userName // Use userName
        bioTextField.text = "" // Bio field not in User model yet
        
        print("✅ Loaded user data for editing")
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        saveProfile()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("Cancel button tapped")
        dismiss(animated: true, completion: nil)
    }
    
    private func saveProfile() {
        guard var user = currentUser else {
            showAlert(title: "Error", message: "No user data available")
            return
        }
        
        // Validate inputs
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Name cannot be empty")
            return
        }
        
        // Update user object
        user.userName = name
        
        // Show loading
        saveButton.isEnabled = false
        saveButton.setTitle("Saving...", for: .normal)
        
        Task {
            do {
                // Update user in database
                try await UserController.shared.updateUser(user)
                
                await MainActor.run {
                    print("✅ Profile updated successfully")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Save Changes", for: .normal)
                    
                    // Dismiss and return to profile
                    self.dismiss(animated: true) {
                        // Notify previous screen to reload
                        NotificationCenter.default.post(name: NSNotification.Name("UserProfileUpdated"), object: nil)
                    }
                }
            } catch {
                await MainActor.run {
                    print("  Error updating profile: \(error.localizedDescription)")
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

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss keyboard when return key is pressed
        textField.resignFirstResponder()
        return true
    }
}
