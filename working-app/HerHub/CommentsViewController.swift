//
//  CommentsViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 22/11/25.
//

import UIKit

class CommentsViewController: UIViewController {

    // --- OUTLETS ---
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var commentTextField: UITextField!
        @IBOutlet weak var sendButton: UIButton!
        @IBOutlet weak var bottomInputView: UIView! // Connect this to the view holding the text field
        
        // --- DATA VARIABLES ---
        var postID: UUID?
        var communityID: UUID?
        var comments: [Comment] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Comments"
            
            // Setup Table
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 80
            
            // Load initial data
            loadComments()
            
            // Keyboard handling (Optional: moves input up when keyboard shows)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    
        func loadComments() {
            print("🔍 DEBUG: Attempting to load comments...")
            guard let pID = postID else {
                        print("  ERROR: postID is nil! Navigation failed.")
                        return
                    }
                    
                    // 1. Find the post
                    if let post = CommunityManager.shared.getAllPosts().first(where: { $0.id == pID }) {
                        
                        // 2. Get comments
                        self.comments = post.comments
                        
                        // 3. Print the result
                        print("✅ SUCCESS: Found post: \(post.title). Comment Count: \(self.comments.count)")
                        
                        if self.comments.count == 0 {
                            print("   WARNING: Post found, but it has 0 comments. Check CommunityManager sample data.")
                        }
                        
                        // 4. Refresh
                        tableView.reloadData()
                        
                    } else {
                        print("  ERROR: Could not find any post with ID: \(pID)")
                    }
                }

        // --- ACTIONS ---
        @IBAction func sendTapped(_ sender: Any) {
            print("👇 Send button tapped!")
                    
                    // 1. Check Text
                    guard let text = commentTextField.text, !text.isEmpty else {
                        print("  FAIL: Text field is empty.")
                        return
                    }
                    
                    // 2. Check IDs
                    // If these are nil, it means CommunityDetailViewController didn't pass them correctly
                    guard let cID = communityID, let pID = postID else {
                        print("  FAIL: Missing IDs!")
                        print("   - Community ID: \(String(describing: communityID))")
                        print("   - Post ID: \(String(describing: postID))")
                        return
                    }
                    
                    print("✅ Data looks good. Sending to Manager...")
                    
                    // 3. Create fake user info
                    let myUserID = UUID()
                    let myName = "Driksha"
                    
                    // 4. Save to Manager
                    CommunityManager.shared.addComment(
                        to: pID,
                        in: cID,
                        authorID: myUserID,
                        authorName: myName,
                        text: text
                    )
                    
                    print("✅ Saved to Manager! Reloading table...")
                    
                    // 5. Clear text field and keyboard
                    commentTextField.text = ""
                    commentTextField.resignFirstResponder()
                    
                    // 6. Reload Data
                    loadComments()
        }
        
        // --- KEYBOARD HANDLING (Optional) ---
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    
    }



//override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        print("\n-------- DIAGNOSTIC CHECK START --------")
//        
//        // 1. Check if we received an ID
//        if let id = postID {
//            print("1. ✅ Received Post ID: \(id)")
//        } else {
//            print("1.   ERROR: Post ID is NIL. Navigation logic is broken.")
//        }
//        
//        // 2. Check the Manager
//        let allPosts = CommunityManager.shared.getAllPosts()
//        print("2. Manager has \(allPosts.count) total posts.")
//        
//        // 3. Try to find the post
//        if let pID = postID, let foundPost = allPosts.first(where: { $0.id == pID }) {
//            print("3. ✅ Found the post in Database!")
//            print("4. Comment Count in Database: \(foundPost.comments.count)")
//            self.comments = foundPost.comments
//            tableView.reloadData()
//        } else {
//            print("3.   Could not find this Post ID in the Database.")
//            print("   (Did the app restart and generate new IDs?)")
//        }
//        
//        print("----------------------------------------\n")
//    }


    // --- TABLE VIEW EXTENSION ---
    extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return comments.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            
            let comment = comments[indexPath.row]
            cell.configure(comment: comment)
            
            // --- CONNECT LIKE BUTTON ---
                    cell.likeButton.tag = indexPath.row
                    cell.likeButton.addTarget(self, action: #selector(handleLikeComment(_:)), for: .touchUpInside)
            
            return cell
        }
        @objc func handleLikeComment(_ sender: UIButton) {
                let rowIndex = sender.tag
                let comment = comments[rowIndex]
                
                guard let cID = communityID, let pID = postID else { return }
                
                // 1. Update Data
                CommunityManager.shared.likeComment(commentID: comment.id, postID: pID, communityID: cID)
                
                // 2. Reload to see the new number!
                loadComments()
            }
    }

