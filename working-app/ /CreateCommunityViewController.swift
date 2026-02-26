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

class CreateCommunityViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: CommunityCreationDelegate?
    
    var onCommunityCreated: (() -> Void)?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    @IBOutlet weak var guidelinesView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapToDismiss()
    }
        
    
    func setupUI() {
        
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 8.0
    
        guidelinesView.layer.cornerRadius = 12.0
        guidelinesView.layer.masksToBounds = true
            
        createButton.layer.cornerRadius = 25
            
        cancelButton.layer.cornerRadius = 25
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
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
    
    @IBAction func cancelTapped(_ sender: Any) {
            dismiss(animated: true)
    }

    @IBAction func createTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            print("Name is empty!")
            return
        }
        
        let description = descriptionTextView.text ?? ""
        
        guard let currentUser = AuthManager.shared.currentUser else {
            print("No user logged in - cannot create community")
            return
        }
        
        CommunityManager.shared.addCommunity(
            name: name,
            description: description,
            themeColor: "purple",
            isFeatured: false,
            createdBy: currentUser.id
        )
        
        print("Community '\(name)' created by: \(currentUser.email ?? "unknown")")
        
        let completionCallback = self.onCommunityCreated
        let delegateRef = self.delegate
        
        dismiss(animated: true) {
            delegateRef?.didCreateCommunity()
            completionCallback?()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
        print("Community '\(name)' created")
        
        dismiss(animated: true)
        
    }

}
