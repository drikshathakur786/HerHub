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
   
    private var threads: [(parent: Comment, replies: [Comment])] = []
    private var replyingToCommentID: UUID?
    private var expandedThreadIDs: Set<UUID> = []

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
            self.threads = CommentsViewController.buildThreads(from: post.comments)
            print("SUCCESS: Found post: \(post.title). Comment Count: \(self.comments.count)")
                        
            if self.comments.count == 0 {
                print("WARNING: Post found, but it has 0 comments. Check CommunityManager sample data.")
            }
            tableView.reloadData()
                        
        } else {
                print("ERROR: Could not find any post with ID: \(pID)")
        }
    }
    
    private static func buildThreads(from comments: [Comment]) -> [(parent: Comment, replies: [Comment])] {
        let parents = comments.filter { $0.parentCommentID == nil }.sorted { $0.createdAt < $1.createdAt }
        let repliesByParent = Dictionary(grouping: comments.filter { $0.parentCommentID != nil }) { $0.parentCommentID! }
        
        return parents.map { parent in
            let replies = (repliesByParent[parent.id] ?? []).sorted { $0.createdAt < $1.createdAt }
            return (parent: parent, replies: replies)
        }
    }

    
    @IBAction func sendTapped(_ sender: Any) {
        if AuthManager.shared.currentUser?.isGuest == true {
            self.showGuestLoginPrompt()
            return
        }

        guard let text = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            print("  FAIL: Text field is empty.")
            return
        }
        
        if ContentFilter.containsOffensiveLanguage(text) {
            let alert = UIAlertController(
                title: "Please adjust your comment",
                message: "To keep HerHub safe and supportive for everyone, please remove offensive language before commenting.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
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
                
        if let parentID = replyingToCommentID {
            CommunityManager.shared.addReply(
                to: parentID,
                postID: pID,
                in: cID,
                authorID: currentUser.id,
                authorName: myName,
                text: text
            )
            expandedThreadIDs.insert(parentID)
        } else {
            CommunityManager.shared.addComment(
                to: pID,
                in: cID,
                authorID: currentUser.id,
                authorName: myName,
                text: text
            )
        }
                
        print("Comment saved! Author: \(myName)")
                
        commentTextField.text = ""
        replyingToCommentID = nil
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return threads.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let replyCount = threads[section].replies.count
        if replyCount == 0 { return 1 }
        
        let isExpanded = expandedThreadIDs.contains(threads[section].parent.id)
        return 1 + 1 + (isExpanded ? replyCount : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        let thread = threads[indexPath.section]
        let replyCount = thread.replies.count
        let isExpanded = expandedThreadIDs.contains(thread.parent.id)
        
        cell.indentationWidth = 16
        
        if indexPath.row == 0 {
            cell.configure(comment: thread.parent)
            cell.indentationLevel = 0
            cell.commentLabel.textColor = .label
            cell.commentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        } else if replyCount > 0 && indexPath.row == 1 {
            cell.configureAsViewReplies(count: replyCount, isExpanded: isExpanded)
            cell.indentationLevel = 1
        } else {
            let replyIndex = indexPath.row - 2
            let reply = thread.replies[replyIndex]
            cell.configure(comment: reply)
            cell.replyButton.isHidden = true
            cell.indentationLevel = 2
            cell.commentLabel.textColor = .secondaryLabel
            cell.commentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
       
        if indexPath.row != 1 || replyCount == 0 {
            let isReplyRow = replyCount > 0 && isExpanded && indexPath.row > 1
            let comment = (indexPath.row == 0) ? thread.parent : (isReplyRow ? thread.replies[indexPath.row - 2] : thread.parent)
            
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
            cell.likeButton.tag = (indexPath.section * 1000) + indexPath.row
            cell.likeButton.addTarget(self, action: #selector(handleLikeComment(_:)), for: .touchUpInside)
            
            cell.replyButton.isHidden = indexPath.row != 0
            cell.replyButton.tag = indexPath.section
            cell.replyButton.addTarget(self, action: #selector(handleReply(_:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let currentUserID = AuthManager.shared.currentUser?.id else { return nil }
        
        let thread = threads[indexPath.section]
        
        if indexPath.row == 1 && thread.replies.count > 0 { return nil }
        
        let comment: Comment
        if indexPath.row == 0 {
            comment = thread.parent
        } else {
            let replyIndex = indexPath.row - 2
            guard replyIndex >= 0, replyIndex < thread.replies.count else { return nil }
            comment = thread.replies[replyIndex]
        }
        guard comment.authorID == currentUserID else { return nil }
        guard let cID = communityID, let pID = postID else { return nil }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            CommunityManager.shared.deleteComment(commentID: comment.id, postID: pID, communityID: cID)
            self.loadComments()
            completion(true)
        }
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thread = threads[indexPath.section]
        let replyCount = thread.replies.count
        guard replyCount > 0 else { return }
       
        if indexPath.row == 1 {
            if expandedThreadIDs.contains(thread.parent.id) {
                expandedThreadIDs.remove(thread.parent.id)
            } else {
                expandedThreadIDs.insert(thread.parent.id)
            }
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    @objc func handleReply(_ sender: UIButton) {
        
        let sectionIndex = sender.tag
        guard sectionIndex >= 0, sectionIndex < threads.count else { return }
        let commentToReply = threads[sectionIndex].parent
        let authorName = commentToReply.authorName
        commentTextField.text = "@\(authorName) "
        replyingToCommentID = commentToReply.id
        commentTextField.becomeFirstResponder()
        
    }
    
    @objc func handleLikeComment(_ sender: UIButton) {
        
        let packed = sender.tag
        let section = packed / 1000
        let row = packed % 1000
        guard section >= 0, section < threads.count else { return }
        
        let thread = threads[section]
        
        if row == 1 && thread.replies.count > 0 { return }
        
        let comment: Comment
        if row == 0 {
            comment = thread.parent
        } else {
            let replyIndex = row - 2
            guard replyIndex >= 0, replyIndex < thread.replies.count else { return }
            comment = thread.replies[replyIndex]
        }
        guard let cID = communityID, let pID = postID else { return }
        CommunityManager.shared.likeComment(commentID: comment.id, postID: pID, communityID: cID)
        loadComments()
    }
    
}



