import Foundation

class DashboardModel: Codable {

    let comments: [CommentModel]
    let posts: [PostModel]
    let albums: [AlbumModel]
    let todos: [TodoModel]

    init(comments: [CommentModel], posts: [PostModel], albums: [AlbumModel], todos: [TodoModel]) {
        self.comments = comments
        self.posts = posts
        self.albums = albums
        self.todos = todos
    }

}

extension DashboardModel: Hashable {

    static func == (lhs: DashboardModel, rhs: DashboardModel) -> Bool {

        guard Set(lhs.comments) == Set(rhs.comments) else { return false }
        guard Set(lhs.posts) == Set(rhs.posts) else { return false }
        guard Set(lhs.albums) == Set(rhs.albums) else { return false }
        guard Set(lhs.todos) == Set(rhs.todos) else { return false }

        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.comments)
        hasher.combine(self.posts)
        hasher.combine(self.albums)
        hasher.combine(self.todos)
    }

}

extension DashboardModel: CustomDebugStringConvertible {

    var debugDescription: String {
        return "DashboardModel(comments: \(self.comments), posts: \(self.posts)), albums: \(self.albums)), todos: \(self.todos))"
    }

}
