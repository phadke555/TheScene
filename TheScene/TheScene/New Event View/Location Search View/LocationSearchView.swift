//
//  SearchLocationView.swift
//  TheScene
//
//  Created by Ryder Klein on 10/25/23.
//

import MapKit
import SwiftUI

struct LocationSearchView: View {
    @FocusState private var focused: Bool
    @StateObject private var vm = LocationSearchViewModel()

    @Binding var searchLocation: MKMapItem?

    var body: some View {
        TextField("Enter a location", text: $vm.searchTerm)
            .onChange(of: vm.searchTerm) {
                if (vm.locSetHack) {
                    vm.locSetHack = false
                } else {
                    searchLocation = nil
                    vm.handleSearchInput()
                }
            }
            .focused($focused, equals: true)
        switch vm.state {
        case .idle:
            idleView
        case .loading:
            loadingView
        case .success(let results):
            locationsList(results)
        case .error(let error):
            errorView(error)
        }
    }

    @ViewBuilder
    private var idleView: some View {
        EmptyView()
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView()
    }

    @ViewBuilder
    private func locationsList(_ locations: [MKMapItem]) -> some View {
        ForEach(locations, id: \.hash) { location in
            Button(action: {
                vm.locSetHack = true
                focused = false
                vm.searchTerm = location.placemark.title ?? location.name ?? "nil"
                searchLocation = location
                vm.state = .idle
            }) {
                VStack(alignment: .leading) {
                    if let locationName = location.name {
                        Text(locationName)
                    }
                    if let address = location.placemark.title {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        Text(error.localizedDescription)
    }
}

#Preview {
    NavigationStack {
        LocationSearchView(searchLocation: .constant(MKMapItem()))
    }
}
