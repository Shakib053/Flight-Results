import Foundation

/// Transport models preserve the API nesting; FlightOfferMapper owns presentation mapping.
struct SerpApiFlightSearchResponse: Decodable {
    let bestFlights: [SerpApiFlightGroup]?
    let otherFlights: [SerpApiFlightGroup]?

    enum CodingKeys: String, CodingKey {
        case bestFlights = "best_flights"
        case otherFlights = "other_flights"
    }

    init(bestFlights: [SerpApiFlightGroup]?, otherFlights: [SerpApiFlightGroup]?) {
        self.bestFlights = bestFlights
        self.otherFlights = otherFlights
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bestFlights = container.decodeLossyArrayIfPresent(SerpApiFlightGroup.self, forKey: .bestFlights)
        otherFlights = container.decodeLossyArrayIfPresent(SerpApiFlightGroup.self, forKey: .otherFlights)
    }
}

struct SerpApiFlightGroup: Decodable {
    let flights: [SerpApiFlightLeg]?
    let layovers: [SerpApiLayover]?
    let totalDuration: Int?
    let price: Int?
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case flights
        case layovers
        case totalDuration = "total_duration"
        case price
        case airlineLogo = "airline_logo"
    }

    init(flights: [SerpApiFlightLeg]?, layovers: [SerpApiLayover]?,
         totalDuration: Int?, price: Int?, airlineLogo: String?) {
        self.flights = flights
        self.layovers = layovers
        self.totalDuration = totalDuration
        self.price = price
        self.airlineLogo = airlineLogo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // A bad leg invalidates the whole itinerary; never display a shortened route.
        flights = container.decodeIfPresentIgnoringInvalidValue([SerpApiFlightLeg].self, forKey: .flights)
        layovers = container.decodeIfPresentIgnoringInvalidValue([SerpApiLayover].self, forKey: .layovers)
        totalDuration = container.decodeIfPresentIgnoringInvalidValue(Int.self, forKey: .totalDuration)
        price = container.decodeIfPresentIgnoringInvalidValue(Int.self, forKey: .price)
        airlineLogo = container.decodeIfPresentIgnoringInvalidValue(String.self, forKey: .airlineLogo)
    }
}

struct SerpApiFlightLeg: Decodable {
    let departureAirport: SerpApiAirport
    let arrivalAirport: SerpApiAirport
    let duration: Int
    let airline: String?
    let airlineLogo: String?

    enum CodingKeys: String, CodingKey {
        case departureAirport = "departure_airport"
        case arrivalAirport = "arrival_airport"
        case duration
        case airline
        case airlineLogo = "airline_logo"
    }

    init(departureAirport: SerpApiAirport, arrivalAirport: SerpApiAirport,
         duration: Int, airline: String?, airlineLogo: String?) {
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.duration = duration
        self.airline = airline
        self.airlineLogo = airlineLogo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        departureAirport = try container.decode(SerpApiAirport.self, forKey: .departureAirport)
        arrivalAirport = try container.decode(SerpApiAirport.self, forKey: .arrivalAirport)
        duration = try container.decode(Int.self, forKey: .duration)
        airline = container.decodeIfPresentIgnoringInvalidValue(String.self, forKey: .airline)
        airlineLogo = container.decodeIfPresentIgnoringInvalidValue(String.self, forKey: .airlineLogo)
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

private struct LossyElement<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}

private extension KeyedDecodingContainer {
    func decodeIfPresentIgnoringInvalidValue<Value: Decodable>(
        _ type: Value.Type, forKey key: Key
    ) -> Value? {
        do {
            return try decodeIfPresent(type, forKey: key)
        } catch {
            return nil
        }
    }

    func decodeLossyArrayIfPresent<Element: Decodable>(
        _ type: Element.Type, forKey key: Key
    ) -> [Element]? {
        guard contains(key), (try? decodeNil(forKey: key)) == false else { return nil }
        return (try? decode([LossyElement<Element>].self, forKey: key))?.compactMap(\.value)
    }
}
