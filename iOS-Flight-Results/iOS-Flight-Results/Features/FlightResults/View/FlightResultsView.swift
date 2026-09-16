//
//  FlightResultsView.swift
//  iOS-Flight-Results
//
//  Created by Kazi Tanjim Shakib on 15/9/26.
//

import SwiftUI

/// Renders an injected ViewModel owned by the feature Coordinator.
struct FlightResultsView: View {
    @ObservedObject var viewModel: FlightResultsViewModel

    var body: some View {
        VStack(spacing: 0) {
            RouteHeaderView(request: viewModel.request) {
                print("Edit tapped")
            }

            DateFareStripView(
                options: viewModel.dateFareOptions,
                isLoading: viewModel.state == .loading
            )

            VStack(spacing: 16) {
                switch viewModel.state {
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
                    Button("Try Again") {
                        Task { await viewModel.retry() }
                    }
                case .error(let message):
                    Text(message)
                    Button("Retry") {
                        Task { await viewModel.retry() }
                    }
                }
            }
            .padding()
        }
        .task {
            await viewModel.loadFlights()
        }
    }
}
#Preview {
    FlightResultsView(viewModel: FlightResultsViewModel(
        request: FlightSearchRequest(
            originCode: "DAC", originCity: "Dhaka",
            destinationCode: "JFK", destinationCity: "New York",
            departureDate: Date(), passengerCount: 2, currencyCode: "USD"
        ),
        service: MockFlightSearchService(result: .empty)
    ))
}
