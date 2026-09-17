@testable import iOS_Flight_Results

struct MockFlightSearchService: FlightSearchServicing {
    enum Result {
        case success(SerpApiFlightSearchResponse)
        case empty
        case failure(Error)
    }

    let result: Result

    init(result: Result) {
        self.result = result
    }

    func fetchFlights(for request: FlightSearchRequest) async throws -> SerpApiFlightSearchResponse {
        switch result {
        case .success(let response): return response
        case .empty: return SerpApiFlightSearchResponse(bestFlights: [], otherFlights: [])
        case .failure(let error): throw error
        }
    }
}
