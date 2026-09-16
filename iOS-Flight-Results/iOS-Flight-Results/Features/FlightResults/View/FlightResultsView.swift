//
//  FlightResultsView.swift
//  iOS-Flight-Results
//
//  Created by Kazi Tanjim Shakib on 15/9/26.
//

import Combine
import SwiftUI

/// Renders an injected ViewModel owned by the feature Coordinator.
struct FlightResultsView: View {
    @ObservedObject var viewModel: FlightResultsViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var displayedState: FlightResultsViewModel.State = .loading
    @State private var isCompletingLoading = false
    @State private var completionTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            RouteHeaderView(request: viewModel.request) {
                print("Edit tapped")
            }

            if isDateFareStripVisible {
                DateFareStripView(
                    options: viewModel.dateFareOptions,
                    isLoading: isLoadingVisible
                )
            }

            switch displayedState {
            case .loading:
                SortFilterBarView(
                    selectedSort: viewModel.sortOption,
                    isSortEnabled: false,
                    onSelectSort: viewModel.selectSort,
                    onFilterTapped: {}
                )
                LoadingSkeletonView(isCompleting: isCompletingLoading,
                                    promotions: viewModel.promotions,
                                    onLearnMore: viewModel.selectPromotion)
            case .success(let offers):
                SortFilterBarView(
                    selectedSort: viewModel.sortOption,
                    isSortEnabled: true,
                    onSelectSort: viewModel.selectSort,
                    onFilterTapped: {}
                )
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(offers.prefix(2)) { offer in
                            FlightCardView(offer: offer)
                                .padding(.horizontal, 16)
                        }
                        DiscountCarouselView(promotions: viewModel.promotions,
                                             onLearnMore: viewModel.selectPromotion)
                        ForEach(offers.dropFirst(2)) { offer in
                            FlightCardView(offer: offer)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(red: 0.035, green: 0, blue: 0.38))
            case .empty:
                EmptyStateView {
                    Task { await viewModel.retry() }
                }
            case .error:
                ErrorStateView {
                    Task { await viewModel.retry() }
                }
            }
        }
        .task {
            await viewModel.loadFlights()
        }
        .onReceive(viewModel.$state.removeDuplicates()) { state in
            show(state)
        }
        .onDisappear {
            completionTask?.cancel()
        }
    }

    private var isLoadingVisible: Bool {
        if case .loading = displayedState { return true }
        return false
    }

    private var isDateFareStripVisible: Bool {
        Self.shouldShowDateFareStrip(for: displayedState)
    }

    static func shouldShowDateFareStrip(for state: FlightResultsViewModel.State) -> Bool {
        switch state {
        case .loading, .success:
            return true
        case .empty, .error:
            return false
        }
    }

    private func show(_ state: FlightResultsViewModel.State) {
        completionTask?.cancel()

        guard case .loading = state else {
            guard case .loading = displayedState, !reduceMotion else {
                displayedState = state
                isCompletingLoading = false
                return
            }

            isCompletingLoading = true
            completionTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(220))
                guard !Task.isCancelled else { return }
                displayedState = state
                isCompletingLoading = false
            }
            return
        }

        displayedState = .loading
        isCompletingLoading = false
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
