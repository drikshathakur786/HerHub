import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Circular profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        // Button styling
        saveButton.layer.cornerRadius = 10
        
        // Email field is read-only
        emailTextField.isEnabled = false
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        print("Save button tapped")
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("Cancel button tapped")
        dismiss(animated: true, completion: nil)
    }
}
