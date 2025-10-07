import Foundation

class FilterModel: Codable {

    let categories: [CategoryFilter]
    let brands: [BrandFilter]

    init(categories: [CategoryFilter], brands: [BrandFilter]) {
        self.categories = categories.sorted()
        self.brands = brands.sorted()
    }

}

extension FilterModel: Hashable {

    static func == (lhs: FilterModel, rhs: FilterModel) -> Bool {

        guard Set(lhs.categories) == Set(rhs.categories) else { return false }
        guard Set(lhs.brands) == Set(rhs.brands) else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.categories)
        hasher.combine(self.brands)
    }

}
extension FilterModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "FilterModel(categories: \(self.categories), brands: \(self.brands))"
    }

}
