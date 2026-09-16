import Foundation
import SwiftUI

@MainActor
final class FlightResultsCoordinator: FlightResultsCoordinatorDelegate {
    let viewModel: FlightResultsViewModel
    private let openURL: (URL) -> Void

    init(service: any FlightSearchServicing,
         now: Date = Date(), openURL: @escaping (URL) -> Void) {
        self.openURL = openURL
        let request = FlightSearchRequest(
            originCode: "DAC", originCity: "Dhaka",
            destinationCode: "JFK", destinationCity: "New York",
            departureDate: Calendar.current.date(byAdding: .day, value: 30, to: now)!,
            passengerCount: 2, currencyCode: "USD"
        )
        viewModel = FlightResultsViewModel(
            request: request, service: service,
            mapper: FlightOfferMapper(usdToBdtRate: 123)
        )
        viewModel.output = self
    }

    func makeView() -> FlightResultsView {
        FlightResultsView(viewModel: viewModel)
    }

    func didSelectPromotion(_ promotion: Promotion) {
        openURL(promotion.url)
    }
}
