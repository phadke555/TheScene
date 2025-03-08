//
//  LocationRequestView.swift
//  TheScene
//
//  Created by Ryder Klein on 11/21/23.
//

import SwiftUI

struct LocationRequestView: View {
    @ObservedObject var lm: LocationManager
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.circle.fill")
                .resizable()
                .foregroundStyle(Color(.systemBlue))
                .frame(width: 50, height: 50)
            Text("We will use your location to show you nearby events.")
                .multilineTextAlignment(.center)
            Button {
                lm.requestLocationAuthorization()
            } label: {
                Text("Allow Access")
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    LocationRequestView(lm: LocationManager())
}
