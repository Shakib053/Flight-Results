import Combine
import Foundation
import XCTest
@testable import iOS_Flight_Results

@MainActor
final class FlightResultsViewModelTests: XCTestCase {
    private let request = FlightSearchRequest(originCode: "DAC", originCity: "Dhaka",
        destinationCode: "JFK", destinationCity: "New York", departureDate: Date(),
        passengerCount: 2, currencyCode: "BDT")

    func testSuspendedRequestsAndRetriesExposeLoadingUntilEveryOutcome() async {
        let empty = SerpApiFlightSearchResponse(bestFlights: [], otherFlights: nil)
        let outcomes: [Result<SerpApiFlightSearchResponse, Error>] = [
            .success(response()), .success(empty), .failure(FlightSearchError.transport)
        ]

        for (index, outcome) in outcomes.enumerated() {
            let started = expectation(description: "Request \(index) started")
            let service = SuspendedFlightService(onStart: { started.fulfill() })
            let model = FlightResultsViewModel(request: request, service: service)
            let load = Task { await model.loadFlights() }
            await fulfillment(of: [started], timeout: 2)
            XCTAssertEqual(model.state, .loading)

            // Overlapping requests must not fetch again or replace the pending state.
            await model.loadFlights()
            await model.retry()
            XCTAssertEqual(service.requests, [request])
            XCTAssertEqual(model.state, .loading)

            service.complete(outcome)
            await load.value
            switch index {
            case 0:
                guard case .success(let offers) = model.state else {
                    XCTFail("Expected success"); continue
                }
                XCTAssertEqual(offers.map(\.price), [100, 200])
            case 1:
                XCTAssertEqual(model.state, .empty)
            default:
                XCTAssertEqual(model.state, .error("We couldn’t load flights. Please try again."))
            }

            let retryStarted = expectation(description: "Retry \(index) started")
            service.onStart = { retryStarted.fulfill() }
            let retry = Task { await model.retry() }
            await fulfillment(of: [retryStarted], timeout: 2)
            XCTAssertEqual(model.state, .loading)
            XCTAssertEqual(service.requests, [request, request])
            service.complete(.success(empty))
            await retry.value
            XCTAssertEqual(model.state, .empty)
        }
    }

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

    func testDateFaresMatchRequestedDepartureAndStayStaticAfterLoading() async {
        let model = dateFareModel(year: 2027, month: 2, day: 15)
        let options = model.dateFareOptions
        XCTAssertEqual(options.count, 7)
        XCTAssertEqual(options.first?.id, "2027-02-15")
        XCTAssertEqual(options.first?.dayText, "Mon")
        XCTAssertEqual(options.first?.dateText, "15 Feb")
        XCTAssertEqual(options.filter(\.isSelected).map(\.id), ["2027-02-15"])
        XCTAssertEqual(options.first?.price, 70_129)
        XCTAssertTrue(options.allSatisfy { $0.currencyCode == "BDT" })
        XCTAssertEqual(Set(options.map(\.id)).count, 7)
        await model.loadFlights()
        XCTAssertEqual(model.dateFareOptions, options)
    }

    func testDateFaresCrossMonthAndYearBoundaries() {
        XCTAssertEqual(dateFareModel(year: 2028, month: 2, day: 27).dateFareOptions.map(\.dateText),
                       ["27 Feb", "28 Feb", "29 Feb", "01 Mar", "02 Mar", "03 Mar", "04 Mar"])
        XCTAssertEqual(dateFareModel(year: 2026, month: 12, day: 29).dateFareOptions.map(\.id),
                       ["2026-12-29", "2026-12-30", "2026-12-31", "2027-01-01",
                        "2027-01-02", "2027-01-03", "2027-01-04"])
    }

    private func dateFareModel(year: Int, month: Int, day: Int) -> FlightResultsViewModel {
        let date = Calendar(identifier: .gregorian).date(
            from: DateComponents(year: year, month: month, day: day, hour: 12))!
        let request = FlightSearchRequest(originCode: "DAC", originCity: "Dhaka",
            destinationCode: "JFK", destinationCity: "New York", departureDate: date,
            passengerCount: 2, currencyCode: "USD")
        return FlightResultsViewModel(request: request, service: MockFlightSearchService(result: .empty))
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

@MainActor
private final class SuspendedFlightService: FlightSearchServicing {
    var requests: [FlightSearchRequest] = []
    var onStart: () -> Void
    private var continuation: CheckedContinuation<SerpApiFlightSearchResponse, Error>?

    init(onStart: @escaping () -> Void) { self.onStart = onStart }

    func fetchFlights(for request: FlightSearchRequest) async throws -> SerpApiFlightSearchResponse {
        requests.append(request)
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            onStart()
        }
    }

    func complete(_ result: Result<SerpApiFlightSearchResponse, Error>) {
        let pending = continuation
        continuation = nil
        pending?.resume(with: result)
    }
}
