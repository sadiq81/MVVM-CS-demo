
import UIKit

extension UIFont.TextStyle {
    
    var emphasized: UIFont.TextStyle {
        switch self{
            case .largeTitle: return .emphasizedLargeTitle
            case .title1: return.emphasizedTitle1
            case .title2: return.emphasizedTitle2
            case .title3: return .emphasizedTitle3
            case .headline: return .emphasizedHeadline
            case .subheadline: return .emphasizedSubheadline
            case .body: return .emphasizedBody
            case .callout: return .emphasizedCallout
            case .footnote: return .emphasizedFootnote
            case .caption1: return .emphasizedCaption1
            case .caption2: return .emphasizedCaption2
            default: return self
        }
    }
    
}

extension UIFont.TextStyle {
    
    static var emphasizedLargeTitle: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedTitle0")
    }
    
    static var emphasizedTitle1: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedTitle1")
    }
    
    static var emphasizedTitle2: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedTitle2")
    }
    
    static var emphasizedTitle3: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedTitle3")
    }
    
    static var emphasizedHeadline: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedHeadline")
    }
    
    static var emphasizedBody: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedBody")
    }
    
    static var shortEmphasizedBody: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleShortEmphasizedBody")
    }
    
    static var shortBody: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleShortBody")
    }
    
    static var emphasizedCallout: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedCallout")
    }
    
    static var emphasizedSubheadline: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedSubhead")
    }
    
    static var emphasizedFootnote: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedFootnote")
    }
    
    static var emphasizedCaption1: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedCaption1")
    }
    
    static var emphasizedCaption2: UIFont.TextStyle {
        return UIFont.TextStyle(rawValue: "UICTFontTextStyleEmphasizedCaption2")
    }
}
