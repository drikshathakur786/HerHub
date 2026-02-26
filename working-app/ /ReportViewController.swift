//
//  ReportViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 21/11/25.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var reasonButtons: [UIButton]!
    var selectedReason: String?
    
    var postID: UUID?
    var communityID: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
        
    func setupUI() {
    
        detailsTextField.layer.borderColor = UIColor.systemGray4.cgColor
        detailsTextField.layer.borderWidth = 1
        detailsTextField.layer.cornerRadius = 8
        
        submitButton.layer.cornerRadius = 25
    }
        
    @IBAction func reasonOptionTapped(_ sender: UIButton) {
        for btn in reasonButtons {
            btn.setImage(UIImage(systemName: "circle"), for: .normal)
        }
            
        sender.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
     
        selectedReason = sender.title(for: .normal)
        print("Selected: \(selectedReason ?? "")")
    }

    @IBAction func submitTapped(_ sender: Any) {
        
        let reason = "Inappropriate Content"
        
        if let pID = postID, let cID = communityID, let currentUser = AuthManager.shared.currentUser {
                CommunityManager.shared.addReport(
                    postID: pID,
                    communityID: cID,
                    reporterID: currentUser.id,
                    reason: reason,
                    notes: nil
                )
            }
                
            let alert = UIAlertController(
                title: "Report Sent",
                message: "Thank you for keeping our community safe. We will review this post shortly.",
                preferredStyle: .alert
            )
                
                
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true)
            }))
                
            self.present(alert, animated: true)
    }
}
