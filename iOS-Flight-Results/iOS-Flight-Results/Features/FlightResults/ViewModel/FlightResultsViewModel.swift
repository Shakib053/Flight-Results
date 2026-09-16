import Combine
import Foundation

@MainActor
final class FlightResultsViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case success([FlightOffer])
        case empty
        case error
    }

    enum SortOption: String, CaseIterable {
        case cheapest = "Cheapest"
        case fastest = "Fastest"
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var sortOption: SortOption = .cheapest
    @Published private(set) var dateFareOptions: [DateFareOption]
    
    weak var output: (any FlightResultsCoordinatorDelegate)?
    
    let request: FlightSearchRequest
    let promotions: [Promotion]
    
    private let service: any FlightSearchServicing
    private let mapper: FlightOfferMapper
    private var offers: [FlightOffer] = []
    private var isLoading = false

    init(request: FlightSearchRequest, service: any FlightSearchServicing,
         mapper: FlightOfferMapper? = nil,
         promotions: [Promotion]? = nil,
         dateFareOptions: [DateFareOption]? = nil) {
        self.dateFareOptions = dateFareOptions
            ?? FlightResultsDummyData.dateFareOptions(departureDate: request.departureDate)
        self.promotions = promotions ?? FlightResultsDummyData.promotions
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
            updateSelectedDateFare(with: offers)
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
            state = .error
        }
    }

    func selectPromotion(_ promotion: Promotion) {
        output?.didSelectPromotion(promotion)
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

    /// The selected date reflects the cheapest successfully returned offer; adjacent dates are samples.
    private func updateSelectedDateFare(with offers: [FlightOffer]) {
        guard let cheapestOffer = offers.min(by: { $0.price < $1.price }),
              let selectedIndex = dateFareOptions.firstIndex(where: \.isSelected) else { return }

        let selectedOption = dateFareOptions[selectedIndex]
        dateFareOptions[selectedIndex] = DateFareOption(
            id: selectedOption.id,
            dayText: selectedOption.dayText,
            dateText: selectedOption.dateText,
            price: cheapestOffer.price,
            currencyCode: cheapestOffer.currencyCode,
            isSelected: true
        )
    }

    private func sortedOffers() -> [FlightOffer] {
        offers.sorted { lhs, rhs in
            let left = sortOption == .cheapest ? lhs.price : lhs.totalDurationMinutes
            let right = sortOption == .cheapest ? rhs.price : rhs.totalDurationMinutes
            return left == right ? lhs.id < rhs.id : left < right
        }
    }
}
