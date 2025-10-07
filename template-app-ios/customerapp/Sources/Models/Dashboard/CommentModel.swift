import Foundation

class CommentModel: Codable {

    var id: Int
    var name: String
    var email: String
    var body: String

    init(id: Int, name: String, email: String, body: String) {
        self.id = id
        self.name =  name
        self.email = email
        self.body = body
    }
}

extension CommentModel: Hashable {

    static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        guard lhs.email == rhs.email else { return false }
        guard lhs.body == rhs.body else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension CommentModel: Comparable {

    static func < (lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.id < rhs.id
    }

}

extension CommentModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "CommentModel(id: \(self.id), name: \(self.name))"
    }

}
