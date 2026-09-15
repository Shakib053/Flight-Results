import Foundation

/// Search inputs shared by the route header and the one-way API request.
struct FlightSearchRequest: Equatable {
    let originCode: String
    let originCity: String
    let destinationCode: String
    let destinationCity: String
    let departureDate: Date
    let passengerCount: Int
    let currencyCode: String
}
