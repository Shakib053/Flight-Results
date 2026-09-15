protocol FlightSearchServicing {
    func fetchFlights(for request: FlightSearchRequest) async throws -> SerpApiFlightSearchResponse
}
