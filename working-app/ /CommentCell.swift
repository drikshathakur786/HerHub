//
//  CommentCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 22/11/25.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        self.selectionStyle = .none
    }

    func configure(comment: Comment) {
        nameLabel.text = comment.authorName
        commentLabel.text = comment.text
         
        timeLabel.text = comment.createdAt.timeAgoDisplay()
            
        likeButton.setTitle(" \(comment.likesCount)", for: .normal)
         
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .systemGray
    }
    
}

