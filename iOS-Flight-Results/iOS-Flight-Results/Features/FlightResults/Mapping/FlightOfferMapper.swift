import Foundation

struct FlightOfferMapper {
    /// Fixed manual rate, supplied by composition. Nil preserves the source currency.
    var usdToBdtRate: Int? = nil

    func map(_ response: SerpApiFlightSearchResponse, currencyCode: String) -> [FlightOffer] {
        let groups = (response.bestFlights ?? []) + (response.otherFlights ?? [])
        var seenIDs = Set<String>()
        return groups.compactMap { map($0, currencyCode: currencyCode) }
            .filter { seenIDs.insert($0.id).inserted }
    }

    func map(_ group: SerpApiFlightGroup, currencyCode: String) -> FlightOffer? {
        guard let flights = group.flights, !flights.isEmpty,
              let priceValue = group.price, let totalDuration = group.totalDuration,
              priceValue >= 0, totalDuration >= 0,
              let airlines = validatedAirlines(in: flights),
              let first = flights.first, let last = flights.last,
              !first.departureAirport.id.isEmpty, !last.arrivalAirport.id.isEmpty else { return nil }

        let price: Int
        let displayCurrency: String
        if currencyCode == "USD", let rate = usdToBdtRate {
            let converted = priceValue.multipliedReportingOverflow(by: rate)
            guard rate > 0, !converted.overflow else { return nil }
            price = converted.partialValue
            displayCurrency = "BDT"
        } else {
            price = priceValue
            displayCurrency = currencyCode
        }

        // UTC is a neutral calendar for comparing airport-local dates, not a time-zone conversion.
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.calendar = Calendar(identifier: .gregorian)
        parser.timeZone = TimeZone(secondsFromGMT: 0)
        parser.dateFormat = "yyyy-MM-dd HH:mm"
        parser.isLenient = false
        guard let departure = parser.date(from: first.departureAirport.time),
              let arrival = parser.date(from: last.arrivalAirport.time),
              parser.string(from: departure) == first.departureAirport.time,
              parser.string(from: arrival) == last.arrivalAirport.time else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let dayOffset = calendar.dateComponents([.day], from: calendar.startOfDay(for: departure),
                                               to: calendar.startOfDay(for: arrival)).day ?? 0
        let logo = ([group.airlineLogo] + flights.map(\.airlineLogo))
            .compactMap { $0 }
            .compactMap { URL(string: $0) }
            .first { ["https", "http"].contains($0.scheme?.lowercased() ?? "") && $0.host != nil }

        // Length-prefixed fields avoid ambiguous concatenation and remain stable across launches.
        // Include the fare to distinguish separate priced offers for the same itinerary.
        let identity = flights.flatMap {
            [$0.departureAirport.id, $0.departureAirport.time, $0.arrivalAirport.id,
             $0.arrivalAirport.time, $0.airline!, String($0.duration)]
        } + [String(totalDuration), String(priceValue), currencyCode]
        let id = identity.map { "\($0.utf8.count):\($0)" }.joined()
        parser.dateFormat = "HH:mm"
        return FlightOffer(
            id: id,
            airlineName: airlines.joined(separator: ", "),
            airlineLogoURL: logo,
            departureAirportCode: first.departureAirport.id,
            arrivalAirportCode: last.arrivalAirport.id,
            departureTime: parser.string(from: departure),
            arrivalTime: parser.string(from: arrival),
            arrivalDayOffset: dayOffset,
            totalDurationMinutes: totalDuration,
            stopCount: group.layovers?.count ?? max(0, flights.count - 1),
            price: price,
            currencyCode: displayCurrency
        )
    }

    private func validatedAirlines(in flights: [SerpApiFlightLeg]) -> [String]? {
        var result: [String] = []
        for leg in flights {
            guard let airline = leg.airline?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !airline.isEmpty else { return nil }
            if !result.contains(airline) {
                result.append(airline)
            }
        }
        return result
    }
}
