//
//  CreateCommunityViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 19/11/25.
//

import UIKit

protocol CommunityCreationDelegate: AnyObject {
    func didCreateCommunity()
}

class CreateCommunityViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    weak var delegate: CommunityCreationDelegate?
    
    var onCommunityCreated: (() -> Void)?
    var onCommunityUpdated: (() -> Void)?
    var editingCommunity: Community?
    var selectedThemeColor: String = "pink"
    
    // Add a reference to the color stack view to update selection borders
    var colorStackView: UIStackView?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var guidelinesView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let community = editingCommunity {
            selectedThemeColor = community.themeColor
            selectedIconName = community.iconName
        }
        
        setupUI()
        setupTapToDismiss()
   
        if let community = editingCommunity {
            nameTextField.text = community.name
            descriptionTextView.text = community.description.isEmpty ? "Describe your community..." : community.description
            descriptionTextView.textColor = community.description.isEmpty ? .placeholderText : .label
            createButton.setTitle("Save Changes", for: .normal)
        }
    }
    
    func setupUI() {
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        let softPinkBg = UIColor(red: 0.988, green: 0.933, blue: 0.957, alpha: 1.0)
        view.backgroundColor = softPinkBg
        
        // 2. Style Inputs with floating Neumorphic/Glass look
        let themePink = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
        
        func styleInputCard(_ inputView: UIView) {
            inputView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            inputView.layer.cornerRadius = 16
            inputView.layer.cornerCurve = .continuous
            inputView.layer.borderWidth = 1
            inputView.layer.borderColor = UIColor.white.cgColor
            
            // Soft shadow for elevation
            inputView.layer.shadowColor = themePink.cgColor
            inputView.layer.shadowOpacity = 0.15
            inputView.layer.shadowOffset = CGSize(width: 0, height: 8)
            inputView.layer.shadowRadius = 15
            inputView.clipsToBounds = false
        }
        
        styleInputCard(nameTextField)
        nameTextField.borderStyle = .none
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
        styleInputCard(descriptionTextView)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        
        // Guidelines View
        if let guidelinesView = guidelinesView {
            guidelinesView.backgroundColor = themePink.withAlphaComponent(0.12)
            guidelinesView.layer.cornerRadius = 16
            guidelinesView.layer.cornerCurve = .continuous
            guidelinesView.layer.borderWidth = 1
            guidelinesView.layer.borderColor = UIColor.white.cgColor
        }
        
        // 3. Style Typography recursively
        func styleLabels(in currentView: UIView) {
            for subview in currentView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "COMMUNITY NAME" || label.text == "DESCRIPTION" {
                        label.textColor = themePink
                        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                        let attributedString = NSMutableAttributedString(string: label.text ?? "")
                        attributedString.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedString.length))
                        label.attributedText = attributedString
                    } else if label.text == "Create Community" {
                        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
                        label.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1.0)
                    } else if let gView = guidelinesView, label.isDescendant(of: gView) {
                        if label.text == "Community Guidelines" {
                            label.textColor = UIColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 1.0)
                        } else {
                            label.textColor = UIColor.darkGray
                        }
                    }
                }
                styleLabels(in: subview)
            }
        }
        styleLabels(in: view)
        
        addCustomizationPickers()
    }
    
    var iconStackView: UIStackView?
    var selectedIconName: String = "heart.fill"
    
    func addCustomizationPickers() {
        // Pastel Colors
        let colors = [
            ("pink", UIColor.themeColor(from: "pink")),
            ("purple", UIColor.themeColor(from: "purple")),
            ("green", UIColor.themeColor(from: "green")),
            ("cyan", UIColor.themeColor(from: "cyan")),
            ("yellow", UIColor.themeColor(from: "yellow"))
        ]
        
        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 16
        colorStack.distribution = .equalSpacing
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        self.colorStackView = colorStack
        
        for (name, color) in colors {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = color
            btn.layer.cornerRadius = 16
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            if name == self.selectedThemeColor {
                btn.layer.borderWidth = 3
                btn.layer.borderColor = UIColor.label.cgColor
            } else {
                btn.layer.borderWidth = 0
            }
            
            btn.accessibilityIdentifier = name
            btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorStack.addArrangedSubview(btn)
        }
        
        let colorLabel = UILabel()
        colorLabel.text = "THEME COLOR"
        colorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        colorLabel.textColor = .secondaryLabel
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Icons
        let icons = ["heart.fill", "sparkles", "leaf.fill", "star.fill", "moon.fill"]
        
        let iconStack = UIStackView()
        iconStack.axis = .horizontal
        iconStack.spacing = 16
        iconStack.distribution = .equalSpacing
        iconStack.translatesAutoresizingMaskIntoConstraints = false
        self.iconStackView = iconStack
        
        for icon in icons {
            let btn = UIButton(type: .custom)
            btn.tintColor = .label
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            btn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
            btn.layer.cornerRadius = 16
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            if icon == self.selectedIconName {
                btn.layer.borderWidth = 3
                btn.layer.borderColor = UIColor.label.cgColor
            } else {
                btn.layer.borderWidth = 0
            }
            
            btn.accessibilityIdentifier = icon
            btn.addTarget(self, action: #selector(iconSelected(_:)), for: .touchUpInside)
            iconStack.addArrangedSubview(btn)
        }
        
        let iconLabel = UILabel()
        iconLabel.text = "COMMUNITY ICON"
        iconLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        iconLabel.textColor = .secondaryLabel
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(iconLabel)
        view.addSubview(iconStack)
        view.addSubview(colorLabel)
        view.addSubview(colorStack)
        
        if let gView = guidelinesView {
            // Find and deactivate the constraint linking guidelinesView top to descriptionTextView bottom
            view.constraints.forEach { constraint in
                if let first = constraint.firstItem as? UIView,
                   let second = constraint.secondItem as? UIView {
                    if (first == gView && second == descriptionTextView) ||
                       (first == descriptionTextView && second == gView) {
                        constraint.isActive = false
                    }
                }
            }
            
            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
                iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                iconStack.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
                iconStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                colorLabel.topAnchor.constraint(equalTo: iconStack.bottomAnchor, constant: 24),
                colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
                colorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                
                gView.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 32)
            ])
        }
    }
    
    @objc func iconSelected(_ sender: UIButton) {
        guard let iconName = sender.accessibilityIdentifier,
              let stackView = self.iconStackView else { return }
        
        self.selectedIconName = iconName
        
        for case let btn as UIButton in stackView.arrangedSubviews {
            if btn.accessibilityIdentifier == iconName {
                btn.layer.borderWidth = 3
                btn.layer.borderColor = UIColor.label.cgColor
            } else {
                btn.layer.borderWidth = 0
            }
        }
    }
    
    @objc func colorSelected(_ sender: UIButton) {
        guard let colorName = sender.accessibilityIdentifier,
              let stackView = self.colorStackView else { return }
        
        self.selectedThemeColor = colorName
        
        for case let btn as UIButton in stackView.arrangedSubviews {
            if btn.accessibilityIdentifier == colorName {
                btn.layer.borderWidth = 3
                btn.layer.borderColor = UIColor.label.cgColor
            } else {
                btn.layer.borderWidth = 0
            }
        }
    }
    
    
    func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
            
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === descriptionTextView && textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === descriptionTextView &&
            textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Describe your community..."
            textView.textColor = .placeholderText
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
            dismiss(animated: true)
    }

    @IBAction func createTapped(_ sender: Any) {
        if AuthManager.shared.currentUser?.isGuest == true {
            self.showGuestLoginPrompt()
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            print("Name is empty!")
            return
        }
        
        var description = descriptionTextView.text ?? ""
        if descriptionTextView.textColor == .placeholderText {
            description = ""
        }
       
        let combined = name + " " + description
        if ContentFilter.containsOffensiveLanguage(combined) {
            let alert = UIAlertController(
                title: "Please adjust your community",
                message: "To keep HerHub safe and supportive for everyone, please remove offensive language from the name or description.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        guard let currentUser = AuthManager.shared.currentUser else {
            print("No user logged in - cannot create community")
            return
        }
        
        let didCreateCallback = self.onCommunityCreated
        let didUpdateCallback = self.onCommunityUpdated
        let delegateRef = self.delegate
        
        if var communityToEdit = editingCommunity {

            communityToEdit.name = name
            communityToEdit.description = description
            communityToEdit.themeColor = self.selectedThemeColor
            communityToEdit.iconName = self.selectedIconName
            
            CommunityManager.shared.updateCommunity(communityToEdit)
            print("Community '\(name)' updated by: \(currentUser.email ?? "unknown")")
            
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
            
            dismiss(animated: true) {
                didUpdateCallback?()
            }
        } else {
            let firstPostKey = "herhub_has_seen_support_notice"
            if !UserDefaults.standard.bool(forKey: firstPostKey) {
                let alert = UIAlertController(title: "Support Community Notice", message: "This is a peer support community. For medical concerns, always consult your doctor. Please be respectful and kind to all members.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "I Understand", style: .default, handler: { [weak self] _ in
                    UserDefaults.standard.set(true, forKey: firstPostKey)
                    self?.executeCommunityCreation(name: name, description: description, currentUser: currentUser, delegateRef: delegateRef, didCreateCallback: didCreateCallback)
                }))
                present(alert, animated: true)
            } else {
                executeCommunityCreation(name: name, description: description, currentUser: currentUser, delegateRef: delegateRef, didCreateCallback: didCreateCallback)
            }
        }
    }
    private func executeCommunityCreation(name: String, description: String, currentUser: User, delegateRef: CommunityCreationDelegate?, didCreateCallback: (() -> Void)?) {
        CommunityManager.shared.addCommunity(
            name: name,
            description: description,
            themeColor: self.selectedThemeColor,
            iconName: self.selectedIconName,
            isFeatured: false,
            createdBy: currentUser.id
        )
        
        print("Community '\(name)' created by: \(currentUser.email ?? "unknown")")
        NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
        
        dismiss(animated: true) {
            delegateRef?.didCreateCommunity()
            didCreateCallback?()
        }
    }

}


