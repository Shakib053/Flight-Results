//
//  FlightResultsView.swift
//  iOS-Flight-Results
//
//  Created by Kazi Tanjim Shakib on 15/9/26.
//

import SwiftUI

/// The feature entry point. It will own rendering only; networking, mapping,
/// sorting, and external navigation are injected from the composition root.
struct FlightResultsView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    FlightResultsView()
}
