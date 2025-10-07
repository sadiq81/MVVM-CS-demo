import Fluent

struct CreateFeatureFlag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_feature_flags")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .unique(on: "user_id", "name")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_feature_flags").delete()
    }
}
