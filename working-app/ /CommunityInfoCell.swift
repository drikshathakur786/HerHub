//
//  CommunityInfoCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class CommunityInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var memberLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        titleButton.titleLabel?.numberOfLines = 1
        titleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.7
        titleButton.isUserInteractionEnabled = false
        
        titleButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        titleButton.contentHorizontalAlignment = .center
        
        memberLabel.numberOfLines = 1
        memberLabel.adjustsFontSizeToFitWidth = true
        memberLabel.minimumScaleFactor = 0.7
        memberLabel.lineBreakMode = .byTruncatingTail
        
        memberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        memberLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
    }
    
 
    func configure(title: String, members: String, iconName: String, color: UIColor) {

        titleButton.setTitle(title, for: .normal)
        titleButton.setTitleColor(.white, for: .normal)
        titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        titleButton.titleLabel?.numberOfLines = 1
        titleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.8
        
        titleButton.contentHorizontalAlignment = .left

        memberLabel.text = "\(members) members"
        memberLabel.adjustsFontSizeToFitWidth = true
        memberLabel.minimumScaleFactor = 0.7
    
        iconImageView.image = UIImage(systemName: iconName)
        
        // Remove any old gradient layers if a cell is reused
        contentView.layer.sublayers?.removeAll(where: { $0.name == "PremiumThemeGradient" })
        
        // Apply solid pastel color
        contentView.backgroundColor = color
    }

}



