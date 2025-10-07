import Vapor

struct CategoryResponse: Content {
    
    var slug: String
    var name: String
    var url: URL
    
}
