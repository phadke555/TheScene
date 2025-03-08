import Fluent
import Vapor

final class EventUser: Model, Content {
    static let schema = "event_user"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "event_id")
    var event: EventModel

    init() {}

    init(user: User, event: EventModel) throws {
        self.$user.id = try user.requireID()
        self.$event.id = try event.requireID()
    }
}
