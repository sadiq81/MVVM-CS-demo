import Vapor

struct ProductPaginatedResponse: Content {
    var products: [ProductResponse]
    var total: Int
    var skip: Int
    var limit: Int
}

struct ProductResponse: Content {
    
    var id: Int
    var title: String
    var description: String
    var price: Double
    var discountPercentage: Double
    var rating: Double
    var stock: Int
    var brand: String?
    var category: String
    var thumbnail: URL
    var images: [URL]
    
    var search: String {
        "\(self.id) \(self.title) \(self.description) \(self.brand ?? "") \(self.category)"
    }
    
}
