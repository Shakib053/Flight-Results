import Foundation

/// Static sample content required by the flight-results assessment screen.
enum FlightResultsDummyData {
    static let promotions: [Promotion] = (1...7).map { index in
        Promotion(
            id: "discount-\(index)",
            imageName: "discount view",
            title: "On International Flight\nBookings",
            url: URL(string: "https://gozayaan.com")!
        )
    }

    static func dateFareOptions(departureDate: Date) -> [DateFareOption] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        let fares = [70_129, 74_240, 120_400, 82_650, 76_890, 91_320, 79_450]

        return fares.enumerated().compactMap { offset, price in
            guard let date = calendar.date(byAdding: .day, value: offset, to: departureDate) else {
                return nil
            }
            formatter.dateFormat = "yyyy-MM-dd"
            let id = formatter.string(from: date)
            formatter.dateFormat = "EEE"
            let dayText = formatter.string(from: date)
            formatter.dateFormat = "dd MMM"
            return DateFareOption(
                id: id, dayText: dayText, dateText: formatter.string(from: date),
                price: price, currencyCode: "BDT", isSelected: offset == 0
            )
        }
    }
}
