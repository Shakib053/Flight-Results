import Foundation

/// A flattened itinerary produced by mapping the API response.
struct FlightOffer: Identifiable, Equatable {
    let id: String
    let airlineName: String
    let airlineLogoURL: URL?
    let departureAirportCode: String
    let arrivalAirportCode: String
    // Airport-local display times; mapping must not convert to the device time zone.
    let departureTime: String
    let arrivalTime: String
    let arrivalDayOffset: Int
    let totalDurationMinutes: Int
    let stopCount: Int
    let price: Int
    let currencyCode: String
}
