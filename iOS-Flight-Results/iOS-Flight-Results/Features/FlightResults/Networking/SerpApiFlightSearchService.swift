import Foundation

enum FlightSearchError: Error, Equatable {
    case missingAPIKey
    case invalidRequest
    case transport
    case invalidResponse
    case httpStatus(Int)
    case decoding
    case apiError
}

struct SerpApiFlightSearchService: FlightSearchServicing {
    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String = Config.serpApiKey) {
        self.session = session
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func fetchFlights(for request: FlightSearchRequest) async throws -> SerpApiFlightSearchResponse {
        guard !apiKey.isEmpty, !apiKey.contains("$("), apiKey != "YOUR_SERPAPI_KEY" else {
            throw FlightSearchError.missingAPIKey
        }
        guard request.passengerCount > 0 else { throw FlightSearchError.invalidRequest }

        // Treat departureDate as a calendar day in the user's current time zone.
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"

        var components = URLComponents(string: "https://serpapi.com/search")!
        components.queryItems = [
            URLQueryItem(name: "engine", value: "google_flights"),
            URLQueryItem(name: "departure_id", value: request.originCode),
            URLQueryItem(name: "arrival_id", value: request.destinationCode),
            URLQueryItem(name: "outbound_date", value: formatter.string(from: request.departureDate)),
            URLQueryItem(name: "type", value: "2"),
            URLQueryItem(name: "adults", value: String(request.passengerCount)),
            URLQueryItem(name: "currency", value: request.currencyCode),
            URLQueryItem(name: "hl", value: "en"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        guard let url = components.url else { throw FlightSearchError.invalidRequest }
        var loggedComponents = components
        loggedComponents.queryItems = loggedComponents.queryItems?.map { item in
            item.name == "api_key" ? URLQueryItem(name: item.name, value: "<redacted>") : item
        }

        // Temporary diagnostic logging helps investigate request and response issues.
        // Production apps should route this through OSLog with appropriate privacy redaction.

        print("Google Flights API request: \(loggedComponents.url?.absoluteString ?? url.absoluteString)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            // Underlying errors can contain the request URL and its API key.
            throw FlightSearchError.transport
        }

        // Temporary raw-response logging is retained to diagnose API payload and empty-result behavior.
        // Replace with privacy-aware OSLog instrumentation before production release.

        print("Google Flights API response: \(String(data: data, encoding: .utf8) ?? "<non-UTF8 response>")")

        guard let http = response as? HTTPURLResponse else {
            throw FlightSearchError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw FlightSearchError.httpStatus(http.statusCode)
        }
        // Google returns an `error` string for a valid search with no matching flights.
        // Preserve that payload as an empty result so the UI can show EmptyStateView.
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           object["error"] is String,
           !isFullyEmptyFlightSearch(object) {
            throw FlightSearchError.apiError
        }
        do {
            return try JSONDecoder().decode(SerpApiFlightSearchResponse.self, from: data)
        } catch {
            throw FlightSearchError.decoding
        }
    }

    private func isFullyEmptyFlightSearch(_ object: [String: Any]) -> Bool {
        guard let information = object["search_information"] as? [String: Any],
              let state = information["flights_results_state"] as? String else {
            return false
        }
        return state.caseInsensitiveCompare("Fully empty") == .orderedSame
    }
}
