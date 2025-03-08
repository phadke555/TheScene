//
//  ServerService.swift
//  TheScene
//
//  Created by Ryder Klein on 11/27/23.
//

import Foundation
import MapKit
import UIKit

enum ServerService {
    private static let serverURL = "https://thescene-819d8a8ab00c.herokuapp.com"
    public static func canMakeEvent() async throws -> Bool {
        let deviceId = try await getDeviceId()
        var components = URLComponents(string: "\(serverURL)/user")!
        components.queryItems = [URLQueryItem(name: "userId", value: deviceId)]
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(UserResponse.self, from: data)
        return response.canMakeEvents
    }

    public static func createNewEvent(eventTitle: String, coverAmount: Double, startDate: Date, endDate: Date, location: MKMapItem, description: String?) async throws {
        let deviceId = try await getDeviceId()
        let eventData = EventData(title: eventTitle, latitude: location.placemark.coordinate.latitude, longitude: location.placemark.coordinate.longitude, description: description, address: location.placemark.name ?? "nil", cover: coverAmount, startDate: startDate, endDate: endDate)
        var components = URLComponents(string: "\(serverURL)/createEvent")!
        components.queryItems = [URLQueryItem(name: "userId", value: deviceId)]
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(eventData)
        _ = try await URLSession.shared.data(for: request)
    }

    public static func deleteEvent(eventId: UUID) async throws {
        let deviceId = try await getDeviceId()
        let data = DeleteEventData(id: eventId)
        var components = URLComponents(string: "\(serverURL)/deleteEvent")!
        components.queryItems = [URLQueryItem(name: "userId", value: deviceId)]
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(data)
        _ = try await URLSession.shared.data(for: request)
    }

    public static func fetchEvents() async throws -> [EventData] {
        let deviceId = try await getDeviceId()
        var components = URLComponents(string: "\(serverURL)/eventList")!
        components.queryItems = [URLQueryItem(name: "userId", value: deviceId)]
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode([EventData].self, from: data)
        return decoded
    }

    public static func setRSVPStatus(id: UUID, status: Bool) async throws {
        let rsvpData = RSVPData(id: id, newStatus: status)
        guard let deviceId = await UIDevice.current.identifierForVendor?.uuidString else {
            throw ServerError.noDeviceId
        }
        var components = URLComponents(string: "\(serverURL)/rsvp")!
        components.queryItems = [URLQueryItem(name: "userId", value: deviceId)]
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(rsvpData)
        _ = try await URLSession.shared.data(for: request)
    }

    public static func getDeviceId() async throws -> String {
        guard let deviceId = await UIDevice.current.identifierForVendor?.uuidString else {
            throw ServerError.noDeviceId
        }
        return deviceId
    }
}

struct DeleteEventData: Codable {
    var id: UUID
}

struct EventData: Codable {
    var title: String
    var latitude: Double
    var longitude: Double
    var description: String?
    var address: String
    var cover: Double
    var startDate: Date
    var endDate: Date
    var id: UUID?
    var rsvp: Bool?
    var owned: Bool?
}

struct RSVPData: Codable {
    var id: UUID
    var newStatus: Bool
}

enum ServerError: Error {
    case noDeviceId
}

struct UserResponse: Codable {
    let canMakeEvents: Bool
}
