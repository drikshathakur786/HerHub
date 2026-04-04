//
//  SignInViewController.swift
//  HerHub
//
//  login screen
//

import UIKit

class SignInViewController: UIViewController {
    
    // text fields and buttons
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("sign in screen loaded") // debug
        setupUI() // setup UI elements
    }
    
    // setup UI elements
    private func setupUI() {
        errorLabel?.isHidden = true
        passwordTextField?.isSecureTextEntry = true
        
        emailTextField?.delegate = self
        passwordTextField?.delegate = self
        
        // dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Sign In button — native filled style
        signInButton?.layer.cornerRadius = 12
        signInButton?.clipsToBounds = true
        signInButton?.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        signInButton?.backgroundColor = UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0)
        
        // "Don't have an account? Sign Up" — attributed with bold pink "Sign Up"
        styleCreateAccountButton()
        
        // "Continue as Guest" — subtle secondary style
        styleGuestButton()
        
        // add logo above title
        addLogo()
        
        // round text field corners
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
    }
    
    private func styleCreateAccountButton() {
        guard let btn = createAccountButton else { return }
        
        let regularText = "Don't have an account? "
        let boldText = "Sign Up"
        
        let regularAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor(red: 0.92, green: 0.38, blue: 0.68, alpha: 1.0)
        ]
        
        let attributed = NSMutableAttributedString(string: regularText, attributes: regularAttrs)
        attributed.append(NSAttributedString(string: boldText, attributes: boldAttrs))
        btn.setAttributedTitle(attributed, for: .normal)
    }
    
    private func styleGuestButton() {
        guard let btn = view.viewWithTag(0) as? UIButton ?? findGuestButton() else { return }
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    private func findGuestButton() -> UIButton? {
        // Find the guest button by its action
        return view.subviews.compactMap { $0 as? UIButton }.first {
            $0.title(for: .normal) == "Continue as Guest"
        }
    }
    
    // add the HerHub logo
    private func addLogo() {
        let logoSize: CGFloat = 80
        
        // Logo image view with rounded corners
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "HerHubLogo")
        logoImageView.layer.cornerRadius = logoSize * 0.22 // iOS-style rounded rect
        logoImageView.clipsToBounds = true
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOpacity = 0.1
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoImageView.layer.shadowRadius = 8
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: logoSize),
            logoImageView.heightAnchor.constraint(equalToConstant: logoSize),
            logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220)
        ])
    }
    
    // style text fields with rounded corners
    private func styleTextField(_ textField: UITextField?) {
        guard let tf = textField else { return }
        tf.borderStyle = .none
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1.0
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .white
        tf.clipsToBounds = true
        // add left padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: tf.frame.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // handle sign in button tap
    @IBAction func signInButtonTapped(_ sender: Any) {
        // validate inputs
        guard let email = emailTextField?.text, !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        guard let password = passwordTextField?.text, !password.isEmpty else {
            showError("Please enter your password")
            return
        }
        signIn(email: email, password: password) // call sign in function
    }
    

    
    private func signIn(email: String, password: String) {
        signInButton?.isEnabled = false
        signInButton?.setTitle("Signing in...", for: .normal)
        errorLabel?.isHidden = true
        
        Task {
            do {
                let user = try await AuthManager.shared.signIn(email: email, password: password)
                
                await MainActor.run {
                    print("[SignIn] Success: \(user.email ?? "")")
                    self.navigateToMainApp()
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                    self.signInButton?.isEnabled = true
                    self.signInButton?.setTitle("Sign In", for: .normal)
                }
            }
        }
    }
    
    @IBAction func guestButtonTapped(_ sender: Any) {
        // Log in as a purely local guest
        AuthManager.shared.signInAsGuest()
        self.navigateToMainApp()
    }
    
    private func showError(_ message: String) {
        errorLabel?.text = message
        errorLabel?.isHidden = false
    }
    
    private func navigateToMainApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = storyboard.instantiateInitialViewController() {
                window.rootViewController = tabBarVC
                window.makeKeyAndVisible()
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInButtonTapped(self)
        }
        return true
    }
}
