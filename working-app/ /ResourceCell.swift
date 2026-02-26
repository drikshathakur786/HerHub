//
//  ResourceCell.swift
//  HerHub
//

import UIKit

class ResourceCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        cardView.layer.cornerRadius = 15
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = .white
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
  
        thumbImageView.layer.cornerRadius = 15
        thumbImageView.clipsToBounds = true
        thumbImageView.contentMode = .scaleAspectFill
 
        badgeLabel.layer.cornerRadius = 11
        badgeLabel.clipsToBounds = true
        badgeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
  
        timeLabel.backgroundColor = UIColor(white: 0.95, alpha: 1) // light grey capsule
        timeLabel.textColor = .darkGray
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textAlignment = .center
        timeLabel.layer.cornerRadius = 9
        timeLabel.layer.masksToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2

        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.textColor = .darkGray
        descLabel.numberOfLines = 0
        
      

        
    }

    
        func configure(with resource: Resource) {
            titleLabel.text = resource.title
            descLabel.text = resource.description
            timeLabel.text = resource.estimatedReadTime
            badgeLabel.text = resource.category.rawValue
            thumbImageView.image = UIImage(named: resource.imageURL ?? "")
            
                        
            badgeLabel.layer.masksToBounds = true
        }
}
