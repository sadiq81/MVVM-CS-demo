import Foundation

struct CommentResponse: Decodable {
    var id: Int
    var name: String
    var email: String
    var body: String
}
