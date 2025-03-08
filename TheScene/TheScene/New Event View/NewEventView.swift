//
//  NewEventView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/27/23.
//

import Foundation
import SwiftUI

struct NewEventView: View {
    var loadData: () -> Void
    @StateObject var vm = NewEventViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            List {
                TextField(text: $vm.eventTitle) {
                    Text("Event Title")
                }
                Stepper(value: $vm.coverAmount, in: 0...20) {
                    Text("$\(vm.coverAmount)")
                }
                VStack {
                    DatePicker("Start Date", selection: $vm.startDate, in: Date()...Date(timeIntervalSinceNow: TimeInterval(1209600)))
                    DatePicker("End Date", selection: $vm.endDate, in: Date()...Date(timeIntervalSinceNow: TimeInterval(1209600)))
                }
                LocationSearchView(searchLocation: $vm.location)
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(4...6)
            }
            .scaledToFit()
            Button(action: {
                Task {
                    _ = await vm.createNewEvent()
                    vm.midSubmit = false
                    loadData()
                    dismiss()
                }
            }, label: {
                if !vm.midSubmit {
                    Text("Submit")
                        .font(.system(size: 26))
                        .padding([.leading, .trailing], 12)
                        .padding([.top, .bottom], 6)
                } else {
                    ProgressView()
                }
            })
            .disabled((vm.location == nil || vm.eventTitle.isEmpty) || vm.midSubmit)
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing, .bottom])
            Spacer()
        }
        // Stupid list hack to keep stuff looking good
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.quaternarySystemFill))
    }
}

#Preview {
    NewEventView(loadData: {})
}
