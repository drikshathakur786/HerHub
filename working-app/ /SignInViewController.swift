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
        emailTextField.text = "user1@gmail.com"
        passwordTextField.text = "user1"
    }
    
    // setup UI elements
    private func setupUI() {
        errorLabel?.isHidden = true // hide error initially
        passwordTextField?.isSecureTextEntry = true // hide password text
        
        emailTextField?.delegate = self
        passwordTextField?.delegate = self
        
        // dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        signInButton?.layer.cornerRadius = 10 // rounded button
        
        // add logo above title
        addLogo()
        
        // round text field corners
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
    }
    
    // add the HerHub logo
    private func addLogo() {
        let logoSize: CGFloat = 80
        
        // white circle background
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = logoSize / 2
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.1
        circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circleView.layer.shadowRadius = 8
        
        // H icon
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(systemName: "h.circle.fill")
        logoImageView.tintColor = UIColor(red: 0.846, green: 0.5, blue: 0.766, alpha: 1.0)
        
        circleView.addSubview(logoImageView)
        view.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: logoSize),
            circleView.heightAnchor.constraint(equalToConstant: logoSize),
            circleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            
            logoImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: logoSize * 0.85),
            logoImageView.heightAnchor.constraint(equalToConstant: logoSize * 0.85)
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
