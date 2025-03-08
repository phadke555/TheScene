import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "uuid")
    var uuid: String
    
    @Field(key: "canMakeEvents")
    var canMakeEvents: Bool
    
    @Siblings(through: EventUser.self, from: \.$user, to: \.$event)
    var events: [EventModel]
    
    init() { }

    init(uuid: String) {
        self.uuid = uuid
        self.canMakeEvents = false
    }
}
