import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("user") { req async throws -> User in
        try await req.getUser()
    }

    app.get("eventList") { req async throws -> [EventModelDTO] in
        let user = try await req.getUser()
        let data = try await EventModel.query(on: req.db).with(\.$users).with(\.$author).all()
        let dataMapped = try data.map { eventModel in
            try EventModelDTO(from: eventModel, user: user)
        }
        return dataMapped
    }

    // Also used to modify the event
    app.post("createEvent") { req async throws -> Response in
        let user = try await req.getUser()
        if !user.canMakeEvents {
            throw Abort(.forbidden)
        }
        let data = try req.content.decode(CreateEventData.self)
        // Is this the best way to do this?
        let event: EventModel = try await {
            if let eventId = data.id {
                let event = try await EventModel.query(on: req.db).filter(\.$id == eventId).with(\.$author).first()
                guard let event = event else {
                    throw Abort(.notFound)
                }
                if try event.author.id != (user.requireID()) {
                    throw Abort(.forbidden)
                }
                return event
            }
            return EventModel()
        }()
        event.title = data.title
        event.$author.id = try user.requireID()
        event.latitude = data.latitude
        event.longitude = data.longitude
        event.description = data.description
        event.address = data.address
        event.cover = data.cover
        event.startDate = data.startDate
        event.endDate = data.endDate
        try await event.save(on: req.db)
        return Response(status: .created)
    }
    app.post("deleteEvent") { req async throws -> Response in
        let user = try await req.getUser()
        let data = try req.content.decode(DeleteEventData.self)
        let event = try await EventModel.query(on: req.db).filter(\.$id == data.id).with(\.$author).first()
        guard let event = event else {
            throw Abort(.notFound)
        }
        if try event.author.id != (user.requireID()) {
            throw Abort(.forbidden)
        }
        try await event.delete(on: req.db)
        return Response(status: .ok)
    }
    app.post("rsvp") { req async throws -> Response in
        let user = try await req.getUser()
        let data = try req.content.decode(RSVPData.self)
        if !data.newStatus {
            try await EventUser.query(on: req.db).filter(\.$user.$id == user.requireID()).delete()
            return Response(status: .ok)
        } else {
            if try (await EventUser.query(on: req.db).filter(\.$user.$id == user.requireID()).count()) > 0 {
                throw Abort(.conflict)
            }
            let event = try await EventModel.query(on: req.db).filter(\.$id == data.id).first()
            guard let event = event else {
                throw Abort(.notFound)
            }
            try await EventUser(user: user, event: event).save(on: req.db)
            return Response(status: .created)
        }
    }
//    try app.register(collection: TodoController())
}

struct CreateEventData: Content {
    var id: UUID?
    var title: String
    var latitude: Double
    var longitude: Double
    var description: String?
    var address: String
    var cover: Double
    var startDate: Date
    var endDate: Date
}

struct RSVPData: Content {
    var id: UUID
    var newStatus: Bool
}

struct DeleteEventData: Content {
    var id: UUID
}
