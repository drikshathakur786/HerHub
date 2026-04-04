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
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 16
        cardView.layer.masksToBounds = false
        contentView.addSubview(cardView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        iconView.image = UIImage(systemName: "sparkles", withConfiguration: config)
        iconView.tintColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.text = "No Featured Posts"
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 15)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.text = "Join communities to see top posts resurfaced here for you."
        
        browseButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            var btnConfig = UIButton.Configuration.tinted()
            btnConfig.baseBackgroundColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
            btnConfig.baseForegroundColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0)
            btnConfig.cornerStyle = .capsule
            var formatTitle = AttributedString("Browse Communities")
            formatTitle.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            btnConfig.attributedTitle = formatTitle
            btnConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            browseButton.configuration = btnConfig
        } else {
            browseButton.setTitle("Browse Communities", for: .normal)
            browseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            browseButton.setTitleColor(UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 1.0), for: .normal)
            browseButton.backgroundColor = UIColor(red: 0.878, green: 0.463, blue: 0.671, alpha: 0.15)
            browseButton.layer.cornerRadius = 20
            browseButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        }
        browseButton.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.alignment = .center
        textStack.spacing = 8
        
        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack, browseButton])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32)
        ])
    }
    
    @objc private func browseTapped() {
        onBrowseTapped?()
    }
}


