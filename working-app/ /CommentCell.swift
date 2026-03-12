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
        avatarImageView.isHidden = false
        nameLabel.isHidden = false
        timeLabel.isHidden = false
        likeButton.isHidden = false
        replyButton.isHidden = false
        
        nameLabel.text = comment.authorName
        commentLabel.text = comment.text
         
        timeLabel.text = comment.createdAt.timeAgoDisplay()
            
        likeButton.setTitle(" \(comment.likesCount)", for: .normal)
         
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .systemGray
    }
    
    func configureAsViewReplies(count: Int, isExpanded: Bool) {
        avatarImageView.isHidden = true
        nameLabel.isHidden = true
        timeLabel.isHidden = true
        likeButton.isHidden = true
        replyButton.isHidden = true
        
        let title: String
        if isExpanded {
            title = count == 1 ? "Hide reply" : "Hide replies"
        } else {
            title = count == 1 ? "View 1 reply" : "View \(count) replies"
        }
        
        commentLabel.text = title
        commentLabel.textColor = tintColor
        commentLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
    
}


