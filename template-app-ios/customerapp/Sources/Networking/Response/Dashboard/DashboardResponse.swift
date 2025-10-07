import Foundation

struct DashboardResponse: Decodable {

    let comments: [CommentResponse]
    let posts: [PostResponse]
    let albums: [AlbumResponse]
    let todos: [TodoResponse]

}


