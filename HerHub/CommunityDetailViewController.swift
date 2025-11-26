//
//  CommunityDetailViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 19/11/25.
//

import UIKit

class CommunityDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        // Connect the bottom view if you want to animate it later
        @IBOutlet weak var bottomInputView: UIView!
    @IBOutlet weak var postTextField: UITextField! // The text field in the bottom bar
        @IBOutlet weak var sendButton: UIButton!       // The paper plane button
        
        // Variable to receive data from the previous screen
        var community: Community?
        
        override func viewDidLoad() {
            super.viewDidLoad()
//            print("Posts count: \(community?.posts.count ?? 0)")
            print("Detail VC Loaded. Community: \(community?.name ?? "Nil"). Posts: \(community?.posts.count ?? 0)")

            title = "FirstFlow"
            navigationController?.navigationBar.prefersLargeTitles = true
            // Set title to community name
            title = community?.name
            
            // Setup Table
            tableView.delegate = self
            tableView.dataSource = self
            
            // Auto-resize rows
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }

    // MARK: - Table View Delegate & DataSource
    extension CommunityDetailViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2 // Section 0: Notice, Section 1: Posts
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return 1 // Just one notice card
            } else {
                return community?.posts.count ?? 0
            }
        }
        

        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    
                    if indexPath.section == 0 {
                        // Dequeue the static Notice Cell
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
                        return cell
                    } else {
                        // Dequeue the Post Cell
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCellTableViewCell
                        
                        if let post = community?.posts[indexPath.row] {
                            cell.configure(post: post)
                            
                            // --- 1. CONNECT LIKE BUTTON (This was missing!) ---
                            cell.likeButton.tag = indexPath.row
                            cell.likeButton.addTarget(self, action: #selector(handleLike(_:)), for: .touchUpInside)
                            
                            // --- 2. CONNECT FLAG BUTTON ---
                            cell.flagButton.tag = indexPath.row
                            cell.flagButton.addTarget(self, action: #selector(handleFlag(_:)), for: .touchUpInside)
                            
                            // 3. NEW: Comment Button (This was missing!)
                                            cell.commentButton.tag = indexPath.row
                                            cell.commentButton.addTarget(self, action: #selector(handleComment(_:)), for: .touchUpInside)
                        }
                        
                        return cell
                    }
                }

            // --- ADD THIS FUNCTION TO HANDLE THE CLICK ---
            @objc func handleFlag(_ sender: UIButton) {
                let rowIndex = sender.tag
                
                // 1. Get the post that was clicked
                guard let post = community?.posts[rowIndex] else { return }
                
                // 2. Create the Report Screen
                let storyboard = UIStoryboard(name: "community", bundle: nil)
                if let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportPostVC") as? ReportViewController {
                    
                    // 3. PASS THE DATA (Crucial!)
                    reportVC.postID = post.id
                    reportVC.communityID = post.communityID
                    
                    // 4. Show the screen
                    self.present(reportVC, animated: true)
                }
            }
        
        @objc func handleLike(_ sender: UIButton) {
                let rowIndex = sender.tag
                // 1. Get the post
                guard let post = community?.posts[rowIndex] else { return }
                
                // 2. Tell Manager to update
                CommunityManager.shared.likePost(postID: post.id, communityID: post.communityID)
                
                // 3. Update local data so the screen refreshes instantly
                // (We fetch the updated community from the manager)
                if let updatedCommunity = CommunityManager.shared.getCommunity(by: post.communityID) {
                    self.community = updatedCommunity
                    
                    // 4. Refresh just this row to show the new number
                    let indexPath = IndexPath(row: rowIndex, section: 1)
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        
        @objc func handleComment(_ sender: UIButton) {
                let rowIndex = sender.tag
                guard let post = community?.posts[rowIndex] else { return }
                
                // 1. Find the storyboard
                let storyboard = UIStoryboard(name: "community", bundle: nil)
                
                // 2. Find the Comments Screen (Make sure ID is "CommentsVC")
                if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsViewController {
                    
                    // 3. Pass the Data
                    commentsVC.postID = post.id
                    commentsVC.communityID = post.communityID
                    
                    // 4. Show it as a popup
                    if let sheet = commentsVC.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                        sheet.prefersGrabberVisible = true
                    }
                    self.present(commentsVC, animated: true)
                }
            }
        @IBAction func sendPostTapped(_ sender: Any) {
                // 1. Check if there is text
                guard let text = postTextField.text, !text.isEmpty else { return }
                
                // 2. Check if we have a community
                guard let currentCommunity = community else { return }
                
                // 3. Create Fake User Data
                let userID = UUID()
                let authorName = "Me"
                
                // 4. Save to Manager
                // We use the text as both Title and Body for now since we only have one input
                CommunityManager.shared.addPost(
                    to: currentCommunity.id,
                    authorID: userID,
                    authorName: authorName,
                    title: "New Post",
                    text: text,
                    imageURL: nil
                )
                
                // 5. Clear the text field and hide keyboard
                postTextField.text = ""
                postTextField.resignFirstResponder()
                
                // 6. Refresh the screen to show the new post!
                // We need to fetch the updated community data first
                if let updatedCommunity = CommunityManager.shared.getCommunity(by: currentCommunity.id) {
                    self.community = updatedCommunity
                    tableView.reloadData()
                    
                    // Optional: Scroll to the new post (at the bottom)
                    let lastRow = updatedCommunity.posts.count - 1
                    if lastRow >= 0 {
                        let indexPath = IndexPath(row: lastRow, section: 1)
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }

}
