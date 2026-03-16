//
//  ExtensionClass.swift
//  PropDub
//
//  Created by acme on 17/05/24.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        get { return CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let cgColor = layer.shadowColor else {
                return .darkGray
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
}

extension UIFont{
    
    class func boldFont(size:CGFloat) -> UIFont{
        return UIFont(name: "DMSans24pt-Medium", size: size) ?? UIFont()
    }
    
    class func regularFont(size:CGFloat) -> UIFont{
        return UIFont(name: "DMSans24pt-Regular", size: size) ?? UIFont()
    }
}



extension UICollectionView {
    
    func registerNib(nibName:String){
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
    }
    func registerFooterNib(nibName: String) {
        self.register(UINib(nibName: nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: nibName)
    }
}

extension UITableView{
    
    func registerNib(nibName:String) {
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    func isEmptyCheck() -> Bool{
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension UIImage{
    
    class func placeholderImage() -> UIImage{
        return UIImage.init(named: "ic_defaultPic") ?? UIImage()
    }
}

extension UIViewController {
    func showGuestLoginPrompt(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "Account Required",
            message: "You need an account to use this feature. Would you like to create one now?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create Account", style: .default, handler: { _ in
            // Push to auth screen
            Task {
                await AuthManager.shared.signOut()
                await MainActor.run {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                        if let authVC = storyboard.instantiateInitialViewController() {
                            window.rootViewController = authVC
                            window.makeKeyAndVisible()
                        }
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
}
