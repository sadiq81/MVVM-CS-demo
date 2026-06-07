import MustacheFoundation

enum ProductFilterType: Int, CaseIterable {

    case category
    case brand

    var localization: String {
        switch self {
            case .category: return Strings.Product.Filter.category
            case .brand: return Strings.Product.Filter.brand
        }        
    }
}
