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
        ContentView()
    }
}


struct ContentView: View {
    @StateObject private var vm = FlightResultsViewModel(
        request: FlightSearchRequest(
            originCode: "DAC",
            originCity: "Dhaka",
            destinationCode: "BKK",
            destinationCity: "Bangkok",
            departureDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            passengerCount: 2,
            currencyCode: "USD"
        ),
        service: SerpApiFlightSearchService()
    )

    var body: some View {
        VStack(spacing: 16) {
            Text("DAC → BKK · Data check")
                .font(.headline)

            switch vm.state {
            case .loading:
                ProgressView("Loading flights…")
            case .success(let offers):
                Text("Received \(offers.count) flight offers")
                List(offers) { offer in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer.airlineName)
                        Text("\(offer.departureAirportCode) → \(offer.arrivalAirportCode)")
                        Text("\(offer.currencyCode) \(offer.price)")
                    }
                }
            case .empty:
                Text("Request succeeded, but no flight offers were returned.")
            case .error(let message):
                Text(message)
                Button("Retry") {
                    Task { await vm.retry() }
                }
            }
        }
        .padding()
        .task {
            await vm.loadFlights()
            print(vm.state)
        }
    }
}
#Preview {
    FlightResultsView()
}
