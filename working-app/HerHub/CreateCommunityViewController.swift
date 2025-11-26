//
//  CreateCommunityViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 19/11/25.
//

import UIKit

class CreateCommunityViewController: UIViewController {
    

    // --- OUTLETS (Connect these to Storyboard) ---
        @IBOutlet weak var nameTextField: UITextField!
        @IBOutlet weak var descriptionTextView: UITextField!
        @IBOutlet weak var guidelinesView: UIView! // The pink box
        @IBOutlet weak var createButton: UIButton!
        @IBOutlet weak var cancelButton: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            // 1. Style the Description Box (TextViews don't have borders by default)
            descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
            descriptionTextView.layer.borderWidth = 1.0
            descriptionTextView.layer.cornerRadius = 8.0
            
            // 2. Style the Guidelines Pink Box
            guidelinesView.layer.cornerRadius = 12.0
            guidelinesView.layer.masksToBounds = true
            
            // 3. Style the Create Button
            createButton.layer.cornerRadius = 25 // Half of height (50)
            
            // 4. Style the Cancel Button
            cancelButton.layer.cornerRadius = 25
            cancelButton.layer.borderWidth = 1.0
            cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        // --- ACTIONS (Connect these to Buttons) ---
        
        @IBAction func cancelTapped(_ sender: Any) {
            // Close the screen without saving
            dismiss(animated: true)
        }

        @IBAction func createTapped(_ sender: Any) {
            // 1. Check if name is empty
            guard let name = nameTextField.text, !name.isEmpty else {
                // Optional: Shake animation or error alert could go here
                print("Name is empty!")
                return
            }
            
            let description = descriptionTextView.text ?? ""
            
            // 2. Create a fake User ID (Since we don't have a login system yet)
            let myUserID = UUID()
            
            // 3. Save to Community Manager
            CommunityManager.shared.addCommunity(
                name: name,
                description: description,
                themeColor: "purple", // We default to purple for now
                isFeatured: false,    // New communities are not featured by default
                createdBy: myUserID
            )
            
            // 4. Close the screen
            dismiss(animated: true)
        }

}
