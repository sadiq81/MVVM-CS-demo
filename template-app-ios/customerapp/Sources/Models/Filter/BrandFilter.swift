import Foundation

class BrandFilter: Codable, ProductFilter {

    var value: String

    var localization: String {
        return self.value
    }

    init(value: String) {
        self.value = value
    }
}

extension BrandFilter {

    static func ==(lhs: BrandFilter, rhs: BrandFilter) -> Bool {
        return lhs.localization == rhs.localization
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }

}

extension BrandFilter: Comparable {

    static func < (lhs: BrandFilter, rhs: BrandFilter) -> Bool {
        return lhs.localization < rhs.localization
    }

}
