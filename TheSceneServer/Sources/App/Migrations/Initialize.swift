import Fluent

struct Initialize: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("uuid", .string, .required)
            .field("canMakeEvents", .bool, .required)
            .create()
        try await database.schema("events")
            .id()
            .field("name", .string, .required)
            .field("user_id", .uuid, .required)
            .field("description", .string)
            .field("address", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("cover", .double, .required)
            .field("start_date", .datetime, .required)
            .field("end_date", .datetime, .required)
            .foreignKey("user_id", references: "users", "id")
            .create()
        try await database.schema("event_user")
            .id()
            .field("user_id", .uuid, .required)
            .field("event_id", .uuid, .required)
            .foreignKey("user_id", references: "users", "id")
            .foreignKey("event_id", references: "events", "id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("events").delete()
        try await database.schema("users").delete()
        try await database.schema("eventUser").delete()
    }
}
