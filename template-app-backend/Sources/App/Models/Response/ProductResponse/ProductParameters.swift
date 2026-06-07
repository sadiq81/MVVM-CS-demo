
import Vapor

struct ProductParameters: Content {
    
    var search: String?
    var categories: String?
    var brands: String?
    var limit: Int
    var skip: Int
}
