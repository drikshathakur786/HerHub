//
//  AddCommunityCell.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class AddCommunityCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Solid pink color #F8C8DC
        contentView.backgroundColor = UIColor(red: 0.973, green: 0.784, blue: 0.863, alpha: 1.0)
        contentView.layer.cornerRadius = 20.0
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        // Remove old gradients/shadows/borders if cell is reused
        contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer || $0 is CAShapeLayer })
        self.layer.shadowOpacity = 0
        
        // Make the + icon the signature pink or white. We'll use the signature pink.
        let themePink = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
        for subview in contentView.subviews {
            if let button = subview as? UIButton {
                button.tintColor = themePink
            }
            if let imageView = subview as? UIImageView {
                imageView.tintColor = themePink
            }
        }
    }
}


