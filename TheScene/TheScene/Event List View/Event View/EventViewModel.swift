//
//  EventViewModel.swift
//  TheScene
//
//  Created by Rohan Phadke on 12/2/23.
//

import Foundation

@MainActor
class EventViewModel: ObservableObject {
    @Published var event: EventData
    @Published var buttonState: ButtonStatus
    var loadData: () -> Void

    init(event: EventData, loadData: @escaping () -> Void) {
        self.event = event
        self.loadData = loadData
        self.buttonState = event.rsvp == true ? .RSVP : .NotRSVP
    }

    func updateRSVP(
        id: UUID,
        status: Bool
    ) async {
        let oldButtonState = self.buttonState
        do {
            self.buttonState = .loading
            try await ServerService.setRSVPStatus(id: id, status: status)
            self.event.rsvp = status
            self.buttonState = status == true ? .RSVP : .NotRSVP
        } catch {
            self.buttonState = oldButtonState
            print("Error: \(error)")
        }
    }

    func updateRSVPWrapper() {
        if !(event.owned == true) {
            guard let id = event.id else { return }
            Task {
                await self.updateRSVP(id: id, status: !(self.event.rsvp == true))
                loadData()
            }
        }
    }
}

enum ButtonStatus: Equatable {
    case NotRSVP
    case RSVP
    case loading
}
