//
//  FeaturedPostCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class FeaturedPostCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView! // The white background view
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none 
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // ADD THIS FUNCTION
    func configure(post: Post, community: Community?) {
        titleLabel.text = post.title
        snippetLabel.text = post.text

        // Set placeholder avatar and time for now
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        timeLabel.text = "2hrs" // You can format post.createdAt later

        // Set category info
        categoryLabel.text = community?.name ?? "General"

        // Set category color
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
