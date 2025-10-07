import Foundation

class PostModel: Codable {

    var id: Int
    var title: String
    var body: String

    init(id: Int, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }
}

extension PostModel: Hashable {

    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.body == rhs.body else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension PostModel: Comparable {

    static func < (lhs: PostModel, rhs: PostModel) -> Bool {
        return lhs.id < rhs.id
    }

}

extension PostModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "PostModel(id: \(self.id), title: \(self.title))"
    }

}
