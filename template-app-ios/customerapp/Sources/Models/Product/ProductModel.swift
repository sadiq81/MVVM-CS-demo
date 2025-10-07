import Foundation

class ProductModel: Codable {

    var id: Int
    var title: String
    var description: String
    var price: Double
    var discountPercentage: Double
    var rating: Double
    var stock: Int
    var brand: String
    var category: String
    var thumbnail: URL?
    var images: [URL]
    var isPlaceholder: Bool

    init(id: Int, title: String, description: String, price: Double, discountPercentage: Double, rating: Double, stock: Int, brand: String?, category: String, thumbnail: URL?, images: [URL], isPlaceholder: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.stock = stock
        self.brand = brand ?? ""
        self.category = category
        self.thumbnail = thumbnail
        self.images = images
        self.isPlaceholder = isPlaceholder
    }
}

extension ProductModel {

    static let empty = ProductModel(id: 0,
                                    title: "",
                                    description: "",
                                    price: 0,
                                    discountPercentage: 0,
                                    rating: 0,
                                    stock: 0,
                                    brand: "",
                                    category: "",
                                    thumbnail: nil,
                                    images: [],
                                    isPlaceholder: true)

}

extension ProductModel: Hashable {

    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.description == rhs.description else { return false }
        guard lhs.price == rhs.price else { return false }
        guard lhs.discountPercentage == rhs.discountPercentage else { return false }
        guard lhs.rating == rhs.rating else { return false }
        guard lhs.stock == rhs.stock else { return false }
        guard lhs.brand == rhs.brand else { return false }
        guard lhs.category == rhs.category else { return false }
        guard lhs.thumbnail == rhs.thumbnail else { return false }
        guard lhs.images == rhs.images else { return false }
        guard !(lhs.isPlaceholder || lhs.isPlaceholder) else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension ProductModel: Comparable {

    static func < (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id < rhs.id
    }

}

extension ProductModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "ProductModel(id: \(self.id), title: \(self.title))"
    }

}
