import Combine
import Foundation
import XCTest
@testable import iOS_Flight_Results

@MainActor
final class FlightResultsViewModelTests: XCTestCase {
    private let request = FlightSearchRequest(originCode: "DAC", originCity: "Dhaka",
        destinationCode: "JFK", destinationCity: "New York", departureDate: Date(),
        passengerCount: 2, currencyCode: "BDT")

    func testSuccessAndSortingWithoutRefetching() async {
        let service = RecordingService(response: response())
        let model = FlightResultsViewModel(request: request, service: service)
        var states: [FlightResultsViewModel.State] = []
        let subscription = model.$state.sink { states.append($0) }
        await model.loadFlights()
        XCTAssertEqual(states.first, .loading)
        guard case .success(let cheapest) = model.state else { return XCTFail("Expected success") }
        XCTAssertEqual(cheapest.map(\.price), [100, 200])
        model.selectSort(.fastest)
        guard case .success(let fastest) = model.state else { return XCTFail("Expected success") }
        XCTAssertEqual(fastest.map(\.totalDurationMinutes), [60, 120])
        XCTAssertEqual(service.requests, [request])
        model.selectSort(.cheapest)
        XCTAssertEqual(model.state, .success(cheapest))
        XCTAssertEqual(service.requests.count, 1)
        withExtendedLifetime(subscription) {}
    }

    func testEmptyAndRetryRepeatSameRequest() async {
        let service = RecordingService(response: SerpApiFlightSearchResponse(bestFlights: [], otherFlights: nil))
        let model = FlightResultsViewModel(request: request, service: service)
        await model.loadFlights()
        XCTAssertEqual(model.state, .empty)
        await model.retry()
        XCTAssertEqual(model.state, .empty)
        XCTAssertEqual(service.requests, [request, request])
    }

    func testFailuresUseSafeMessage() async {
        for error in [FlightSearchError.missingAPIKey, .transport, .httpStatus(500), .decoding, .apiError] {
            let model = FlightResultsViewModel(request: request,
                service: MockFlightSearchService(result: .failure(error)))
            await model.loadFlights()
            XCTAssertEqual(model.state, .error("We couldn’t load flights. Please try again."))
        }
    }

    func testInvalidOffersProduceEmptyState() async {
        let response = SerpApiFlightSearchResponse(bestFlights: [SerpApiFlightGroup(
            flights: [], layovers: nil, totalDuration: 0, price: 100, airlineLogo: nil)], otherFlights: nil)
        let model = FlightResultsViewModel(request: request, service: MockFlightSearchService(result: .success(response)))
        await model.loadFlights()
        XCTAssertEqual(model.state, .empty)
    }

    private func response() -> SerpApiFlightSearchResponse {
        let leg = SerpApiFlightLeg(
            departureAirport: SerpApiAirport(id: "DAC", time: "2026-10-01 10:00"),
            arrivalAirport: SerpApiAirport(id: "JFK", time: "2026-10-01 12:00"),
            duration: 120, airline: "Airline", airlineLogo: nil)
        return SerpApiFlightSearchResponse(bestFlights: [
            SerpApiFlightGroup(flights: [leg], layovers: nil, totalDuration: 60, price: 200, airlineLogo: nil),
            SerpApiFlightGroup(flights: [leg], layovers: nil, totalDuration: 120, price: 100, airlineLogo: nil)
        ], otherFlights: nil)
    }
}

private final class RecordingService: FlightSearchServicing {
    var requests: [FlightSearchRequest] = []
    let response: SerpApiFlightSearchResponse
    init(response: SerpApiFlightSearchResponse) { self.response = response }
    func fetchFlights(for request: FlightSearchRequest) async throws -> SerpApiFlightSearchResponse {
        requests.append(request)
        return response
    }
}
