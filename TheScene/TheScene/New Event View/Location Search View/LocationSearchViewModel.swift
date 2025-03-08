//
//  LocationSearchViewModel.swift
//  TheScene
//
//  Created by Ryder Klein on 10/25/23.
//

import Foundation
import MapKit

class LocationSearchViewModel: ObservableObject {
    @Published var searchTerm = ""
    @Published var locSetHack = false
    @Published var state: LocationSearchLoadingState = .idle
    public var searchDebounce: Timer?

    @MainActor func findLocations() async {
        guard !searchTerm.isEmpty else {
            return
        }
        state = .loading
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        let search = MKLocalSearch(request: request)
        do {
            let results = try await search.start()
            state = .success(results: results.mapItems)
        } catch {
            state = .error(error: error)
        }
    }

    func handleSearchInput() {
        searchDebounce?.invalidate()
        searchDebounce = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            Task {
                await self.findLocations()
            }
        }
    }
}

enum LocationSearchLoadingState {
    case idle
    case loading
    case error(error: Error)
    case success(results: [MKMapItem])
}
