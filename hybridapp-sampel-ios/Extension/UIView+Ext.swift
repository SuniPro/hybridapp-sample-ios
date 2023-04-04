import Foundation
import UIKit

extension UIView {
    func addConstraintsWithFormat(_ format:String, views:UIView...) {
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated() {
            viewsDictionary["v\(index)"] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: viewsDictionary))
    }
    
    @IBInspectable var borderWidth: CGFloat {
            set {
                layer.borderWidth = newValue
            }
            get {
                return layer.borderWidth
            }
        }
        
        @IBInspectable var cornerRadius: CGFloat {
            set {
                layer.cornerRadius = newValue
            }
            get {
                return layer.cornerRadius
            }
        }
        
        @IBInspectable var borderColor: UIColor? {
            set {
                guard let uiColor = newValue else { return }
                layer.borderColor = uiColor.cgColor
            }
            get {
                guard let color = layer.borderColor else { return nil }
                return UIColor(cgColor: color)
            }
        }
    
    func parentViewController_Recommend() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.parentViewController_Recommend()
        } else {
            return nil
        }
    }
    
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
}
