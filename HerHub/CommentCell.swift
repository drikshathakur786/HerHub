//
//  CommentCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 22/11/25.
//

import UIKit

class CommentCell: UITableViewCell {

    // --- OUTLETS ---
        @IBOutlet weak var avatarImageView: UIImageView!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var timeLabel: UILabel!
        @IBOutlet weak var commentLabel: UILabel!
        @IBOutlet weak var likeButton: UIButton!
        @IBOutlet weak var replyButton: UIButton!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // 1. Make Avatar Circular
            avatarImageView.layer.cornerRadius = 20 // Assuming width is 40
            avatarImageView.clipsToBounds = true
            
            // 2. Selection Style
            self.selectionStyle = .none
        }

    func configure(comment: Comment) {
            nameLabel.text = comment.authorName
            commentLabel.text = comment.text
            
            // 1. USE THE REAL TIME
            // This uses the helper we just wrote
            timeLabel.text = comment.createdAt.timeAgoDisplay()
            
            // 2. USE THE REAL LIKE COUNT
            // This will show " 0" for new comments, or the actual number
            likeButton.setTitle(" \(comment.likesCount)", for: .normal)
            
            // Styling
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray4
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .systemGray
        }
    }
