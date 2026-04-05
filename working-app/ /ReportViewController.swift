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

    var onReportSubmitted: (() -> Void)?

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
        if AuthManager.shared.currentUser?.isGuest == true {
            self.showGuestLoginPrompt()
            return
        }

        let reason = selectedReason ?? "Inappropriate Content"
        
        if let pID = postID, let cID = communityID, let currentUser = AuthManager.shared.currentUser {
            
            if let community = CommunityManager.shared.getCommunity(by: cID),
               let post = community.posts.first(where: { $0.id == pID }),
               post.authorID == currentUser.id {
                let alert = UIAlertController(
                    title: "Can't report your own post",
                    message: "You can delete your post instead.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            CommunityManager.shared.addReport(
                postID: pID,
                communityID: cID,
                reporterID: currentUser.id,
                reason: reason,
                notes: detailsTextField.text?.isEmpty == false ? detailsTextField.text : nil
            )
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
        onReportSubmitted?()
        
        let alert = UIAlertController(
            title: "Report Sent",
            message: "Thank you for keeping our community safe. We will review this post shortly. It has been hidden from your feed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
}

