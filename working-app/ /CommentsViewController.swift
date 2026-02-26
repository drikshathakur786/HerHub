//
//  CommentsViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 22/11/25.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomInputView: UIView!
     
    var postID: UUID?
    var communityID: UUID?
    var comments: [Comment] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = "Comments"
          
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
          
        loadComments()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    
    func loadComments() {
        
        print("Attempting to load comments..")
        guard let pID = postID else {
            print("ERROR: postID is nil! Navigation failed.")
            return
        }
                  
        if let post = CommunityManager.shared.getAllPosts().first(where: { $0.id == pID }) {
                    
            self.comments = post.comments
            print("SUCCESS: Found post: \(post.title). Comment Count: \(self.comments.count)")
                        
            if self.comments.count == 0 {
                print("WARNING: Post found, but it has 0 comments. Check CommunityManager sample data.")
            }
            tableView.reloadData()
                        
        } else {
                print("ERROR: Could not find any post with ID: \(pID)")
        }
    }

    
    @IBAction func sendTapped(_ sender: Any) {
            
        print("Send button tapped!")
           
        guard let text = commentTextField.text, !text.isEmpty else {
            print("  FAIL: Text field is empty.")
            return
        }
                
        guard let cID = communityID, let pID = postID else {
            print("  FAIL: Missing IDs!")
            return
        }
                
        print("Data looks good. Sending to Manager...")
          
        guard let currentUser = AuthManager.shared.currentUser else {
            print("No user logged in - cannot add comment")
            return
        }
                
        let myName = currentUser.userName ?? "Anonymous"
                
        CommunityManager.shared.addComment(
            to: pID,
            in: cID,
            authorID: currentUser.id,
            authorName: myName,
            text: text
        )
                
        print("Comment saved! Author: \(myName)")
                
        commentTextField.text = ""
        commentTextField.resignFirstResponder()
                
        loadComments()
    }
  
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


extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.configure(comment: comment)
        
        
        if let userID = AuthManager.shared.currentUser?.id {
            if comment.likedBy.contains(userID) {
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = .systemPink
            } else {
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.likeButton.tintColor = .systemGray
            }
        }
        
        cell.likeButton.setTitle(" \(comment.likesCount)", for: .normal)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(handleLikeComment(_:)), for: .touchUpInside)
        
        cell.replyButton.tag = indexPath.row
        cell.replyButton.addTarget(self, action: #selector(handleReply(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func handleReply(_ sender: UIButton) {
        
        let rowIndex = sender.tag
        let commentToReply = comments[rowIndex]
        let authorName = commentToReply.authorName
        commentTextField.text = "@\(authorName) "
        commentTextField.becomeFirstResponder()
        
    }
    
    @objc func handleLikeComment(_ sender: UIButton) {
        
        let rowIndex = sender.tag
        let comment = comments[rowIndex]
        guard let cID = communityID, let pID = postID else { return }
        CommunityManager.shared.likeComment(commentID: comment.id, postID: pID, communityID: cID)
        loadComments()
    }
    
}

