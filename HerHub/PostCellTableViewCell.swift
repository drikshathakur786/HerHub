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

        // Configure the view for the selected state
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
            // Styling
            cardView.layer.cornerRadius = 16
            avatarImageView.layer.cornerRadius = 20 // Assuming width is 40
            avatarImageView.clipsToBounds = true
            postImageView.layer.cornerRadius = 12
            postImageView.clipsToBounds = true
            
            // Remove default selection color
            self.selectionStyle = .none
        }

    func configure(post: Post) {
            nameLabel.text = post.authorName
            postBodyLabel.text = post.text
            
            // 1. FIX TIME: Use the real time (Requires DateExtension.swift)
            // This will show "Just now", "5m", etc.
            timeLabel.text = post.createdAt.timeAgoDisplay()
            
            // 2. FIX COMMENT COUNT: Show the real number of comments
            // This will show "0" for new posts!
            commentButton.setTitle(" \(post.comments.count)", for: .normal)
            
            // 3. Like Count
            likeButton.setTitle(" \(post.likesCount)", for: .normal)

            // 4. Avatar (Placeholder)
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray4
            
            // 5. Post Image Logic
            if let imageURL = post.imageURL, !imageURL.isEmpty {
                postImageView.isHidden = false
                postImageView.image = UIImage(named: imageURL)
            } else {
                postImageView.isHidden = true
            }
        }

}
