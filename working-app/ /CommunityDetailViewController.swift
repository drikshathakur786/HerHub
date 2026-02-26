//
//  CommunityDetailViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 19/11/25.
//

import UIKit

class CommunityDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: UIView!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
        
        
    var community: Community?
    
    var originalY: CGFloat?
    private var selectedImage: UIImage?
    

    private var filteredPostIndices: [Int] = []
    private var currentSearchText: String = ""
    private var isFiltering: Bool {
        return !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
        
    override func viewDidLoad() {
            
        super.viewDidLoad()
        print("Detail VC Loaded. Community: \(community?.name ?? "Nil"). Posts: \(community?.posts.count ?? 0)")

        title = "FirstFlow"
        navigationController?.navigationBar.prefersLargeTitles = true
        title = community?.name
        
         
        tableView.delegate = self
        tableView.dataSource = self
            
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        setupSearchBar()
        setupPhotoButton()
        
        setupKeyboardHandling()
        
        
    }
    
    @IBAction func leaveCommunityTapped(_ sender: Any) {
        guard let currentCommunity = community,
              let currentUser = AuthManager.shared.currentUser else { return }
        
        let alert = UIAlertController(
            title: "Leave Community?",
            message: "You will no longer see posts from this community on your Community screen.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
            CommunityManager.shared.leaveCommunity(communityID: currentCommunity.id, userID: currentUser.id)
            
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
         
            self.navigationController?.popViewController(animated: true)
        }))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search posts"
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .done
        searchBar.sizeToFit()
      
        let bgColor = tableView.backgroundColor ?? view.backgroundColor ?? .systemBackground
        searchBar.barTintColor = bgColor
        searchBar.backgroundColor = bgColor
        searchBar.isTranslucent = false
        
        searchBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            let textField = searchBar.searchTextField
            textField.backgroundColor = .white.withAlphaComponent(0.9)
        }
        
        tableView.tableHeaderView = searchBar
    }
        
   
    func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tableView.addGestureRecognizer(tap)
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardFrame.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
    }
    
    private func setupPhotoButton() {
        photoButton?.setImage(UIImage(systemName: "photo"), for: .normal)

    }
      
    @IBAction func photoButtonTapped(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            present(picker, animated: true)
    }
        

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        photoButton?.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        photoButton?.tintColor = .systemGreen
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        private func saveImageLocally(_ image: UIImage) -> String? {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            
            let filename = "post_image_\(UUID().uuidString).jpg"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            do {
                try imageData.write(to: fileURL)
                return filename
            } catch {
                print("Error saving image: \(error)")
                return nil
            }
        }
}


extension CommunityDetailViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return 1
            } else {
                guard let posts = community?.posts else { return 0 }
                return isFiltering ? filteredPostIndices.count : posts.count
            }
        }
        

        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCellTableViewCell
                    
                    guard let posts = community?.posts else { return cell }
                    let postIndex: Int
                    if isFiltering {
                        postIndex = filteredPostIndices[indexPath.row]
                    } else {
                        postIndex = indexPath.row
                    }
                    
                    let post = posts[postIndex]
                            
                    let currentUserID = AuthManager.shared.currentUser?.id
                    cell.configure(post: post, currentUserID: currentUserID)
                        
                    cell.likeButton.tag = postIndex
                    cell.likeButton.addTarget(self, action: #selector(handleLike(_:)), for: .touchUpInside)
                        
                    cell.flagButton.tag = postIndex
                    cell.flagButton.addTarget(self, action: #selector(handleFlag(_:)), for: .touchUpInside)
                       
                    cell.commentButton.tag = postIndex
                    cell.commentButton.addTarget(self, action: #selector(handleComment(_:)), for: .touchUpInside)
                    
                    return cell
                }
        }

        @objc func handleFlag(_ sender: UIButton) {
            
            let rowIndex = sender.tag
            guard let post = community?.posts[rowIndex] else { return }
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            
            if let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportPostVC") as? ReportViewController {
                reportVC.postID = post.id
                reportVC.communityID = post.communityID
                self.present(reportVC, animated: true)
            }
            
        }
        
        @objc func handleLike(_ sender: UIButton) {
            
            let rowIndex = sender.tag
            guard let post = community?.posts[rowIndex] else { return }
            guard let currentUser = AuthManager.shared.currentUser else {
                print("No user logged in - cannot like post")
                return
            }
            CommunityManager.shared.likePost(postID: post.id, communityID: post.communityID, userID: currentUser.id)
                
            if let updatedCommunity = CommunityManager.shared.getCommunity(by: post.communityID) {
                self.community = updatedCommunity
                let indexPath = IndexPath(row: rowIndex, section: 1)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        @objc func handleComment(_ sender: UIButton) {
            
            let rowIndex = sender.tag
            guard let post = community?.posts[rowIndex] else { return }
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsViewController {
                
                commentsVC.postID = post.id
                commentsVC.communityID = post.communityID
                if let sheet = commentsVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                self.present(commentsVC, animated: true)
            }
        }
    
    
        @IBAction func sendPostTapped(_ sender: Any) {
                
            guard let text = postTextField.text, !text.isEmpty else { return }
            guard let currentCommunity = community else { return }
                
            guard let currentUser = AuthManager.shared.currentUser else {
                print("No user logged in - cannot create post")
                return
            }
                
            let authorName = currentUser.userName ?? "Anonymous"
                
            var imageFilename: String? = nil
            if let image = selectedImage {
                imageFilename = saveImageLocally(image)
            }
                
              
            CommunityManager.shared.addPost(
                to: currentCommunity.id,
                authorID: currentUser.id,
                authorName: authorName,
                title: "New Post",
                text: text,
                imageURL: imageFilename
            )
                
            print("Post created by: \(currentUser.email ?? "unknown")")
            if imageFilename != nil {
                print("Post includes photo: \(imageFilename!)")
            }
                
            postTextField.text = ""
            selectedImage = nil
            photoButton?.setImage(UIImage(systemName: "photo"), for: .normal)
            photoButton?.tintColor = .systemBlue
            postTextField.resignFirstResponder()
            
            if let updatedCommunity = CommunityManager.shared.getCommunity(by: currentCommunity.id) {
                
                self.community = updatedCommunity
                tableView.reloadData()
                
                let lastRow = (isFiltering ? filteredPostIndices.count : updatedCommunity.posts.count) - 1
                
                if lastRow >= 0 {
                    let indexPath = IndexPath(row: lastRow, section: 1)
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }

}

extension CommunityDetailViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        applyFilter()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func applyFilter() {
        guard let posts = community?.posts else {
            filteredPostIndices = []
            tableView.reloadData()
            return
        }
        
        let query = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            filteredPostIndices = []
        } else {
            filteredPostIndices = posts.enumerated().compactMap { index, post in
                let haystack = "\(post.title) \(post.text)".lowercased()
                return haystack.contains(query) ? index : nil
            }
        }
        tableView.reloadData()
    }
}

