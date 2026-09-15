import Foundation

/// Transport models preserve the API nesting; FlightOfferMapper owns presentation mapping.
struct SerpApiFlightSearchResponse: Codable {
    let bestFlights: [SerpApiFlightGroup]?
    let otherFlights: [SerpApiFlightGroup]?

    enum CodingKeys: String, CodingKey {
        case bestFlights = "best_flights"
        case otherFlights = "other_flights"
    }
}

struct SerpApiFlightGroup: Codable {
    let flights: [SerpApiFlightLeg]
    let layovers: [SerpApiLayover]?
    let totalDuration: Int
    let price: Int
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case flights
        case layovers
        case totalDuration = "total_duration"
        case price
        case airlineLogo = "airline_logo"
    }
}

struct SerpApiFlightLeg: Codable {
    let departureAirport: SerpApiAirport
    let arrivalAirport: SerpApiAirport
    let duration: Int
    let airline: String
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case departureAirport = "departure_airport"
        case arrivalAirport = "arrival_airport"
        case duration
        case airline
        case airlineLogo = "airline_logo"
    }
}

struct SerpApiAirport: Codable {
    let id: String
    /// Airport-local timestamp retained exactly as supplied by the API.
    let time: String
}

struct SerpApiLayover: Codable {
    let duration: Int
    let id: String
    let name: String
    let overnight: Bool?
}
