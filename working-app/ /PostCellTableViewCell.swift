//
//  PostCellTableViewCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 19/11/25.
//

import UIKit

class PostCellTableViewCell: UITableViewCell {
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postBodyLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 16
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 12
        postImageView.clipsToBounds = true
        self.selectionStyle = .none
    }

    private var currentPostID: UUID?

    func configure(post: Post, currentUserID: UUID? = nil) {
        currentPostID = post.id
        
        nameLabel.text = post.authorName
        postBodyLabel.text = post.text
        timeLabel.text = post.createdAt.timeAgoDisplay()
            
        commentButton.setTitle(" \(post.comments.count)", for: .normal)
            
        likeButton.setTitle(" \(post.likesCount)", for: .normal)
            
        if let userID = currentUserID, post.isLikedBy(userID: userID) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemPink
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .systemGray
        }

        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        
        Task {
            if let user = try? await UserController.shared.fetchUser(byID: post.authorID) {
                if let avatarName = user.userPicture, !avatarName.isEmpty {
                    await MainActor.run {
                        // Prevent cell reuse mismatch
                        if self.currentPostID == post.id {
                            self.avatarImageView.image = UIImage(named: avatarName)
                            self.avatarImageView.tintColor = nil
                        }
                    }
                }
            }
        }
            
        if let imageURL = post.imageURL, !imageURL.isEmpty {
            postImageView.isHidden = false
            if let image = loadImageFromDocuments(filename: imageURL) {
                postImageView.image = image
            } else {
                postImageView.image = UIImage(named: imageURL)
            }
        } else {
            postImageView.isHidden = true
        }
    }
    
    private func loadImageFromDocuments(filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }

}

