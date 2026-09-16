import Combine
import Foundation

@MainActor
final class FlightResultsViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case success([FlightOffer])
        case empty
        case error(String)
    }

    enum SortOption: String, CaseIterable {
        case cheapest = "Cheapest"
        case fastest = "Fastest"
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var sortOption: SortOption = .cheapest
    let request: FlightSearchRequest
    private let service: any FlightSearchServicing
    private let mapper: FlightOfferMapper
    private var offers: [FlightOffer] = []
    private var isLoading = false

    init(request: FlightSearchRequest, service: any FlightSearchServicing,
         mapper: FlightOfferMapper? = nil) {
        self.request = request
        self.service = service
        self.mapper = mapper ?? FlightOfferMapper()
    }

    func loadFlights() async {
        // Ignore overlapping loads so an older response cannot replace newer state.
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        state = .loading
        do {
            let response = try await service.fetchFlights(for: request)
            try Task.checkCancellation()
            offers = mapper.map(response, currencyCode: request.currencyCode)
            state = offers.isEmpty ? .empty : .success(sortedOffers())
        } catch is CancellationError {
            // A disappearing screen may cancel its task; don't show a network error.
        } catch {
            #if DEBUG
            // Only log our sanitized error enum, never credential-bearing URLs.
            if let searchError = error as? FlightSearchError {
                print("Flight search failed: \(searchError)")
            }
            #endif
            offers = []
            state = .error("We couldn’t load flights. Please try again.")
        }
    }

    func retry() async {
        await loadFlights()
    }

    func selectSort(_ option: SortOption) {
        sortOption = option
        if case .success = state {
            state = .success(sortedOffers())
        }
    }

    private func sortedOffers() -> [FlightOffer] {
        offers.sorted { lhs, rhs in
            let left = sortOption == .cheapest ? lhs.price : lhs.totalDurationMinutes
            let right = sortOption == .cheapest ? rhs.price : rhs.totalDurationMinutes
            return left == right ? lhs.id < rhs.id : left < right
        }
    }
}
