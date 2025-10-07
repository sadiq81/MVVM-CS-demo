
import UIKit

extension Colors.Foreground {
    
    enum Types  {
        case attention
        case brand
        case danger
        case `default`
        case lightmuted
        case light
        case link
        case muted
        case placeholder
        case success
        case custom(UIColor)
        
        var color: UIColor {
            switch self {
                case .attention: return Colors.Foreground.attention.color
                case .brand: return Colors.Foreground.brand.color
                case .danger: return Colors.Foreground.danger.color
                case .`default`: return Colors.Foreground.default.color
                case .lightmuted: return Colors.Foreground.lightMuted.color
                case .light: return Colors.Foreground.light.color
                case .link: return Colors.Foreground.link.color
                case .muted: return Colors.Foreground.muted.color
                case .placeholder: return Colors.Foreground.placeholder.color
                case .success: return Colors.Foreground.success.color
                case .custom(let color): return color
            }
        }
    }
    
}

extension Colors.Border {
    
    enum Types  {
        case brand
        case danger
        case `default`
        case interactiveStrong
        case interactive
        case inverse
        case strong
        case custom(UIColor)
        
        var color: UIColor {
            switch self {
                case .brand: return Colors.Border.brand.color
                case .danger: return Colors.Border.danger.color
                case .default: return Colors.Border.default.color
                case .interactiveStrong: return Colors.Border.interactiveStrong.color
                case .interactive: return Colors.Border.interactive.color
                case .inverse: return Colors.Border.inverse.color
                case .strong: return Colors.Border.strong.color
                case .custom(let color): return color
            }
        }
    }
    
}
