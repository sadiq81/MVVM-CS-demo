import Foundation
import Vapor

struct DashboardResponse: Content {
    
    let comments: [CommentResponse]
    let posts: [PostResponse]
    let albums: [AlbumResponse]
    let todos: [TodoResponse]
    
}

struct PostResponse: Content {
    var id: Int
    var title: String
    var body: String
}

struct AlbumResponse: Content {
    var id: Int
    var title: String
}

struct TodoResponse: Content {
    var id: Int
    var title: String
    var completed: Bool
}

struct CommentResponse: Content {
    var id: Int
    var name: String
    var email: String
    var body: String
}

