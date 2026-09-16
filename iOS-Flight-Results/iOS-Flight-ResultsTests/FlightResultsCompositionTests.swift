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

    func testDummyPromotionsNavigateDuringLoadingAndAfterSuccess() async {
        var openedURLs: [URL] = []
        let leg = SerpApiFlightLeg(
            departureAirport: SerpApiAirport(id: "DAC", time: "2026-10-01 10:00"),
            arrivalAirport: SerpApiAirport(id: "BKK", time: "2026-10-01 12:00"),
            duration: 120, airline: "Airline", airlineLogo: nil)
        let response = SerpApiFlightSearchResponse(bestFlights: [
            SerpApiFlightGroup(flights: [leg], layovers: nil,
                              totalDuration: 120, price: 100, airlineLogo: nil)
        ], otherFlights: nil)
        let coordinator = FlightResultsCoordinator(
            service: MockFlightSearchService(result: .success(response)),
            openURL: { openedURLs.append($0) })
        let model = coordinator.viewModel
        let promotions = model.promotions
        XCTAssertEqual(model.state, .loading)
        XCTAssertEqual(promotions.count, 3)
        XCTAssertEqual(Set(promotions.map(\.id)).count, 3)
        XCTAssertTrue(promotions.allSatisfy { $0.imageName == "discount view" })
        promotions.forEach(model.selectPromotion)
        await model.loadFlights()
        guard case .success = model.state else { return XCTFail("Expected success") }
        model.selectSort(.fastest)
        XCTAssertEqual(model.promotions, promotions)
        promotions.forEach(model.selectPromotion)
        XCTAssertEqual(openedURLs, Array(repeating: URL(string: "https://gozayaan.com")!, count: 6))
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
