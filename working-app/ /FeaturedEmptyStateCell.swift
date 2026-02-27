//
//  FeaturedEmptyStateCell.swift
//  HerHub
//

import UIKit

class FeaturedEmptyStateCell: UICollectionViewCell {
    
    private let cardView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let browseButton = UIButton(type: .system)
    
    var onBrowseTapped: (() -> Void)?
    
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
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconView.image = UIImage(systemName: "sparkles", withConfiguration: config)
        iconView.tintColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.text = "No featured posts yet"
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0
        bodyLabel.text = "Join a community and like posts you find helpful. We’ll surface the best ones here for you."
        
        browseButton.translatesAutoresizingMaskIntoConstraints = false
        browseButton.setTitle("Browse communities", for: .normal)
        browseButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        browseButton.tintColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
        browseButton.backgroundColor = .clear
        browseButton.layer.cornerRadius = 0
        browseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        browseButton.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, browseButton])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .top
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func browseTapped() {
        onBrowseTapped?()
    }
}

