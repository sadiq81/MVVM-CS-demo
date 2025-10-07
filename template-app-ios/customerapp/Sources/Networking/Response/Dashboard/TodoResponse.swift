import Foundation

struct TodoResponse: Decodable {
    var id: Int
    var title: String
    var completed: Bool
}
