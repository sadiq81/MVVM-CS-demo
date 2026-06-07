import Foundation

struct CommentModel: Codable {

    let id: Int
    let name: String
    let email: String
    let body: String

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
