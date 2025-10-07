import Foundation

struct PostResponse: Decodable {
    var id: Int
    var title: String
    var body: String
}
