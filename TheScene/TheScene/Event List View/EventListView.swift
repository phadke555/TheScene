//
//  EventListView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/21/23.
//

import SwiftUI

struct EventListView: View {
    @ObservedObject var vm: EventListViewModel
    var body: some View {
        NavigationStack {
            if vm.canMakeEvents {
                HStack {
                    Spacer()
                    Button(action: {
                        vm.isShowingCreationSheet = true
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title)
                    })
                }
                .padding()
            }
            switch vm.eventListStatus {
            case .success(let events):
                if !events.isEmpty {
                    List {
                        let ownedEvents = events.filter { $0.owned == true }
                        let rsvpEvents = events.filter { $0.rsvp == true }
                        let otherEvents = events.filter { ($0.owned != true) && $0.rsvp != true }
                        if !ownedEvents.isEmpty {
                            Section(header: Text("Organizer")) {
                                ForEach(ownedEvents, id: \.id) { event in
                                    eventRow(event: event)
                                        .deleteDisabled(false)
                                }
                                .onDelete { index in
                                    guard let index = index.first else {
                                        return
                                    }
                                    guard let deleteEventId = ownedEvents[index].id else {
                                        return
                                    }
                                    Task {
                                        try await ServerService.deleteEvent(eventId: deleteEventId)
                                        await vm.loadEvents()
                                    }
                                }
                            }
                        }
                        if !rsvpEvents.isEmpty {
                            Section(header: Text("Attendee")) {
                                ForEach(rsvpEvents, id: \.id) { event in
                                    eventRow(event: event)
                                }
                            }
                        }
                        if !otherEvents.isEmpty {
                            Section(header: Text("Available")) {
                                ForEach(otherEvents, id: \.id) { event in
                                    eventRow(event: event)
                                }
                            }
                        }
                    }
                    .refreshable {
                        await vm.loadEvents()
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("No events yet.")
                        if vm.canMakeEvents {
                            Text("Create one now?")
                                .font(.caption)
                            Button(action: {
                                vm.isShowingCreationSheet = true
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .padding(1)
                        }
                        Spacer()
                    }
                }
            case .error(let error):
                Spacer()
                Text(error.localizedDescription)
                Button(action: {
                    Task {
                        await vm.loadEvents()
                    }
                }) {
                    Text("Retry")
                }
                Spacer()
            case .loading:
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            Spacer()
        }
        .sheet(isPresented: $vm.isShowingCreationSheet) {
            NewEventView(loadData: vm.loadEventsWrapper)
        }
    }

    @ViewBuilder
    func eventRow(event: EventData) -> some View {
        NavigationLink(destination: EventView(event: event, loadData: vm.loadEventsWrapper)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(event.title)
                    Spacer()
                    Text("$\(event.cover, specifier: "%.2f")")
                        .font(.subheadline)
                }
                HStack {
                    Text("\(event.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                    Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    EventListView(vm: EventListViewModel())
}
