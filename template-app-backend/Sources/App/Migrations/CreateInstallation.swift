import Fluent

struct CreateInstallation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_installation")
            .id()
            .field("user_id", .uuid, .references("users", "id", onDelete: .setNull))
            .field("device_model", .string, .required)
            .field("identifier_for_vendor", .string)
            .field("fcm_token", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_installation").delete()
    }
}
