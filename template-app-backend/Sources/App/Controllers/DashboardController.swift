import Vapor
import Fluent

struct DashboardController: RouteCollection {
    
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.group("dashboard") { dashboard in
            
            dashboard.group(UserAuthenticator()) { authenticated in
                dashboard.get("", use: self.dashboard)
            }
        }
    }
    
    @Sendable
    private func dashboard(_ req: Request) async throws -> DashboardResponse {
        
        let commentResponse = try await req.client.get("https://jsonplaceholder.typicode.com/comments/")
        let postResponse = try await req.client.get("https://jsonplaceholder.typicode.com/posts/")
        let albumResponse = try await req.client.get("https://jsonplaceholder.typicode.com/albums/")
        let todoResponse = try await req.client.get("https://jsonplaceholder.typicode.com/todos/")
        
        // TODO: How to do this in parallel?
        
        let comments = try commentResponse.content.decode([CommentResponse].self)
        let posts = try postResponse.content.decode([PostResponse].self)
        let albums = try albumResponse.content.decode([AlbumResponse].self)
        let todos = try todoResponse.content.decode([TodoResponse].self)
        
        let dashboardResponse: DashboardResponse = DashboardResponse(comments: comments,
                                                  posts: posts,
                                                  albums: albums,
                                                  todos: todos)
        
        return dashboardResponse
    }
    
}
