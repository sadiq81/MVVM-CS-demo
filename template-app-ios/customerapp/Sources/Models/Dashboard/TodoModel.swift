import Foundation

class TodoModel: Codable {

    var id: Int
    var title: String
    var completed: Bool

    init(id: Int, title: String, completed: Bool) {
        self.id = id
        self.title = title
        self.completed = completed
    }
}

extension TodoModel: Hashable {

    static func == (lhs: TodoModel, rhs: TodoModel) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.completed == rhs.completed else { return false }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

}

extension TodoModel: Comparable {

    static func < (lhs: TodoModel, rhs: TodoModel) -> Bool {
        return lhs.id < rhs.id
    }

}

extension TodoModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "TodoModel(id: \(self.id), title: \(self.title))"
    }

}
