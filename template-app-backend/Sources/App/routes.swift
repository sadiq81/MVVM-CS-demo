import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.group("api") { api in
        try! api.register(collection: AuthenticationController())
        try! api.register(collection: OnboardingStateController())
        try! api.register(collection: InstallationController())
        try! api.register(collection: UserController())
        try! api.register(collection: DashboardController())
        try! api.register(collection: ProductController())
    }
    
    print(app.routes.all)
}
