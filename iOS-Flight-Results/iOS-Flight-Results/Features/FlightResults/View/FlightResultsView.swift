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

            switch viewModel.state {
            case .loading:
                SortFilterBarView(
                    selectedSort: viewModel.sortOption,
                    isSortEnabled: false,
                    onSelectSort: viewModel.selectSort,
                    onFilterTapped: {}
                )
                LoadingSkeletonView()
            case .success(let offers):
                SortFilterBarView(
                    selectedSort: viewModel.sortOption,
                    isSortEnabled: true,
                    onSelectSort: viewModel.selectSort,
                    onFilterTapped: {}
                )
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(offers) { offer in
                            FlightCardView(offer: offer)
                        }
                    }
                    .padding(16)
                }
                .background(Color(red: 0.035, green: 0, blue: 0.38))
            case .empty:
                resultsContent {
                    Text("Request succeeded, but no flight offers were returned.")
                    Button("Try Again") {
                        Task { await viewModel.retry() }
                    }
                }
            case .error(let message):
                resultsContent {
                    Text(message)
                    Button("Retry") {
                        Task { await viewModel.retry() }
                    }
                }
            }
        }
        .task {
            await viewModel.loadFlights()
        }
    }

    @ViewBuilder
    private func resultsContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 16, content: content)
            .padding()
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
