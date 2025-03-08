//
//  MapView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/21/23.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Namespace var mapScope
    @StateObject var lm = LocationManager.shared
    @ObservedObject var vm: EventListViewModel
    var body: some View {
        switch lm.userLocation {
        case .denied:
            locationsMap(nil)
        case .hasLocation(let location):
            locationsMap(location)
        case .loading:
            ProgressView()
        case .unprompted:
            LocationRequestView(lm: lm)
        }
    }

    func locationsMap(_ currentLocation: CLLocation?) -> some View {
        NavigationStack {
            // Default to Chapel Hill
            Map(initialPosition: .userLocation(fallback: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.9049, longitude: -79.0469), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))), scope: mapScope) {
                UserAnnotation()
                switch vm.eventListStatus {
                case .success(let events):
                    ForEach(events, id: \.id) { event in
                        Annotation(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), content: {
                            NavigationLink(destination: {
                                EventView(event: event, loadData: vm.loadEventsWrapper)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.blue)
                                    Image(systemName: "music.mic")
                                        .foregroundStyle(Color.white)
                                        .padding(5)
                                }
                            }
                        }, label: {
                            VStack {
                                Text(event.title)
                                Text("\(event.startDate.formatted(date: .abbreviated, time: .omitted)) \(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                                    .fontWeight(.bold)
                            }
                        }).annotationSubtitles(.visible)
                    }
                default:
                    EmptyMapContent()
                }
            }
            .mapControls {
                MapUserLocationButton(scope: mapScope)
            }
        }
    }
}

#Preview {
    MapView(vm: EventListViewModel()).locationsMap(nil)
}

#Preview {
    LocationRequestView(lm: LocationManager())
}
