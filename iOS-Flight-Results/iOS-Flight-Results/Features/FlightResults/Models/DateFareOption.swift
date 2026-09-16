import Foundation

/// An item in the horizontally scrolling date and fare strip.
/// The selected date reflects the cheapest returned offer; other dates use sample fares.
struct DateFareOption: Identifiable, Equatable {
    let id: String
    let dayText: String
    let dateText: String
    let price: Int
    let currencyCode: String
    let isSelected: Bool
}
