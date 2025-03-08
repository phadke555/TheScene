//
//  EventListViewModel.swift
//  TheScene
//
//  Created by Ryder Klein on 11/27/23.
//

import Foundation

class EventListViewModel: ObservableObject {
    @Published var canMakeEvents = false
    @Published var isShowingCreationSheet = false
    @Published var eventListStatus: EventListStatus = .loading
    @MainActor
    init() {
        Task {
            let eventResponse = try? await ServerService.canMakeEvent()
            await MainActor.run {
                if let eventResponse = eventResponse {
                    self.canMakeEvents = eventResponse
                }
            }
        }
        Task {
            await loadEvents()
        }
    }

    @MainActor
    func loadEvents() async {
        do {
            eventListStatus = try .success(events: await ServerService.fetchEvents())
        } catch {
            eventListStatus = .error(error: error)
        }
    }

    func loadEventsWrapper() {
        Task {
            await loadEvents()
        }
    }
}

enum EventListStatus {
    case success(events: [EventData])
    case error(error: Error)
    case loading
}
