import Foundation
import XCTest
@testable import iOS_Flight_Results

@MainActor
final class SerpApiDTOsTests: XCTestCase {
    private let mapper = FlightOfferMapper()

    func testKnownFlightDataSummaryDecodesAndContainsNoDuplicateOffers() throws {
        let prices = [212, 220, 220, 246, 324, 329, 367, 417]
        let groups = prices.enumerated().map { index, price -> [String: Any] in
            var group = validGroup()
            var leg = validLeg(airline: "Airline \(index)")
            leg["duration"] = 150 + index
            group["flights"] = [leg]
            group["total_duration"] = 150 + index
            group["price"] = price
            return group
        }
        let response = try decode([
            "best_flights": Array(groups.prefix(4)),
            "other_flights": Array(groups.dropFirst(4))
        ])
        let offers = mapper.map(response, currencyCode: "USD")

        XCTAssertEqual(response.bestFlights?.count, 4)
        XCTAssertEqual(response.otherFlights?.count, 4)
        XCTAssertEqual(offers.count, 8)
        XCTAssertEqual(Set(offers.map(\.id)).count, 8)
        XCTAssertEqual(offers.map(\.price), [212, 220, 220, 246, 324, 329, 367, 417])
        XCTAssertEqual(offers.first?.departureAirportCode, "DAC")
        XCTAssertEqual(offers.first?.arrivalAirportCode, "BKK")
    }

    func testMissingNullAndWrongRequiredValuesDecodeButAreRejectedByMapper() throws {
        let cases: [(key: String, value: Any?)] = [
            ("flights", nil), ("flights", NSNull()), ("flights", "not-an-array"),
            ("price", nil), ("price", NSNull()), ("price", "212"),
            ("total_duration", nil), ("total_duration", NSNull()), ("total_duration", false)
        ]

        for testCase in cases {
            var group = validGroup()
            if let value = testCase.value {
                group[testCase.key] = value
            } else {
                group.removeValue(forKey: testCase.key)
            }
            let response = try decode(["best_flights": [group]])
            XCTAssertTrue(mapper.map(response, currencyCode: "USD").isEmpty,
                          "Expected invalid \(testCase.key)=\(String(describing: testCase.value)) to be skipped")
        }
    }

    func testMissingNullAndWrongAirlineDecodeButRejectWholeItinerary() throws {
        for value: Any? in [nil, NSNull(), 42] {
            var malformedLeg = validLeg(airline: "Broken")
            if let value {
                malformedLeg["airline"] = value
            } else {
                malformedLeg.removeValue(forKey: "airline")
            }
            var group = validGroup()
            group["flights"] = [validLeg(), malformedLeg]

            let response = try decode(["best_flights": [group]])

            XCTAssertTrue(mapper.map(response, currencyCode: "USD").isEmpty)
        }
    }

    func testUndecodableGroupIsDiscardedWithoutLosingValidSibling() throws {
        let response = try decode(["best_flights": ["not-a-group", validGroup()]])

        XCTAssertEqual(response.bestFlights?.count, 1)
        XCTAssertEqual(mapper.map(response, currencyCode: "USD").count, 1)
    }

    func testMissingNullAndWrongTopLevelArrayPreserveOtherArray() throws {
        let values: [Any?] = [nil, NSNull(), "not-an-array"]
        for value in values {
            var payload: [String: Any] = ["other_flights": [validGroup()]]
            if let value {
                payload["best_flights"] = value
            }

            let response = try decode(payload)

            XCTAssertNil(response.bestFlights)
            XCTAssertEqual(mapper.map(response, currencyCode: "USD").count, 1)
        }
    }

    func testInvalidRootStillThrowsDecodingError() {
        XCTAssertThrowsError(try JSONDecoder().decode(
            SerpApiFlightSearchResponse.self, from: Data("[]".utf8)
        ))
    }

    func testFullyEmptyGoogleFlightsPayloadMapsToEmptyResults() throws {
        let response = try decode([
            "search_information": ["flights_results_state": "Fully empty"],
            "error": "Google Flights hasn't returned any results for this query."
        ])

        XCTAssertTrue(mapper.map(response, currencyCode: "USD").isEmpty)
    }

    private func decode(_ payload: [String: Any]) throws -> SerpApiFlightSearchResponse {
        let data = try JSONSerialization.data(withJSONObject: payload)
        return try JSONDecoder().decode(SerpApiFlightSearchResponse.self, from: data)
    }

    private func validGroup() -> [String: Any] {
        ["flights": [validLeg()], "total_duration": 155, "price": 212]
    }

    private func validLeg(airline: String = "Airline") -> [String: Any] {
        [
            "departure_airport": ["id": "DAC", "time": "2027-02-15 09:35"],
            "arrival_airport": ["id": "BKK", "time": "2027-02-15 13:10"],
            "duration": 155,
            "airline": airline
        ]
    }
}
