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
    
    private var displayedPosts: [Post] = []
    
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
  
        if let rightItem = navigationItem.rightBarButtonItem {
            rightItem.title = nil
            rightItem.image = UIImage(systemName: "ellipsis")
        }
        
         
        tableView.delegate = self
        tableView.dataSource = self
            
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        setupSearchBar()
        setupPhotoButton()
        
        setupKeyboardHandling()

        configureRespectCoachmark()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDisplayedPostsFromNotification),
            name: NSNotification.Name("RefreshCommunityData"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDisplayedPosts()
    }
   
    private func refreshDisplayedPosts() {
        guard let cid = community?.id else { return }
        if let updated = CommunityManager.shared.getCommunity(by: cid) {
            community = updated
        }
        displayedPosts = CommunityManager.shared.getPostsForDisplay(
            in: cid,
            currentUserID: AuthManager.shared.currentUser?.id
        )
        applyFilter()
        tableView.reloadData()
    }
    
    @objc private func refreshDisplayedPostsFromNotification() {
        refreshDisplayedPosts()
    }

    // MARK: - Be respectful coachmark (bottom input)

    private var respectCoachmarkDismissedKey: String {
        let userPart = AuthManager.shared.currentUser?.id.uuidString ?? "anonymous"
        return "herhub_respectCoachmarkDismissed_\(userPart)"
    }

    private var isRespectCoachmarkDismissed: Bool {
        get { UserDefaults.standard.bool(forKey: respectCoachmarkDismissedKey) }
        set { UserDefaults.standard.set(newValue, forKey: respectCoachmarkDismissedKey) }
    }

    private func setRespectCoachmarkVisible(_ visible: Bool) {
        guard let coachmarkView = bottomInputView.viewWithTag(4003) else { return }
        coachmarkView.isHidden = !visible

        // Collapse/expand the coachmark's fixed-height constraint.
        if let heightConstraint = coachmarkView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = visible ? 36 : 0
        }

        bottomInputView.layoutIfNeeded()
    }

    private func configureRespectCoachmark() {
        // Wire buttons from storyboard by tag.
        let dismissButton = bottomInputView.viewWithTag(4001) as? UIButton
        let infoButton = bottomInputView.viewWithTag(4004) as? UIButton

        dismissButton?.removeTarget(nil, action: nil, for: .allEvents)
        infoButton?.removeTarget(nil, action: nil, for: .allEvents)

        dismissButton?.addTarget(self, action: #selector(didTapDismissRespectCoachmark), for: .touchUpInside)
        infoButton?.addTarget(self, action: #selector(didTapRespectInfo), for: .touchUpInside)

        // One-time: hide if already dismissed.
        setRespectCoachmarkVisible(!isRespectCoachmarkDismissed)
    }

    @objc private func didTapDismissRespectCoachmark() {
        isRespectCoachmarkDismissed = true
        setRespectCoachmarkVisible(false)
    }

    @objc private func didTapRespectInfo() {
        // Allow re-show any time via the info button.
        setRespectCoachmarkVisible(true)
    }

    private var noticeCollapsedDefaultsKey: String {
        let communityPart = community?.id.uuidString ?? "unknown_community"
        let userPart = AuthManager.shared.currentUser?.id.uuidString ?? "anonymous"
        return "herhub_noticeCollapsed_\(communityPart)_\(userPart)"
    }

    private var isNoticeCollapsed: Bool {
        get { UserDefaults.standard.bool(forKey: noticeCollapsedDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: noticeCollapsedDefaultsKey) }
    }

    @objc private func collapseNoticeTapped() {
        isNoticeCollapsed = true
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.endUpdates()
    }

    @objc private func expandNoticeTapped() {
        isNoticeCollapsed = false
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.endUpdates()
    }
    
    @objc private func editCommunityTapped() {
        guard let community = community else { return }
        
        let storyboard = UIStoryboard(name: "community", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "CreateCommunityVC") as? CreateCommunityViewController {
            editVC.editingCommunity = community
            editVC.onCommunityUpdated = { [weak self] in
                guard let self = self else { return }
                if let updated = CommunityManager.shared.getCommunity(by: community.id) {
                    self.community = updated
                    self.title = updated.name
                    self.refreshDisplayedPosts()
                }
            }
            
            editVC.modalPresentationStyle = .pageSheet
            if let sheet = editVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(editVC, animated: true)
        }
    }
    
    @IBAction func leaveCommunityTapped(_ sender: Any) {
        guard let currentCommunity = community,
              let currentUser = AuthManager.shared.currentUser else { return }
        
        let isCreator = currentCommunity.createdBy == currentUser.id
        
        let alert = UIAlertController(
            title: currentCommunity.name,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        if isCreator {
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
                self?.editCommunityTapped()
            }))
            
            alert.addAction(UIAlertAction(title: "Delete Community", style: .destructive, handler: { _ in
                CommunityManager.shared.deleteCommunity(communityID: currentCommunity.id)
                NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Leave Community", style: .destructive, handler: { _ in
            CommunityManager.shared.leaveCommunity(communityID: currentCommunity.id, userID: currentUser.id)
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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

        guard postTextField.isFirstResponder else { return }
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
                if isFiltering {
                    return filteredPostIndices.isEmpty ? 1 : filteredPostIndices.count
                } else {
                    return displayedPosts.isEmpty ? 1 : displayedPosts.count
                }
            }
        }
        

        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
                    let expandedView = cell.contentView.viewWithTag(3003)
                    let closeButton = cell.contentView.viewWithTag(3001) as? UIButton
                    let collapsedButton = cell.contentView.viewWithTag(3002) as? UIButton

                    expandedView?.isHidden = isNoticeCollapsed
                    closeButton?.isHidden = isNoticeCollapsed
                    collapsedButton?.isHidden = !isNoticeCollapsed

                    // Ensure buttons are tappable and not obscured by other subviews.
                    closeButton?.isUserInteractionEnabled = true
                    collapsedButton?.isUserInteractionEnabled = true
                    if let closeButton {
                        closeButton.superview?.bringSubviewToFront(closeButton)
                    }

                    closeButton?.removeTarget(nil, action: nil, for: .allEvents)
                    collapsedButton?.removeTarget(nil, action: nil, for: .allEvents)
                    closeButton?.addTarget(self, action: #selector(collapseNoticeTapped), for: .touchUpInside)
                    collapsedButton?.addTarget(self, action: #selector(expandNoticeTapped), for: .touchUpInside)
                    return cell
                } else {
                    let isEmpty: Bool
                    if isFiltering {
                        isEmpty = filteredPostIndices.isEmpty
                    } else {
                        isEmpty = displayedPosts.isEmpty
                    }
                    if isEmpty {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyPostsCell", for: indexPath)
                        let label = cell.contentView.viewWithTag(1001) as? UILabel
                        if isFiltering {
                            label?.text = "No matching posts"
                        } else {
                            label?.text = "No posts yet\nBe the first to post"
                        }
                        return cell
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCellTableViewCell
                    
                    let postIndex: Int
                    if isFiltering {
                        postIndex = filteredPostIndices[indexPath.row]
                    } else {
                        postIndex = indexPath.row
                    }
                    guard postIndex >= 0, postIndex < displayedPosts.count else { return cell }
                    let post = displayedPosts[postIndex]
                            
                    let currentUserID = AuthManager.shared.currentUser?.id
                    cell.configure(post: post, currentUserID: currentUserID)
                        
                    cell.likeButton.tag = postIndex
                    cell.likeButton.addTarget(self, action: #selector(handleLike(_:)), for: .touchUpInside)
                        
                    // Don't allow reporting your own post.
                    let isOwnPost = (currentUserID != nil && post.authorID == currentUserID)
                    cell.flagButton.isHidden = isOwnPost
                    cell.flagButton.isEnabled = !isOwnPost
                    cell.flagButton.tag = postIndex
                    cell.flagButton.removeTarget(nil, action: nil, for: .allEvents)
                    if !isOwnPost {
                        cell.flagButton.addTarget(self, action: #selector(handleFlag(_:)), for: .touchUpInside)
                    }
                       
                    cell.commentButton.tag = postIndex
                    cell.commentButton.addTarget(self, action: #selector(handleComment(_:)), for: .touchUpInside)
                    
                    return cell
                }
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         
            guard indexPath.section == 1 else { return nil }
            if displayedPosts.isEmpty || (isFiltering && filteredPostIndices.isEmpty) { return nil }
            guard let currentUserID = AuthManager.shared.currentUser?.id else { return nil }
            
            let postIndex: Int = isFiltering ? filteredPostIndices[indexPath.row] : indexPath.row
            guard postIndex >= 0, postIndex < displayedPosts.count else { return nil }
            
            let post = displayedPosts[postIndex]
            guard post.authorID == currentUserID else { return nil }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                guard let self = self else { return }
                CommunityManager.shared.deletePost(postID: post.id, in: post.communityID)
                
                if let updated = CommunityManager.shared.getCommunity(by: post.communityID) {
                    self.community = updated
                }
                self.refreshDisplayedPosts()
                NotificationCenter.default.post(name: NSNotification.Name("RefreshCommunityData"), object: nil)
                completion(true)
            }
            delete.backgroundColor = .systemRed
            
            return UISwipeActionsConfiguration(actions: [delete])
        }

        @objc func handleFlag(_ sender: UIButton) {
            let rowIndex = sender.tag
            guard rowIndex >= 0, rowIndex < displayedPosts.count else { return }
            let post = displayedPosts[rowIndex]
            if let currentUserID = AuthManager.shared.currentUser?.id, post.authorID == currentUserID {
                return
            }
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            
            if let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportPostVC") as? ReportViewController {
                reportVC.postID = post.id
                reportVC.communityID = post.communityID
                reportVC.onReportSubmitted = { [weak self] in
                    self?.refreshDisplayedPosts()
                }
                self.present(reportVC, animated: true)
            }
        }
        
        @objc func handleLike(_ sender: UIButton) {
            let rowIndex = sender.tag
            guard rowIndex >= 0, rowIndex < displayedPosts.count else { return }
            let post = displayedPosts[rowIndex]
            guard let currentUser = AuthManager.shared.currentUser else {
                print("No user logged in - cannot like post")
                return
            }
            CommunityManager.shared.likePost(postID: post.id, communityID: post.communityID, userID: currentUser.id)
                
            if let updatedCommunity = CommunityManager.shared.getCommunity(by: post.communityID) {
                self.community = updatedCommunity
                self.refreshDisplayedPosts()
            }
        }
        
        @objc func handleComment(_ sender: UIButton) {
            let rowIndex = sender.tag
            guard rowIndex >= 0, rowIndex < displayedPosts.count else { return }
            let post = displayedPosts[rowIndex]
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
            
            if ContentFilter.containsOffensiveLanguage(text) {
                let alert = UIAlertController(
                    title: "Please adjust your post",
                    message: "To keep HerHub safe and supportive for everyone, please remove offensive language before posting.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
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
                self.refreshDisplayedPosts()
                
                let lastRow = displayedPosts.count - 1
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
        let posts = displayedPosts
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


