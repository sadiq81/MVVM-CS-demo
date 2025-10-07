import UIKit

// https://medium.com/@khushabu29/theme-management-in-ios-apps-chapter-i-font-manager-f8cfb42981a6
extension UIFont {
    
    @objc class func swizzledPreferredFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        
        if #available(iOS 17.0, *) {
            switch style {
                case .extraLargeTitle:
                    return FontFamily.Montserrat.bold.font(size: 36)
                case .extraLargeTitle2:
                    return FontFamily.Montserrat.bold.font(size: 28)
                default:
                    break
            }
        }
        
        switch style {
            case .largeTitle:
                return FontFamily.Montserrat.bold.font(size: 35)
                
            case .emphasizedLargeTitle:
                return FontFamily.Montserrat.black.font(size: 35)
                
            case .title1:
                return FontFamily.Montserrat.bold.font(size: 28)
                
            case .emphasizedTitle1:
                return FontFamily.Montserrat.black.font(size: 28)
                
            case .title2:
                return FontFamily.Montserrat.bold.font(size: 22)
                
            case .emphasizedTitle2:
                return FontFamily.Montserrat.black.font(size: 22)
                
            case .title3:
                return FontFamily.Montserrat.regular.font(size: 20)
                
            case .emphasizedTitle3:
                return FontFamily.Montserrat.semiBold.font(size: 20)
                
            case .headline:
                return FontFamily.Montserrat.semiBold.font(size: 17)
                
            case .emphasizedHeadline:
                return FontFamily.Montserrat.bold.font(size: 17)
                
            case .subheadline:
                return FontFamily.Montserrat.regular.font(size: 15)
                
            case .emphasizedSubheadline:
                return FontFamily.Montserrat.semiBold.font(size: 15)
                
            case .body, .shortBody:
                return FontFamily.Montserrat.regular.font(size: 17)
                
            case .emphasizedBody, .shortEmphasizedBody:
                return FontFamily.Montserrat.semiBold.font(size: 17)
                
            case .callout:
                return FontFamily.Montserrat.regular.font(size: 16)
                
            case .emphasizedCallout:
                return FontFamily.Montserrat.semiBold.font(size: 16)
                
            case .footnote:
                return FontFamily.Montserrat.regular.font(size: 13)
                
            case .emphasizedFootnote:
                return FontFamily.Montserrat.semiBold.font(size: 13)
                
            case .caption1:
                return FontFamily.Montserrat.regular.font(size: 12)
                
            case .emphasizedCaption1:
                return FontFamily.Montserrat.semiBold.font(size: 12)
                
            case .caption2:
                return FontFamily.Montserrat.regular.font(size: 11)
                
            case .emphasizedCaption2:
                return FontFamily.Montserrat.semiBold.font(size: 11)
                
            default:
                return FontFamily.Montserrat.regular.font(size: 17)
        }
    }
    
    @objc class func swizzledPreferredFont(forTextStyle style: UIFont.TextStyle, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        self.swizzledPreferredFont(forTextStyle: style)
    }
    
    @objc class func swizzledSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontFamily.Montserrat.regular.name, size: size)!
    }
    
    @objc class func swizzledBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontFamily.Montserrat.bold.name, size: size)!
    }
    
    @objc class func swizzledItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontFamily.Montserrat.italic.name, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
            self.init(myCoder: aDecoder)
            return
        }
        var fontName = ""
        switch fontAttribute {
            case "CTFontRegularUsage":
                fontName = FontFamily.Montserrat.regular.name
            case "CTFontEmphasizedUsage", "CTFontBoldUsage":
                fontName = FontFamily.Montserrat.bold.name
            case "CTFontObliqueUsage":
                fontName = UIFont.italicSystemFont(ofSize: 12).fontName
            default:
                fontName = UIFont.systemFont(ofSize: 12).fontName
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemMethod = class_getClassMethod(self, #selector(preferredFont(forTextStyle:))),
           let swizzledMethod = class_getClassMethod(self, #selector(swizzledPreferredFont(forTextStyle:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
        
        if let systemMethod = class_getClassMethod(self, #selector(preferredFont(forTextStyle: compatibleWith:))),
           let swizzledMethod = class_getClassMethod(self, #selector(swizzledPreferredFont(forTextStyle: compatibleWith:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
        
        if let systemMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
           let swizzledMethod = class_getClassMethod(self, #selector(swizzledSystemFont(ofSize:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
        
        if let systemMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
           let swizzledMethod = class_getClassMethod(self, #selector(swizzledBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
        
        if let systemMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
           let swizzledMethod = class_getClassMethod(self, #selector(swizzledItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
        
        if let systemMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
           let swizzledMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(systemMethod, swizzledMethod)
        }
    }
    
    //    class func overrideInitialize() {}
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}
