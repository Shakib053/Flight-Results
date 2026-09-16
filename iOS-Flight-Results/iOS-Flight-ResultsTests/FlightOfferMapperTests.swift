import XCTest
@testable import iOS_Flight_Results

final class FlightOfferMapperTests: XCTestCase {
    private let mapper = FlightOfferMapper()

    func testDirectFlightAndStableIdentity() throws {
        let group = group([leg()])
        let offer = try XCTUnwrap(mapper.map(group, currencyCode: "BDT"))
        XCTAssertEqual(offer.departureTime, "23:30")
        XCTAssertEqual(offer.arrivalTime, "04:30")
        XCTAssertEqual(offer.arrivalDayOffset, 1)
        XCTAssertEqual(offer.stopCount, 0)
        XCTAssertEqual(offer.price, 37400)
        XCTAssertEqual(offer.totalDurationMinutes, 300)
        XCTAssertEqual(offer.currencyCode, "BDT")
        XCTAssertNil(offer.airlineLogoURL)
        XCTAssertEqual(offer.id, mapper.map(group, currencyCode: "BDT")?.id)
    }

    func testThreeLegFlightUsesEndpointsAndPreservesAirlines() throws {
        let legs = [leg(), leg(origin: "BKK", destination: "DOH", airline: "Second"),
                    leg(origin: "DOH", destination: "JFK", arrival: "2026-10-03 08:00")]
        let offer = try XCTUnwrap(mapper.map(group(legs), currencyCode: "BDT"))
        XCTAssertEqual(offer.departureAirportCode, "DAC")
        XCTAssertEqual(offer.arrivalAirportCode, "JFK")
        XCTAssertEqual(offer.airlineName, "First, Second")
        XCTAssertEqual(offer.stopCount, 2)
        XCTAssertEqual(offer.arrivalDayOffset, 2)
    }

    func testExplicitLayoversTakePrecedenceAndLogoFallsBackToLeg() throws {
        let group = SerpApiFlightGroup(flights: [leg(logo: "https://example.com/logo.png")],
            layovers: [SerpApiLayover(duration: 60, id: "DOH", name: "Doha", overnight: nil)],
            totalDuration: 300, price: 37400, airlineLogo: "invalid")
        let offer = try XCTUnwrap(mapper.map(group, currencyCode: "BDT"))
        XCTAssertEqual(offer.stopCount, 1)
        XCTAssertEqual(offer.airlineLogoURL?.absoluteString, "https://example.com/logo.png")
    }

    func testEmptyAndInvalidGroupsAreSkipped() {
        XCTAssertNil(mapper.map(group([]), currencyCode: "BDT"))
        XCTAssertNil(mapper.map(group([leg(arrival: "invalid")]), currencyCode: "BDT"))
        XCTAssertTrue(mapper.map(SerpApiFlightSearchResponse(bestFlights: nil, otherFlights: nil), currencyCode: "BDT").isEmpty)
    }

    func testCombinesBothArraysInSourceOrder() {
        let response = SerpApiFlightSearchResponse(bestFlights: [group([]), group([leg()])],
            otherFlights: [group([leg(airline: "Second")])])
        XCTAssertEqual(mapper.map(response, currencyCode: "BDT").map(\.airlineName), ["First", "Second"])
    }

    private func leg(origin: String = "DAC", destination: String = "BKK",
                     arrival: String = "2026-10-02 04:30", airline: String = "First",
                     logo: String? = nil) -> SerpApiFlightLeg {
        SerpApiFlightLeg(departureAirport: SerpApiAirport(id: origin, time: "2026-10-01 23:30"),
            arrivalAirport: SerpApiAirport(id: destination, time: arrival),
            duration: 300, airline: airline, airlineLogo: logo)
    }

    private func group(_ flights: [SerpApiFlightLeg]) -> SerpApiFlightGroup {
        SerpApiFlightGroup(flights: flights, layovers: nil, totalDuration: 300, price: 37400, airlineLogo: nil)
    }
}
