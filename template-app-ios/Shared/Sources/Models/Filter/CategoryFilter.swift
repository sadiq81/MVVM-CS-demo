import MustacheFoundation

// TODO: Localize from backend
enum CategoryFilter: String, Codable, ProductFilter {

    case smartphones
    case laptops
    case fragrances
    case skincare
    case groceries
    case homeDecoration = "home-decoration"
    case furniture
    case tops
    case womensDresses = "womens-dresses"
    case womensShoes = "womens-shoes"
    case mensShirts = "mens-shirts"
    case mensShoes = "mens-shoes"
    case mensWatches = "mens-watches"
    case womensWatches = "womens-watches"
    case womensBags = "womens-bags"
    case womensJewellery = "womens-jewellery"
    case sunglasses
    case automotive
    case motorcycle
    case lighting

    var localization: String {
        switch self {
            case .smartphones: return Strings.Category.smartphones
            case .laptops: return Strings.Category.laptops
            case .fragrances: return Strings.Category.fragrances
            case .skincare: return Strings.Category.skincare
            case .groceries: return Strings.Category.groceries
            case .homeDecoration: return Strings.Category.homeDecoration
            case .furniture: return Strings.Category.furniture
            case .tops: return Strings.Category.tops
            case .womensDresses: return Strings.Category.womensDresses
            case .womensShoes: return Strings.Category.womensShoes
            case .mensShirts: return Strings.Category.mensShirts
            case .mensShoes: return Strings.Category.mensShoes
            case .mensWatches: return Strings.Category.mensWatches
            case .womensWatches: return Strings.Category.womensWatches
            case .womensBags: return Strings.Category.womensBags
            case .womensJewellery: return Strings.Category.womensJewellery
            case .sunglasses: return Strings.Category.sunglasses
            case .automotive: return Strings.Category.automotive
            case .motorcycle: return Strings.Category.motorcycle
            case .lighting: return Strings.Category.lighting
        }
    }
}

extension CategoryFilter: Comparable {

    static func < (lhs: CategoryFilter, rhs: CategoryFilter) -> Bool {
        return lhs.localization < rhs.localization
    }

}
