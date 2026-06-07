import Foundation

#if DEBUG

extension DashboardModel {

    static let mockData = DashboardModel(
        comments: CommentModel.mockDataArray,
        posts: PostModel.mockDataArray,
        albums: AlbumModel.mockDataArray,
        todos: TodoModel.mockDataArray
    )

}

#endif
