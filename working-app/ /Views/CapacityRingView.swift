//
//  CapacityRingView.swift
//  HerHub
//
//  Custom circular progress ring for Bio-Capacity display
//

import UIKit

@IBDesignable
class CapacityRingView: UIView {
    
    // MARK: - Properties
    @IBInspectable var capacity: Int = 85 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var ringWidth: CGFloat = 12.0
    
    @IBInspectable var showPercentage: Bool = true {
        didSet {
            percentageLabel.isHidden = !showPercentage
            subtitleLabel.isHidden = !showPercentage
        }
    }
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFProRounded-Bold", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .rosePink
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFProRounded-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .slateGray
        label.text = "Bio-Capacity"
        return label
    }()
    
    // MARK: - Layer Components
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        setupLabels()
        setupLayers()
    }
    
    private func setupLayers() {
        // Path configuration
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2 - ringWidth / 2 - 5
        let startAngle = -CGFloat.pi / 2
        let endAngle = 3 * CGFloat.pi / 2
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Background Ring (Pink)
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor(red: 1.0, green: 0.85, blue: 0.9, alpha: 1.0).cgColor // Explicit Pink
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = ringWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        // Progress Ring
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.rosePink.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = ringWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Re-calculate paths on layout update
        setupLayers()
        setProgress(to: CGFloat(capacity) / 100.0, animated: false)
    }
    
    private func setupLabels() {
        addSubview(percentageLabel)
        addSubview(subtitleLabel)
        
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 2)
        ])
    }
    
    // MARK: - Public Methods
    func updateCapacity(_ newCapacity: Int, animated: Bool = true) {
        self.capacity = newCapacity
        percentageLabel.text = "\(capacity)%"
        
        // Update color based on capacity
        let color: UIColor
        if capacity >= 70 {
            color = UIColor(red: 0.9, green: 0.5, blue: 0.6, alpha: 1.0) // Rose
        } else if capacity >= 40 {
            color = UIColor(red: 0.95, green: 0.7, blue: 0.5, alpha: 1.0) // Orange
        } else {
            color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Gray
        }
        progressLayer.strokeColor = color.cgColor
        
        setProgress(to: CGFloat(capacity) / 100.0, animated: animated)
    }
    
    private func setProgress(to value: CGFloat, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = value
            animation.duration = 0.8
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: "progressAnim")
        }
        progressLayer.strokeEnd = value
    }
}

// MARK: - Color Extensions
extension UIColor {
    static let slateGray = UIColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 1.0)
    static let rosePink = UIColor(red: 0.9, green: 0.5, blue: 0.6, alpha: 1.0)
    static let roseLight = UIColor(red: 1.0, green: 0.9, blue: 0.95, alpha: 1.0)
}
