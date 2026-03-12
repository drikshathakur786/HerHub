//
//  FeaturedPostCollectionCell.swift
//  HerHub
//
//  Created to display featured posts in CommunityViewController collection view.
//

import UIKit

class FeaturedPostCollectionCell: UICollectionViewCell {
    
    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let communityLabel = UILabel()
    private let titleLabel = UILabel()
    private let snippetLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 16
        contentView.addSubview(cardView)
       
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.tintColor = .systemGray4

        communityLabel.translatesAutoresizingMaskIntoConstraints = false
        communityLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        communityLabel.textColor = .systemPink
        
       
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        
        snippetLabel.translatesAutoresizingMaskIntoConstraints = false
        snippetLabel.font = UIFont.systemFont(ofSize: 14)
        snippetLabel.textColor = .label
        snippetLabel.numberOfLines = 0

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        
        let textStack = UIStackView(arrangedSubviews: [communityLabel, titleLabel, snippetLabel, timeLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let headerStack = UIStackView(arrangedSubviews: [avatarImageView, textStack])
        headerStack.axis = .horizontal
        headerStack.alignment = .top
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(headerStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            headerStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(post: Post, community: Community?) {
        communityLabel.text = community?.name ?? "General"
        titleLabel.text = post.title
        snippetLabel.text = post.text
        
        let timeText = post.createdAt.timeAgoDisplay()
        timeLabel.text = timeText
        
        if let theme = community?.themeColor {
            switch theme {
            case "pink":
                communityLabel.textColor = .systemPink
            case "purple":
                communityLabel.textColor = .systemPurple
            case "yellow":
                communityLabel.textColor = .systemYellow
            default:
                communityLabel.textColor = .systemBlue
            }
        } else {
            communityLabel.textColor = .systemBlue
        }
    }
}


