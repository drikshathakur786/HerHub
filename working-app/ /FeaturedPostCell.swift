//
//  FeaturedPostCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class FeaturedPostCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none 
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(post: Post, community: Community?) {
        
        titleLabel.text = post.title
        snippetLabel.text = post.text

        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        timeLabel.text = post.createdAt.timeAgoDisplay()

        categoryLabel.text = community?.name ?? "General"

        if community?.themeColor == "pink" {
            categoryLabel.textColor = .systemPink
        } else if community?.themeColor == "purple" {
            categoryLabel.textColor = .systemPurple
        } else if community?.themeColor == "yellow" {
            categoryLabel.textColor = .systemYellow
        } else {
            categoryLabel.textColor = .systemBlue
        }
        
    }

}
