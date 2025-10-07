import Foundation
import MustacheServices

import Combine
import MustacheCombine

protocol DashboardServiceType {

    var dashboard: DashboardModel? { get }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }

    func refresh() async throws

    func clearState()

}

class DashboardService: DashboardServiceType {

    @StorageCombine("DashboardService.dashboard", mode: .userDefaults())
    var dashboard: DashboardModel?

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.$dashboard
    }

    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    func refresh() async throws {

        let response = try await self.networkService.dashboard()
        let model = DashboardModel(response: response)
        self.dashboard = model

    }

    func clearState() {
        self.dashboard = nil
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

extension DashboardModel {    
    convenience init(response: DashboardResponse) {
        let comments = response.comments.map { CommentModel(response: $0) }
        let posts = response.posts.map { PostModel(response: $0) }
        let albums = response.albums.map { AlbumModel(response: $0) }
        let todos = response.todos.map { TodoModel(response: $0) }
        self.init(comments: comments,
                  posts: posts,
                  albums: albums,
                  todos: todos)
    }
}

extension AlbumModel {
    convenience init(response: AlbumResponse) {
        self.init(id: response.id,
                  title: response.title)
    }
}

extension PostModel {
    convenience init(response: PostResponse) {
        self.init(id: response.id,
                  title: response.title,
                  body: response.body)
    }
}

extension TodoModel {
    convenience init(response: TodoResponse) {
        self.init(id: response.id,
                  title: response.title,
                  completed: response.completed)
    }
}

extension CommentModel {
    convenience init(response: CommentResponse) {
        self.init(id: response.id,
                  name: response.name,
                  email: response.email,
                  body: response.body)
    }    
}
