import Fluent
import Vapor

final class EventModel: Model, Content {
    static let schema = "events"
        
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var title: String
        
    @Parent(key: "user_id")
    var author: User
        
    @Field(key: "latitude")
    var latitude: Double
        
    @Field(key: "longitude")
    var longitude: Double
        
    @Field(key: "description")
    var description: String?
        
    @Field(key: "address")
    var address: String
        
    @Field(key: "cover")
    var cover: Double
        
    @Field(key: "start_date")
    var startDate: Date
        
    @Field(key: "end_date")
    var endDate: Date
        
    @Siblings(through: EventUser.self, from: \.$event, to: \.$user)
    var users: [User]
        
    var rsvp: Bool?
    var owned: Bool?
        
    init() {}

    init(title: String, authorId: UUID, description: String?, address: String, latitude: Double, longitude: Double, cover: Double, startDate: Date, endDate: Date) {
        self.title = title
        $author.id = authorId
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.cover = cover
        self.startDate = startDate
        self.endDate = endDate
    }
}

struct EventModelDTO: Content {
    var id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var description: String?
    var address: String
    var cover: Double
    var startDate: Date
    var endDate: Date
    var rsvp: Bool?
    var owned: Bool?

    init(from eventModel: EventModel, user: User?) throws {
        self.id = try eventModel.requireID()
        self.title = eventModel.title
        self.latitude = eventModel.latitude
        self.longitude = eventModel.longitude
        if description?.isEmpty == false {
            self.description = eventModel.description
        }
        self.address = eventModel.address
        self.cover = eventModel.cover
        self.startDate = eventModel.startDate
        self.endDate = eventModel.endDate
        if let user = user {
            self.rsvp = (eventModel.users.first(where: { $0.uuid == user.uuid }) != nil)
            self.owned = (eventModel.author.uuid == user.uuid)
        } else {
            self.rsvp = false
            self.owned = false
        }
    }
}
