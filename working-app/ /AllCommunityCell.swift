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
    
    var onJoinTapped: (() -> Void)?


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
      
        self.selectionStyle = .none
        cardView.layer.cornerRadius = 20.0
        cardView.layer.masksToBounds = true
        iconBackgroundView.layer.cornerRadius = 16.0
        iconBackgroundView.layer.masksToBounds = true
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        joinButton.isUserInteractionEnabled = true
        
    }
    
    @IBAction func joinButtonTapped(_ sender: Any) {
            onJoinTapped?()
    }
    
    func configure(community: Community, isJoined: Bool) {
        
        titleLabel.text = community.name
        descriptionLabel.text = community.description
        memberLabel.text = "\(community.members.count) members"
       
        let config = UIImage.SymbolConfiguration(weight: .bold)
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit

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
            iconBackgroundView.backgroundColor = .systemCyan
            iconImageView.image = UIImage(systemName: "aqi.medium", withConfiguration: config)
        }
       
        if isJoined {
            joinButton.setTitle("Joined", for: .normal)
            //joinButton.backgroundColor = .systemGreen.withAlphaComponent(0.5)
            //joinButton.setTitleColor(.white, for: .normal)
            
            joinButton.backgroundColor = .systemGray5
            joinButton.setTitleColor(.systemGreen, for: .normal)
            
            joinButton.layer.cornerRadius = 15.0
            joinButton.isEnabled = false
        } else {
            joinButton.setTitle("Join", for: .normal)
            joinButton.backgroundColor = .systemGreen
            joinButton.setTitleColor(.white, for: .normal)
            joinButton.layer.cornerRadius = 15.0
            joinButton.isEnabled = true
        }
        
    }
}

