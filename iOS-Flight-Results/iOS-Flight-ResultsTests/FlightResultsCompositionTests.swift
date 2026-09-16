import Foundation
import XCTest
@testable import iOS_Flight_Results

@MainActor
final class FlightResultsCompositionTests: XCTestCase {
    func testCompositionUsesUSDAndFutureDate() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let coordinator = FlightResultsCoordinator(
            service: MockFlightSearchService(result: .empty), now: now, openURL: { _ in }
        )
        let request = coordinator.viewModel.request
        XCTAssertEqual(request.originCode, "DAC")
        XCTAssertEqual(request.destinationCode, "JFK")
        XCTAssertEqual(request.currencyCode, "USD")
        XCTAssertEqual(request.passengerCount, 2)
        XCTAssertEqual(request.departureDate, Calendar.current.date(byAdding: .day, value: 30, to: now))
        await coordinator.viewModel.loadFlights()
        XCTAssertEqual(coordinator.viewModel.state, .empty)
    }

    func testPromotionIntentReachesCoordinator() async {
        var openedURL: URL?
        let coordinator = FlightResultsCoordinator(
            service: MockFlightSearchService(result: .empty), openURL: { openedURL = $0 }
        )
        let url = URL(string: "https://gozayaan.com")!
        coordinator.viewModel.selectPromotion(Promotion(id: "promo", imageName: "", title: "Offer", url: url))
        XCTAssertEqual(openedURL, url)
    }
}
