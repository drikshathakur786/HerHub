//
//  ReportViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 21/11/25.
//

import UIKit

class ReportViewController: UIViewController {

    // --- Outlets ---
        @IBOutlet weak var detailsTextField: UITextField!
        @IBOutlet weak var submitButton: UIButton!
        @IBOutlet var reasonButtons: [UIButton]! // Connect ALL 5 buttons to this one outlet collection
        
        var selectedReason: String?
        
        // Data passed from previous screen
        var postID: UUID?
        var communityID: UUID?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            // Style Text View
            detailsTextField.layer.borderColor = UIColor.systemGray4.cgColor
            detailsTextField.layer.borderWidth = 1
            detailsTextField.layer.cornerRadius = 8
            
            // Style Submit Button
            submitButton.layer.cornerRadius = 25
        }
        
        // --- ACTIONS ---
        
        // Connect ALL 5 reason buttons to this ONE action
        @IBAction func reasonOptionTapped(_ sender: UIButton) {
            
            // 1. Reset all buttons to empty circle
            for btn in reasonButtons {
                btn.setImage(UIImage(systemName: "circle"), for: .normal)
            }
            
            // 2. Set the tapped button to filled circle
            sender.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            
            // 3. Save the text
            selectedReason = sender.title(for: .normal)
            print("Selected: \(selectedReason ?? "")")
        }

        @IBAction func submitTapped(_ sender: Any) {
            // 1. Check Reason
                guard let reason = selectedReason else {
                    print("❌ Error: No reason selected.")
                    return
                }
                
                // 2. Check IDs (I bet this is printing!)
                if postID == nil || communityID == nil {
                    print("❌ Error: postID or communityID is MISSING! You forgot to pass them.")
                    return
                }
                
                // 3. Proceed if we have data
                guard let pID = postID, let cID = communityID else { return }
                
                // Create a fake reporter ID for now
                let reporterID = UUID()
                
                // Save to Manager
                ReportManager.shared.addReport(
                    postID: pID,
                    communityID: cID,
                    reporterID: reporterID,
                    reason: reason,
                    notes: detailsTextField.text
                )
                
                print("✅ Success! Report saved.")
                
                // Close
                dismiss(animated: true)
        }
}
