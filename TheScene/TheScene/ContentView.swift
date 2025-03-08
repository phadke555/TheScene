//
//  ContentView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/14/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = EventListViewModel()
    var body: some View {
        TabView {
            MapView(vm: vm)
                .tabItem {
                    Label("Map", systemImage: "mappin.and.ellipse.circle")
                }
            EventListView(vm: vm)
                .tabItem {
                    Label("My Events", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
