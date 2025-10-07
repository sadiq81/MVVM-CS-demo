import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string)
            .field("birth_date", .date)
            .field("birth_date_verified", .bool, .required, .custom("DEFAULT FALSE"))
            .field("phone_country", .string)
            .field("phone_number", .string)
            .field("email", .string, .required)
            .field("street", .string)
            .field("zip_code", .string)
            .field("city", .string)
            .field("country", .string)
            .field("image_url", .string)
            .field("password_hash", .string, .required)
            .field("is_admin", .bool, .required, .custom("DEFAULT FALSE"))
            .field("is_email_verified", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
