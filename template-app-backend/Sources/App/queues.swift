import Vapor
import Queues

func queues(_ app: Application) throws {
    // MARK: Queues Configuration
//    if app.environment != .testing {
//        let url = Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"
//        try app.queues.use(.redis(url: url))
//        app.queues.add(EmailJob())
//    }
    
    
}
