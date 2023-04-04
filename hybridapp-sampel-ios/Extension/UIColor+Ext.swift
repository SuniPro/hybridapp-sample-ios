import UIKit

extension UIColor {
    static func rgba(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor{
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static func sameRGB(rgb:CGFloat) -> UIColor{
        return UIColor.init(red: rgb/255, green: rgb/255, blue: rgb/255, alpha: 1)
    }
}
