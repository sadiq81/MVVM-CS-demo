import Foundation

extension DashboardResponse {

    static let mockData = DashboardResponse(
        comments: CommentResponse.mockData,
        posts: PostResponse.mockData,
        albums: AlbumResponse.mockData,
        todos: TodoResponse.mockData
    )

}


