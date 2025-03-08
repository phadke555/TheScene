//
//  NewEventViewModel.swift
//  TheScene
//
//  Created by Ryder Klein on 11/27/23.
//

import Foundation
import MapKit

@MainActor
class NewEventViewModel: ObservableObject {
    @Published var eventTitle = ""
    @Published var coverAmount = 0
    @Published var startDate: Date = Calendar.current.date(bySettingHour: 20, minute: 30, second: 0, of: Date())!
    @Published var endDate: Date = Calendar.current.date(bySettingHour: 23, minute: 30, second: 0, of: Date())!
    @Published var location: MKMapItem?
    @Published var description = ""
    @Published var midSubmit = false
    public func createNewEvent() async -> Bool {
        guard let location = location else {
            return false
        }
        midSubmit = true
        do {
            try await ServerService.createNewEvent(eventTitle: eventTitle, coverAmount: Double(coverAmount), startDate: startDate, endDate: endDate, location: location, description: description)
        } catch {
            print(error.localizedDescription)
        }
        return true
    }
}
