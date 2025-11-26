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
        
        // Rounded corners
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // ----- FIX: Prevent the title from stretching the cell -----
        titleButton.titleLabel?.numberOfLines = 1
        titleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.7
        
        // Compression priorities (important!)
        titleButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Center by default, left when configured
        titleButton.contentHorizontalAlignment = .center
        
        // ----- Member Label Fix -----
        memberLabel.numberOfLines = 1
        memberLabel.adjustsFontSizeToFitWidth = true
        memberLabel.minimumScaleFactor = 0.7
        memberLabel.lineBreakMode = .byTruncatingTail
        
        memberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        memberLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    
    // MARK: - Configure Cell with Data
    func configure(title: String, members: String, iconName: String, color: UIColor) {

        // Title fixes
        titleButton.setTitle(title, for: .normal)
        titleButton.setTitleColor(.white, for: .normal)
        titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        titleButton.titleLabel?.numberOfLines = 1
        titleButton.titleLabel?.lineBreakMode = .byTruncatingTail
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.titleLabel?.minimumScaleFactor = 0.8
        
        titleButton.contentHorizontalAlignment = .left

        // Member label fixes
        memberLabel.text = "\(members) members"
        memberLabel.adjustsFontSizeToFitWidth = true
        memberLabel.minimumScaleFactor = 0.7
        
        // Icon & background
        iconImageView.image = UIImage(systemName: iconName)
        contentView.backgroundColor = color
    }
    
    
    // Ensures cell stays within fixed size (160×120)
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        contentView.frame = bounds
//    }
}

