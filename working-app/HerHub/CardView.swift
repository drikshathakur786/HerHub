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

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
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
