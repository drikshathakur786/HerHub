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
    
    private var currentPostID: UUID?

    func configure(post: Post, community: Community?) {
        currentPostID = post.id
        
        titleLabel.text = post.title
        snippetLabel.text = post.text

        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray4
        
        Task {
            if let user = try? await UserController.shared.fetchUser(byID: post.authorID) {
                if let avatarName = user.userPicture, !avatarName.isEmpty {
                    await MainActor.run {
                        if self.currentPostID == post.id {
                            self.avatarImageView.image = UIImage(named: avatarName)
                            self.avatarImageView.tintColor = nil
                        }
                    }
                }
            }
        }
        timeLabel.text = post.createdAt.timeAgoDisplay()

        categoryLabel.text = community?.name ?? "General"

        if let theme = community?.themeColor {
            categoryLabel.textColor = UIColor.themeColor(from: theme)
        } else {
            categoryLabel.textColor = .systemBlue
        }
        
    }

}


