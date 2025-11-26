//
//  AllCommunityCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class AllCommunityCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. EXISTING STYLING
        self.selectionStyle = .none
        cardView.layer.cornerRadius = 20.0
        cardView.layer.masksToBounds = true
        iconBackgroundView.layer.cornerRadius = 16.0
        iconBackgroundView.layer.masksToBounds = true
        
        // 2. NEW: MAKE ICONS WHITE & BOLD
        // This forces the icon to be White, just like Figma
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
    }

    func configure(community: Community, isJoined: Bool) {
        titleLabel.text = community.name
        descriptionLabel.text = community.description
        memberLabel.text = "\(community.members.count) members"
        
        // 1. Create Bold Config for thicker icons
        let config = UIImage.SymbolConfiguration(weight: .bold)
        
        // 2. Force the icon to always be WHITE
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        // 3. Set Colors and Icons
        if community.themeColor == "pink" {
            iconBackgroundView.backgroundColor = .systemPink
            iconImageView.image = UIImage(systemName: "heart", withConfiguration: config)
            
        } else if community.themeColor == "purple" {
            iconBackgroundView.backgroundColor = .systemPurple
            iconImageView.image = UIImage(systemName: "heart.circle", withConfiguration: config)
            
        } else if community.themeColor == "green" {
            iconBackgroundView.backgroundColor = .systemGreen
            iconImageView.image = UIImage(systemName: "leaf", withConfiguration: config)
            
        } else {
            // --- MENTAL WELLNESS (Blue) ---
            // "cyan" matches the light blue in Figma better than standard blue
            iconBackgroundView.backgroundColor = .systemCyan
            
            // "aqi.medium" looks like a Lotus Flower 🪷
            // If this doesn't show, try "brain.head.profile"
            iconImageView.image = UIImage(systemName: "aqi.medium", withConfiguration: config)
        }
        
        // 4. Set Button State
        if isJoined {
            joinButton.setTitle("Joined", for: .normal)
            joinButton.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            joinButton.setTitleColor(.white, for: .normal)
            joinButton.layer.cornerRadius = 15.0
        } else {
            joinButton.setTitle("Join", for: .normal)
            joinButton.backgroundColor = .systemGreen
            joinButton.setTitleColor(.white, for: .normal)
            joinButton.layer.cornerRadius = 15.0
        }
    }
}
