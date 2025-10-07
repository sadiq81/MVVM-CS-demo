import Foundation

protocol ProductFilter: Hashable {
    var localization: String { get }
}

extension String: ProductFilter {

    var localization: String {
        return self.localized
    }

}
