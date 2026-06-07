import Combine
import Foundation

import MustacheCombine
import MustacheServices

protocol DashboardServiceType: Sendable {

    var dashboard: DashboardModel? { get }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }

    func refresh() async throws

    @MainActor func clearState()

}

final class DashboardService: DashboardServiceType, @unchecked Sendable {

    @StorageCombine("DashboardService.dashboard", mode: .userDefaults())
    var dashboard: DashboardModel?

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.$dashboard
    }

    @LazyInjected(\.asyncNetworkService)
    private var networkService: any AsyncNetworkServiceType

    func refresh() async throws {

        let response = try await self.networkService.dashboard()
        let model = DashboardModel(response: response)
        await MainActor.run { self.dashboard = model }

    }

    @MainActor
    func clearState() {
        self.dashboard = nil
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

extension DashboardModel {    
    init(response: DashboardResponse) {
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
    init(response: AlbumResponse) {
        self.init(id: response.id,
                  title: response.title)
    }
}

extension PostModel {
    init(response: PostResponse) {
        self.init(id: response.id,
                  title: response.title,
                  body: response.body)
    }
}

extension TodoModel {
    init(response: TodoResponse) {
        self.init(id: response.id,
                  title: response.title,
                  completed: response.completed)
    }
}

extension CommentModel {
    init(response: CommentResponse) {
        self.init(id: response.id,
                  name: response.name,
                  email: response.email,
                  body: response.body)
    }    
}
