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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var guidelinesView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapToDismiss()
   
        if let community = editingCommunity {
            nameTextField.text = community.name
            descriptionTextView.text = community.description.isEmpty ? "Describe your community..." : community.description
            descriptionTextView.textColor = community.description.isEmpty ? .systemGray : .label
            createButton.setTitle("Save Changes", for: .normal)
        }
    }
    
    func setupUI() {
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        nameTextField.backgroundColor = .white
        nameTextField.textColor = .label
        nameTextField.font = UIFont.systemFont(ofSize: 16)
        nameTextField.layer.cornerRadius = 12
        nameTextField.layer.borderWidth = 0
        nameTextField.layer.masksToBounds = true
        
        descriptionTextView.backgroundColor = .white
        descriptionTextView.textColor = .label
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.layer.borderWidth = 0
        descriptionTextView.layer.masksToBounds = true
        
        if let placeholder = nameTextField.placeholder {
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.systemGray]
            )
        }
        
        descriptionTextView.text = "Describe your community..."
        descriptionTextView.textColor = .systemGray
        descriptionTextView.isScrollEnabled = true
      
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
        if textView === descriptionTextView && textView.textColor == .systemGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === descriptionTextView &&
            textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Describe your community..."
            textView.textColor = .systemGray
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
        if descriptionTextView.textColor == .systemGray {
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
            
            CommunityManager.shared.updateCommunity(communityToEdit)
            print("Community '\(name)' updated by: \(currentUser.email ?? "unknown")")
            
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
            
            dismiss(animated: true) {
                didUpdateCallback?()
            }
        } else {
            CommunityManager.shared.addCommunity(
                name: name,
                description: description,
                themeColor: "purple",
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

}


