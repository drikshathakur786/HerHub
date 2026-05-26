import UIKit

@IBDesignable
class CardView: UIView {

    @IBInspectable override var cornerRadius: CGFloat {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable override var borderWidth: CGFloat {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable override var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable override var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }

    @IBInspectable override var shadowOpacity: CGFloat {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }

    @IBInspectable override var shadowOffset: CGSize {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable override var shadowRadius: CGFloat {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var startColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    @IBInspectable var endColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // MARK: - Interactive Animations
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        feedbackGenerator.prepare()
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        feedbackGenerator.impactOccurred()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [.allowUserInteraction]) {
            self.transform = .identity
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
        
        // Enforce Apple Ecosystem premium aesthetics
        layer.cornerCurve = .continuous
        
        // Convert old black shadows to soft tinted shadows automatically
        if layer.shadowColor == UIColor.black.cgColor {
            layer.shadowColor = UIColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            layer.shadowOpacity = 0.08
            layer.shadowOffset = CGSize(width: 0, height: 8)
            layer.shadowRadius = 15
        }
        
        // Performance optimizations for 60fps scrolling
        if layer.cornerRadius > 0 {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    private func updateGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        
        if let start = startColor, let end = endColor {
            gradientLayer.colors = [start.cgColor, end.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        } else {
            // Fallback to background color if no gradient is set
            // But since layer is CAGradientLayer, backgroundColor property of UIView might behave differently.
            // Usually it's better to keep UIView as is and add a sublayer, but changing layerClass is cleaner for full gradient views.
            // However, if start/end are nil, we might want solid color.
            // CAGradientLayer supports backgroundColor as well.
            gradientLayer.colors = nil
        }
    }
}
