//
//  EventView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/21/23.
//

import CoreLocation
import MapKit
import SwiftUI

struct EventView: View {
    @StateObject var vm: EventViewModel
    init(event: EventData, loadData: @escaping () -> Void) {
        // ???
        self._vm = StateObject(wrappedValue: EventViewModel(event: event, loadData: loadData))
    }

    var body: some View {
        VStack(alignment: .center) {
            // +0.004 hack for SwiftUI Map weirdness
            Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: vm.event.latitude + 0.004, longitude: vm.event.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))), interactionModes: MapInteractionModes()) {
                Annotation(vm.event.title, coordinate: CLLocationCoordinate2D(latitude: vm.event.latitude, longitude: vm.event.longitude)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue)
                        Image(systemName: "music.mic")
                            .foregroundStyle(Color.white)
                            .padding(5)
                    }
                }
            }
            .frame(height: 275)
            .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomLeading: 15, bottomTrailing: 15)))
            HStack(alignment: .center, spacing: .zero) {
                Image(systemName: "location.circle")
                    .padding(.trailing, 3)
                Text("\(vm.event.address)")
                switch LocationManager.shared.userLocation {
                case .hasLocation(let location):
                    Text("\(location.distance(from: CLLocation(latitude: vm.event.latitude, longitude: vm.event.longitude)) * 0.000621371, specifier: "%.2f") mi")
                        .foregroundStyle(.gray)
                        .bold()
                        .padding(.leading, 6)
                default:
                    EmptyView()
                }
            }.padding(.bottom)
            Text("\(vm.event.startDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.title)
                .fontWeight(.bold)
            Text("\(vm.event.startDate.formatted(date: .omitted, time: .shortened)) - \(vm.event.endDate.formatted(date: .omitted, time: .shortened))")
                .font(.title2)
            if vm.event.cover > 0 {
                Text("$\(vm.event.cover, specifier: "%.2f")")
            }
            if let description = vm.event.description {
                Spacer()
                Text(description)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
            }
            Spacer()
            if !(vm.event.owned == true) {
                Button(role: (vm.buttonState != .RSVP) ? .none : .destructive, action: {
                    vm.updateRSVPWrapper()
                }) {
                    Group {
                        switch vm.buttonState {
                        case .RSVP:
                            Text("Cancel RSVP")
                        case .loading:
                            ProgressView()
                        default:
                            Text("RSVP")
                        }
                    }
                    .font(.title)
                    .padding([.leading, .trailing], 60)
                    .padding([.top, .bottom], 5)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle(vm.event.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        EventView(event: EventData(title: "Sam and the Shis", latitude: 35.9049, longitude: -79.0469, description: "Come see Sam and the magnificent Shis for less than one minute! It will be so awesome!", address: "123 Sesame Street", cover: 4, startDate: Date(), endDate: Date()), loadData: {})
    }
}
